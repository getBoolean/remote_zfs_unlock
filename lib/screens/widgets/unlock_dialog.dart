import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:remote_zfs_unlock/models/unlock_request.dart';
import 'package:remote_zfs_unlock/screens/widgets/futuristic_cancel_button.dart';
import 'package:remote_zfs_unlock/screens/widgets/futuristic_outlined_button.dart';
import 'package:remote_zfs_unlock/screens/widgets/keyfile_hex_or_upload_field.dart';

enum _UnlockKeyInputMethod { upload, serverPath }

class UnlockDialog extends StatefulWidget {
  const UnlockDialog({
    required this.allowedMethod,
    required this.serverPathSuggestions,
    required this.onSubmitValidation,
    this.initialServerKeyFilePath,
    super.key,
  });

  final UnlockMethod allowedMethod;
  final Future<List<String>> Function(String query) serverPathSuggestions;
  final Future<bool> Function() onSubmitValidation;
  final String? initialServerKeyFilePath;

  @override
  State<UnlockDialog> createState() => _UnlockDialogState();
}

class _UnlockDialogState extends State<UnlockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _keyFileFormFieldKey = GlobalKey<FormFieldState<Uint8List>>();
  final _passphraseController = TextEditingController();
  final _rawKeyTextController = TextEditingController();
  final _rawKeyTextFocusNode = FocusNode();
  final _serverPathController = TextEditingController();
  final _serverPathFocusNode = FocusNode();
  String? _rawKeyInputError;
  Uint8List? _keyFileBytes;
  String? _keyFileName;
  _UnlockKeyInputMethod _keyInputMethod = _UnlockKeyInputMethod.upload;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final initialPath = widget.initialServerKeyFilePath?.trim();
    if (initialPath != null && initialPath.isNotEmpty) {
      _serverPathController.text = initialPath;
      _keyInputMethod = _UnlockKeyInputMethod.serverPath;
    }
    _rawKeyTextFocusNode.addListener(() {
      if (!_rawKeyTextFocusNode.hasFocus) {
        _keyFileFormFieldKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _passphraseController.dispose();
    _rawKeyTextController.dispose();
    _rawKeyTextFocusNode.dispose();
    _serverPathController.dispose();
    _serverPathFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unlock dataset'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.allowedMethod == UnlockMethod.passphrase)
                TextFormField(
                  controller: _passphraseController,
                  decoration: const InputDecoration(labelText: 'Passphrase'),
                  obscureText: true,
                  validator: (value) {
                    if (widget.allowedMethod != UnlockMethod.passphrase) {
                      return null;
                    }
                    if ((value ?? '').trim().isEmpty) {
                      return 'Passphrase is required.';
                    }
                    return null;
                  },
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<_UnlockKeyInputMethod>(
                      segments: const [
                        ButtonSegment<_UnlockKeyInputMethod>(
                          value: _UnlockKeyInputMethod.upload,
                          label: Text('Key bytes / upload'),
                        ),
                        ButtonSegment<_UnlockKeyInputMethod>(
                          value: _UnlockKeyInputMethod.serverPath,
                          label: Text('Path on server'),
                        ),
                      ],
                      selected: {_keyInputMethod},
                      onSelectionChanged: (selection) {
                        if (selection.isEmpty) {
                          return;
                        }
                        FocusScope.of(context).unfocus();
                        _serverPathFocusNode.unfocus();
                        setState(() => _keyInputMethod = selection.first);
                        _keyFileFormFieldKey.currentState?.validate();
                      },
                    ),
                    const SizedBox(height: 8),
                    FormField<Uint8List>(
                      key: _keyFileFormFieldKey,
                      validator: (_) {
                        if (_keyInputMethod == _UnlockKeyInputMethod.upload) {
                          return _validateUploadedOrHexKeyInput();
                        }
                        final keyFilePath = _serverPathController.text.trim();
                        if (keyFilePath.isEmpty) {
                          return 'Keyfile path on server is required.';
                        }
                        return null;
                      },
                      builder: (state) {
                        final hasError =
                            state.hasError && state.errorText != null;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_keyInputMethod == _UnlockKeyInputMethod.upload)
                              KeyfileHexOrUploadField(
                                controller: _rawKeyTextController,
                                focusNode: _rawKeyTextFocusNode,
                                onChanged: (_) {
                                  if (_keyFileBytes == null &&
                                      _keyFileName == null) {
                                    if (_hexCharCount(
                                          _rawKeyTextController.text,
                                        ) >=
                                        64) {
                                      _keyFileFormFieldKey.currentState
                                          ?.validate();
                                    }
                                    return;
                                  }
                                  setState(() {
                                    _rawKeyInputError = null;
                                    _keyFileBytes = null;
                                    _keyFileName = null;
                                  });
                                  if (_hexCharCount(
                                        _rawKeyTextController.text,
                                      ) >=
                                      64) {
                                    _keyFileFormFieldKey.currentState
                                        ?.validate();
                                  }
                                },
                                uploadedFileName: _keyFileName,
                                uploadedFileSizeBytes: _keyFileBytes?.length,
                                onUploadPressed: _pickKeyFile,
                                onClearUploadedFile: _clearKeyFile,
                              )
                            else
                              Autocomplete<String>(
                                textEditingController: _serverPathController,
                                focusNode: _serverPathFocusNode,
                                optionsBuilder: _loadServerPathOptions,
                                onSelected: (_) {
                                  _keyFileFormFieldKey.currentState?.validate();
                                },
                                fieldViewBuilder:
                                    (context, controller, focusNode, onSubmit) {
                                      return TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        onSubmitted: (_) => onSubmit(),
                                        onChanged: (_) {
                                          _keyFileFormFieldKey.currentState
                                              ?.validate();
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Keyfile path on server',
                                          hintText:
                                              '/root/zfs.keys/dataset.key',
                                          helperText:
                                              'Select a keyfile path reachable by zfs load-key.',
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                                final option =
                                                    optionList[index];
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
                                padding: const EdgeInsets.only(
                                  top: 6,
                                  left: 12,
                                ),
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
                ),
            ],
          ),
        ),
      ),
      actions: [
        FuturisticCancelButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
        FuturisticOutlinedButton(
          onPressed: _isSubmitting ? null : _submit,
          icon: Icons.lock_open_outlined,
          label: 'Unlock',
        ),
      ],
    );
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
      setState(() {
        _rawKeyInputError = 'Uploaded keyfile is empty.';
        _keyFileBytes = null;
        _keyFileName = null;
      });
      _keyFileFormFieldKey.currentState?.validate();
      return;
    }
    setState(() {
      _rawKeyInputError = null;
      _keyFileBytes = file.bytes!;
      _keyFileName = file.name;
    });
    _keyFileFormFieldKey.currentState?.validate();
  }

  void _clearKeyFile() {
    setState(() {
      _rawKeyInputError = null;
      _keyFileBytes = null;
      _keyFileName = null;
    });
    _keyFileFormFieldKey.currentState?.validate();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    if (widget.allowedMethod == UnlockMethod.passphrase) {
      await _submitWithValidation(
        UnlockRequest.passphrase(_passphraseController.text),
      );
      return;
    }

    if (_keyInputMethod == _UnlockKeyInputMethod.upload) {
      final keyFileBytes =
          _keyFileBytes ?? _parseHexKeyBytes(_rawKeyTextController.text)!;
      await _submitWithValidation(UnlockRequest.keyFile(keyFileBytes));
      return;
    }

    await _submitWithValidation(
      UnlockRequest.keyFilePathOnServer(_serverPathController.text.trim()),
    );
  }

  Future<void> _submitWithValidation(UnlockRequest request) async {
    setState(() => _isSubmitting = true);
    final isValid = await widget.onSubmitValidation();
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (!isValid) {
      return;
    }
    Navigator.of(context).pop(request);
  }

  Future<Iterable<String>> _loadServerPathOptions(
    TextEditingValue textEditingValue,
  ) async {
    final query = textEditingValue.text.trim();
    if (query.isEmpty) {
      return const Iterable<String>.empty();
    }
    final suggestions = await widget.serverPathSuggestions(query);
    final normalizedQuery = query.toLowerCase();
    return suggestions.where(
      (option) => option.toLowerCase().contains(normalizedQuery),
    );
  }

  void _handleServerPathOptionTap(
    String option,
    AutocompleteOnSelected<String> onSelected,
  ) {
    if (option.endsWith('/')) {
      _serverPathController.value = TextEditingValue(
        text: option,
        selection: TextSelection.collapsed(offset: option.length),
      );
      _serverPathFocusNode.requestFocus();
      return;
    }
    onSelected(option);
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

  String? _validateUploadedOrHexKeyInput() {
    if (_rawKeyInputError != null) {
      return _rawKeyInputError;
    }
    if (_keyFileBytes != null) {
      final byteLength = _keyFileBytes!.length;
      if (byteLength != 32) {
        return 'Uploaded keyfile must be exactly 256 bit (32 bytes).';
      }
      return null;
    }

    final rawKeyText = _rawKeyTextController.text;
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

  int _hexCharCount(String input) {
    return input.replaceAll(RegExp(r'\s+'), '').length;
  }
}
