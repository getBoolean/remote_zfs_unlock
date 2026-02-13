import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remote_zfs_unlock/models/create_dataset_request.dart';
import 'package:remote_zfs_unlock/models/zfs_dataset.dart';

enum _CreateEncryptionMethod { passphrase, keyFile }

enum _KeyFileInputMethod { upload, rawText, serverPath }

class _Utf8ByteLengthLimitingTextInputFormatter extends TextInputFormatter {
  const _Utf8ByteLengthLimitingTextInputFormatter(this.maxBytes);

  final int maxBytes;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (utf8.encode(newValue.text).length <= maxBytes) {
      return newValue;
    }

    final truncatedText = _truncateToMaxUtf8Bytes(newValue.text);
    final selectionOffset = newValue.selection.extentOffset.clamp(
      0,
      truncatedText.length,
    );

    return TextEditingValue(
      text: truncatedText,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }

  String _truncateToMaxUtf8Bytes(String text) {
    final buffer = StringBuffer();
    var usedBytes = 0;

    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      final runeBytes = utf8.encode(char).length;
      if (usedBytes + runeBytes > maxBytes) {
        break;
      }
      buffer.write(char);
      usedBytes += runeBytes;
    }

    return buffer.toString();
  }
}

class CreateDatasetDialog extends StatefulWidget {
  const CreateDatasetDialog({
    required this.parentDatasets,
    required this.serverPathSuggestions,
    super.key,
  });

  final List<String> parentDatasets;
  final Future<List<String>> Function(String query) serverPathSuggestions;

  @override
  State<CreateDatasetDialog> createState() => _CreateDatasetDialogState();
}

class _CreateDatasetDialogState extends State<CreateDatasetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _keyFileFormFieldKey = GlobalKey<FormFieldState<Uint8List>>();
  final _datasetNameController = TextEditingController();
  final _passphraseController = TextEditingController();
  final _confirmPassphraseController = TextEditingController();
  final _rawKeyTextController = TextEditingController();
  final _serverKeyFilePathController = TextEditingController();
  final _serverKeyFilePathFocusNode = FocusNode();

  late String _selectedParent;
  bool _encrypted = false;
  _CreateEncryptionMethod _encryptionMethod =
      _CreateEncryptionMethod.passphrase;
  _KeyFileInputMethod _keyFileInputMethod = _KeyFileInputMethod.upload;
  CreateDatasetEncryptionType _keyFileEncryptionType =
      CreateDatasetEncryptionType.on;
  ZfsCompressionType? _compressionType;
  Uint8List? _keyFileBytes;
  String? _keyFileName;
  bool _serverPathLookupInProgress = false;

  @override
  void initState() {
    super.initState();
    _selectedParent = widget.parentDatasets.first;
  }

  @override
  void dispose() {
    _datasetNameController.dispose();
    _passphraseController.dispose();
    _confirmPassphraseController.dispose();
    _rawKeyTextController.dispose();
    _serverKeyFilePathController.dispose();
    _serverKeyFilePathFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create dataset'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedParent,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Parent dataset'),
                items: widget.parentDatasets
                    .map(
                      (name) => DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _selectedParent = value);
                },
              ),
              TextFormField(
                controller: _datasetNameController,
                decoration: const InputDecoration(labelText: 'Dataset name'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final name = (value ?? '').trim();
                  if (name.isEmpty) {
                    return 'Dataset name is required.';
                  }
                  if (name.contains('/')) {
                    return 'Use a single dataset name (no slashes).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ZfsCompressionType?>(
                initialValue: _compressionType,
                decoration: const InputDecoration(labelText: 'Compression'),
                items: const [
                  DropdownMenuItem<ZfsCompressionType?>(
                    value: null,
                    child: Text('Default (inherit)'),
                  ),
                  DropdownMenuItem<ZfsCompressionType?>(
                    value: ZfsCompressionType.on,
                    child: Text('On'),
                  ),
                  DropdownMenuItem<ZfsCompressionType?>(
                    value: ZfsCompressionType.off,
                    child: Text('Off'),
                  ),
                  DropdownMenuItem<ZfsCompressionType?>(
                    value: ZfsCompressionType.lzjb,
                    child: Text('LZJB'),
                  ),
                  DropdownMenuItem<ZfsCompressionType?>(
                    value: ZfsCompressionType.gzip,
                    child: Text('GZIP'),
                  ),
                  DropdownMenuItem<ZfsCompressionType?>(
                    value: ZfsCompressionType.zle,
                    child: Text('ZLE'),
                  ),
                  DropdownMenuItem<ZfsCompressionType?>(
                    value: ZfsCompressionType.lz4,
                    child: Text('LZ4'),
                  ),
                  DropdownMenuItem<ZfsCompressionType?>(
                    value: ZfsCompressionType.zstd,
                    child: Text('ZSTD'),
                  ),
                  DropdownMenuItem<ZfsCompressionType?>(
                    value: ZfsCompressionType.zstdFast,
                    child: Text('ZSTD Fast'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _compressionType = value);
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Encrypt dataset'),
                subtitle: const Text('Require a key to load dataset keys.'),
                value: _encrypted,
                onChanged: (value) {
                  setState(() {
                    _encrypted = value;
                    if (!value) {
                      _encryptionMethod = _CreateEncryptionMethod.passphrase;
                      _keyFileInputMethod = _KeyFileInputMethod.upload;
                      _keyFileEncryptionType = CreateDatasetEncryptionType.on;
                      _passphraseController.clear();
                      _confirmPassphraseController.clear();
                      _rawKeyTextController.clear();
                      _serverKeyFilePathController.clear();
                      _keyFileBytes = null;
                      _keyFileName = null;
                      _serverPathLookupInProgress = false;
                    }
                  });
                },
              ),
              if (_encrypted) ...[
                const SizedBox(height: 8),
                SegmentedButton<_CreateEncryptionMethod>(
                  segments: const [
                    ButtonSegment<_CreateEncryptionMethod>(
                      value: _CreateEncryptionMethod.passphrase,
                      label: Text('Passphrase'),
                    ),
                    ButtonSegment<_CreateEncryptionMethod>(
                      value: _CreateEncryptionMethod.keyFile,
                      label: Text('Keyfile'),
                    ),
                  ],
                  selected: {_encryptionMethod},
                  onSelectionChanged: (selection) {
                    if (selection.isEmpty) {
                      return;
                    }
                    setState(() => _encryptionMethod = selection.first);
                  },
                ),
                if (_encryptionMethod ==
                    _CreateEncryptionMethod.passphrase) ...[
                  TextFormField(
                    controller: _passphraseController,
                    decoration: const InputDecoration(labelText: 'Passphrase'),
                    obscureText: true,
                    validator: (value) {
                      if (!_encrypted ||
                          _encryptionMethod !=
                              _CreateEncryptionMethod.passphrase) {
                        return null;
                      }
                      if ((value ?? '').trim().isEmpty) {
                        return 'Passphrase is required.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _confirmPassphraseController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm passphrase',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (!_encrypted ||
                          _encryptionMethod !=
                              _CreateEncryptionMethod.passphrase) {
                        return null;
                      }
                      if ((value ?? '').trim().isEmpty) {
                        return 'Please confirm the passphrase.';
                      }
                      if (value != _passphraseController.text) {
                        return 'Passphrases do not match.';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<CreateDatasetEncryptionType>(
                    initialValue: _keyFileEncryptionType,
                    decoration: const InputDecoration(
                      labelText: 'Encryption type',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: CreateDatasetEncryptionType.on,
                        child: Text('Default'),
                      ),
                      DropdownMenuItem(
                        value: CreateDatasetEncryptionType.aes128Ccm,
                        child: Text('AES-128-CCM'),
                      ),
                      DropdownMenuItem(
                        value: CreateDatasetEncryptionType.aes192Ccm,
                        child: Text('AES-192-CCM'),
                      ),
                      DropdownMenuItem(
                        value: CreateDatasetEncryptionType.aes256Ccm,
                        child: Text('AES-256-CCM'),
                      ),
                      DropdownMenuItem(
                        value: CreateDatasetEncryptionType.aes128Gcm,
                        child: Text('AES-128-GCM'),
                      ),
                      DropdownMenuItem(
                        value: CreateDatasetEncryptionType.aes192Gcm,
                        child: Text('AES-192-GCM'),
                      ),
                      DropdownMenuItem(
                        value: CreateDatasetEncryptionType.aes256Gcm,
                        child: Text('AES-256-GCM'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _keyFileEncryptionType = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<_KeyFileInputMethod>(
                    segments: const [
                      ButtonSegment<_KeyFileInputMethod>(
                        value: _KeyFileInputMethod.upload,
                        label: Text('Upload keyfile'),
                      ),
                      ButtonSegment<_KeyFileInputMethod>(
                        value: _KeyFileInputMethod.rawText,
                        label: Text('Raw text'),
                      ),
                      ButtonSegment<_KeyFileInputMethod>(
                        value: _KeyFileInputMethod.serverPath,
                        label: Text('Path on server'),
                      ),
                    ],
                    selected: {_keyFileInputMethod},
                    onSelectionChanged: (selection) {
                      if (selection.isEmpty) {
                        return;
                      }
                      setState(() => _keyFileInputMethod = selection.first);
                    },
                  ),
                  const SizedBox(height: 8),
                  FormField<Uint8List>(
                    key: _keyFileFormFieldKey,
                    validator: (_) {
                      if (!_encrypted ||
                          _encryptionMethod !=
                              _CreateEncryptionMethod.keyFile) {
                        return null;
                      }
                      if (_keyFileInputMethod == _KeyFileInputMethod.upload) {
                        if (_keyFileBytes == null || _keyFileBytes!.isEmpty) {
                          return 'Keyfile is required.';
                        }
                        final byteLength = _keyFileBytes!.length;
                        if (byteLength != 32) {
                          return 'Keyfile must be exactly 256 bit (32 bytes).';
                        }
                        return null;
                      }
                      final rawKeyText = _rawKeyTextController.text;
                      if (_keyFileInputMethod == _KeyFileInputMethod.rawText) {
                        if (rawKeyText.trim().isEmpty) {
                          return 'Raw key text is required.';
                        }
                        final byteLength = utf8.encode(rawKeyText).length;
                        if (byteLength != 32) {
                          return 'Raw key must be exactly 256 bit (32 bytes).';
                        }
                        return null;
                      }
                      final serverPath = _serverKeyFilePathController.text;
                      if (serverPath.trim().isEmpty) {
                        return 'Server keyfile path is required.';
                      }
                      return null;
                    },
                    builder: (state) {
                      final hasError =
                          state.hasError && state.errorText != null;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_keyFileInputMethod == _KeyFileInputMethod.upload)
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _pickKeyFile,
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Upload keyfile'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _keyFileName ?? 'No file selected',
                                  ),
                                ),
                              ],
                            )
                          else if (_keyFileInputMethod ==
                              _KeyFileInputMethod.rawText)
                            TextFormField(
                              controller: _rawKeyTextController,
                              onChanged: (_) {
                                _keyFileFormFieldKey.currentState?.validate();
                              },
                              inputFormatters: const [
                                _Utf8ByteLengthLimitingTextInputFormatter(32),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Raw key text',
                                hintText: 'Enter raw key contents',
                                helperText:
                                    'Text is sent as UTF-8 bytes and must be exactly 32 bytes.',
                              ),
                              minLines: 3,
                              maxLines: 5,
                            )
                          else
                            Autocomplete<String>(
                              textEditingController:
                                  _serverKeyFilePathController,
                              focusNode: _serverKeyFilePathFocusNode,
                              optionsBuilder: _loadServerPathOptions,
                              onSelected: (_) {
                                _keyFileFormFieldKey.currentState?.validate();
                              },
                              fieldViewBuilder:
                                  (context, controller, focusNode, onSubmit) {
                                    return TextFormField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      onFieldSubmitted: (_) => onSubmit(),
                                      onChanged: (_) {
                                        _keyFileFormFieldKey.currentState
                                            ?.validate();
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Keyfile path on server',
                                        hintText:
                                            '/root/zfs.keys/my-dataset.key',
                                        helperText: _serverPathLookupInProgress
                                            ? 'Loading path suggestions...'
                                            : 'Type to see matching paths on the server.',
                                        suffixIcon: _serverPathLookupInProgress
                                            ? const Padding(
                                                padding: EdgeInsets.all(12),
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              )
                                            : null,
                                      ),
                                    );
                                  },
                              optionsViewBuilder:
                                  (context, onSelected, options) {
                                    final optionList = options.toList();
                                    if (optionList.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(8),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxHeight: 260,
                                            minWidth: 320,
                                            maxWidth: 520,
                                          ),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: optionList.length,
                                            itemBuilder: (context, index) {
                                              final option = optionList[index];
                                              return ListTile(
                                                dense: true,
                                                title: Text(option),
                                                onTap: () =>
                                                    _handleServerPathOptionTap(
                                                      option,
                                                      onSelected,
                                                    ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                            ),
                          if (hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 12),
                              child: Text(
                                state.errorText!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Create')),
      ],
    );
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final rawTextBytes =
        _encrypted &&
            _encryptionMethod == _CreateEncryptionMethod.keyFile &&
            _keyFileInputMethod == _KeyFileInputMethod.rawText
        ? Uint8List.fromList(utf8.encode(_rawKeyTextController.text))
        : null;
    final keyFilePathOnServer =
        _encrypted &&
            _encryptionMethod == _CreateEncryptionMethod.keyFile &&
            _keyFileInputMethod == _KeyFileInputMethod.serverPath
        ? _serverKeyFilePathController.text.trim()
        : null;

    Navigator.of(context).pop(
      CreateDatasetRequest(
        parentDataset: _selectedParent,
        datasetName: _datasetNameController.text.trim(),
        encrypted: _encrypted,
        compressionType: _compressionType,
        passphrase:
            _encrypted &&
                _encryptionMethod == _CreateEncryptionMethod.passphrase
            ? _passphraseController.text
            : null,
        keyFileBytes:
            _encrypted && _encryptionMethod == _CreateEncryptionMethod.keyFile
            ? switch (_keyFileInputMethod) {
                _KeyFileInputMethod.upload => _keyFileBytes,
                _KeyFileInputMethod.rawText => rawTextBytes,
                _KeyFileInputMethod.serverPath => null,
              }
            : null,
        keyFilePathOnServer: keyFilePathOnServer,
        keyFileEncryptionType:
            _encrypted && _encryptionMethod == _CreateEncryptionMethod.keyFile
            ? _keyFileEncryptionType
            : null,
      ),
    );
  }

  Future<Iterable<String>> _loadServerPathOptions(
    TextEditingValue textEditingValue,
  ) async {
    final query = textEditingValue.text.trim();
    if (query.isEmpty) {
      if (_serverPathLookupInProgress && mounted) {
        setState(() => _serverPathLookupInProgress = false);
      }
      return const Iterable<String>.empty();
    }

    if (!_serverPathLookupInProgress && mounted) {
      setState(() => _serverPathLookupInProgress = true);
    }
    try {
      final suggestions = await widget.serverPathSuggestions(query);
      final normalizedQuery = query.toLowerCase();
      return suggestions.where(
        (option) => option.toLowerCase().contains(normalizedQuery),
      );
    } catch (_) {
      return const Iterable<String>.empty();
    } finally {
      if (_serverPathLookupInProgress && mounted) {
        setState(() => _serverPathLookupInProgress = false);
      }
    }
  }

  void _handleServerPathOptionTap(
    String option,
    AutocompleteOnSelected<String> onSelected,
  ) {
    if (option.endsWith('/')) {
      _serverKeyFilePathController.value = TextEditingValue(
        text: option,
        selection: TextSelection.collapsed(offset: option.length),
      );
      _serverKeyFilePathFocusNode.requestFocus();
      _keyFileFormFieldKey.currentState?.validate();
      return;
    }
    onSelected(option);
  }

  Future<void> _pickKeyFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      dialogTitle: 'Select ZFS keyfile',
    );
    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.first;
    if (file.bytes == null || file.bytes!.isEmpty) {
      return;
    }
    setState(() {
      _keyFileBytes = file.bytes!;
      _keyFileName = file.name;
    });
    _keyFileFormFieldKey.currentState?.validate();
  }
}
