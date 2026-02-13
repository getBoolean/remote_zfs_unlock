import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remote_zfs_unlock/models/create_dataset_request.dart';
import 'package:remote_zfs_unlock/models/zfs_dataset.dart';
import 'package:remote_zfs_unlock/screens/widgets/futuristic_outlined_button.dart';

enum _CreateEncryptionMethod { none, passphrase, keyFile }

enum _KeyFileInputMethod { rawText, serverPath }

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
  _CreateEncryptionMethod _encryptionMethod = _CreateEncryptionMethod.none;
  _KeyFileInputMethod _keyFileInputMethod = _KeyFileInputMethod.rawText;
  CreateDatasetEncryptionType _keyFileEncryptionType =
      CreateDatasetEncryptionType.on;
  ZfsCompressionType? _compressionType;
  String? _rawKeyInputError;
  Uint8List? _uploadedKeyFileBytes;
  String? _uploadedKeyFileName;
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
    final scheme = Theme.of(context).colorScheme;
    const dropdownMenuColor = Color.fromARGB(255, 17, 35, 58);
    const dropdownTextStyle = TextStyle(
      color: Color(0xFFEAF5FF),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    return AlertDialog(
      scrollable: true,
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
                dropdownColor: dropdownMenuColor,
                style: dropdownTextStyle,
                iconEnabledColor: scheme.primary,
                borderRadius: BorderRadius.circular(14),
                menuMaxHeight: 360,
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
              const SizedBox(height: 8),
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
                dropdownColor: dropdownMenuColor,
                style: dropdownTextStyle,
                iconEnabledColor: scheme.primary,
                borderRadius: BorderRadius.circular(14),
                menuMaxHeight: 360,
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
              const Text(
                'Encryption',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SegmentedButton<_CreateEncryptionMethod>(
                segments: const [
                  ButtonSegment<_CreateEncryptionMethod>(
                    value: _CreateEncryptionMethod.none,
                    label: Text('None'),
                  ),
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
                  setState(() {
                    _encryptionMethod = selection.first;
                    if (_encryptionMethod == _CreateEncryptionMethod.none) {
                      _keyFileInputMethod = _KeyFileInputMethod.rawText;
                      _keyFileEncryptionType = CreateDatasetEncryptionType.on;
                      _passphraseController.clear();
                      _confirmPassphraseController.clear();
                      _rawKeyTextController.clear();
                      _rawKeyInputError = null;
                      _uploadedKeyFileBytes = null;
                      _uploadedKeyFileName = null;
                      _serverKeyFilePathController.clear();
                      _serverPathLookupInProgress = false;
                    }
                  });
                },
              ),
              if (_encryptionMethod != _CreateEncryptionMethod.none) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<CreateDatasetEncryptionType>(
                  initialValue: _keyFileEncryptionType,
                  dropdownColor: dropdownMenuColor,
                  style: dropdownTextStyle,
                  iconEnabledColor: scheme.primary,
                  borderRadius: BorderRadius.circular(14),
                  menuMaxHeight: 360,
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
                if (_encryptionMethod ==
                    _CreateEncryptionMethod.passphrase) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passphraseController,
                    decoration: const InputDecoration(labelText: 'Passphrase'),
                    obscureText: true,
                    validator: (value) {
                      if (_encryptionMethod !=
                          _CreateEncryptionMethod.passphrase) {
                        return null;
                      }
                      if ((value ?? '').trim().isEmpty) {
                        return 'Passphrase is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPassphraseController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm passphrase',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (_encryptionMethod !=
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
                  SegmentedButton<_KeyFileInputMethod>(
                    segments: const [
                      ButtonSegment<_KeyFileInputMethod>(
                        value: _KeyFileInputMethod.rawText,
                        label: Text('Key bytes / upload'),
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
                      if (_encryptionMethod !=
                          _CreateEncryptionMethod.keyFile) {
                        return null;
                      }
                      final rawKeyText = _rawKeyTextController.text;
                      if (_keyFileInputMethod == _KeyFileInputMethod.rawText) {
                        if (_rawKeyInputError != null) {
                          return _rawKeyInputError;
                        }
                        if (_uploadedKeyFileBytes != null) {
                          final byteLength = _uploadedKeyFileBytes!.length;
                          if (byteLength != 32) {
                            return 'Uploaded keyfile must be exactly 256 bit (32 bytes).';
                          }
                          return null;
                        }
                        if (rawKeyText.trim().isEmpty) {
                          return 'Key is required.';
                        }
                        final parsed = _parseHexKeyBytes(rawKeyText);
                        if (parsed == null) {
                          return 'Enter key as hex bytes (64 hex chars).';
                        }
                        if (parsed.length != 32) {
                          return 'Key must be exactly 32 bytes (64 hex chars).';
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
                          if (_keyFileInputMethod ==
                              _KeyFileInputMethod.rawText)
                            TextFormField(
                              controller: _rawKeyTextController,
                              onChanged: (_) {
                                setState(() {
                                  _rawKeyInputError = null;
                                  _uploadedKeyFileBytes = null;
                                  _uploadedKeyFileName = null;
                                });
                                _keyFileFormFieldKey.currentState?.validate();
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9a-fA-F]'),
                                ),
                                LengthLimitingTextInputFormatter(64),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Raw key bytes (hex)',
                                hintText: 'Example: 001122... (64 hex chars)',
                                helperText: _uploadedKeyFileName != null
                                    ? 'Using uploaded keyfile: $_uploadedKeyFileName (${_uploadedKeyFileBytes?.length ?? 0} bytes).'
                                    : 'Type hex bytes or upload keyfile. Key must be exactly 32 bytes.',
                                suffixIcon: IconButton(
                                  onPressed: _pickKeyFileIntoRawText,
                                  tooltip: 'Upload keyfile',
                                  icon: const Icon(Icons.upload_file),
                                ),
                              ),
                              minLines: 1,
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
        FuturisticOutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icons.close_rounded,
          label: 'Cancel',
          toneDownGlow: true,
          accentColor: scheme.error,
        ),
        FuturisticOutlinedButton(
          onPressed: _submit,
          icon: Icons.add_rounded,
          label: 'Create',
          accentColor: scheme.primary,
        ),
      ],
    );
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final rawTextBytes =
        _encryptionMethod == _CreateEncryptionMethod.keyFile &&
            _keyFileInputMethod == _KeyFileInputMethod.rawText
        ? (_uploadedKeyFileBytes ??
              _parseHexKeyBytes(_rawKeyTextController.text))
        : null;
    final keyFilePathOnServer =
        _encryptionMethod == _CreateEncryptionMethod.keyFile &&
            _keyFileInputMethod == _KeyFileInputMethod.serverPath
        ? _serverKeyFilePathController.text.trim()
        : null;
    final encrypted = _encryptionMethod != _CreateEncryptionMethod.none;

    Navigator.of(context).pop(
      CreateDatasetRequest(
        parentDataset: _selectedParent,
        datasetName: _datasetNameController.text.trim(),
        encrypted: encrypted,
        compressionType: _compressionType,
        passphrase: _encryptionMethod == _CreateEncryptionMethod.passphrase
            ? _passphraseController.text
            : null,
        keyFileBytes: _encryptionMethod == _CreateEncryptionMethod.keyFile
            ? switch (_keyFileInputMethod) {
                _KeyFileInputMethod.rawText => rawTextBytes,
                _KeyFileInputMethod.serverPath => null,
              }
            : null,
        keyFilePathOnServer: keyFilePathOnServer,
        keyFileEncryptionType: _encryptionMethod != _CreateEncryptionMethod.none
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

  Future<void> _pickKeyFileIntoRawText() async {
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
      setState(() {
        _uploadedKeyFileBytes = null;
        _uploadedKeyFileName = null;
        _rawKeyInputError = 'Uploaded keyfile is empty.';
      });
      _keyFileFormFieldKey.currentState?.validate();
      return;
    }
    setState(() {
      _uploadedKeyFileBytes = file.bytes!;
      _uploadedKeyFileName = file.name;
      _rawKeyInputError = null;
    });
    _keyFileFormFieldKey.currentState?.validate();
  }

  Uint8List? _parseHexKeyBytes(String input) {
    final normalized = input.replaceAll(RegExp(r'\s+'), '');
    if (normalized.isEmpty || normalized.length.isOdd) {
      return null;
    }

    final bytes = Uint8List(normalized.length ~/ 2);
    for (var i = 0; i < normalized.length; i += 2) {
      final byteValue = int.tryParse(normalized.substring(i, i + 2), radix: 16);
      if (byteValue == null) {
        return null;
      }
      bytes[i ~/ 2] = byteValue;
    }
    return bytes;
  }
}
