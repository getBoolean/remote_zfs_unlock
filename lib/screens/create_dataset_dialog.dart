import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:remote_zfs_unlock/models/create_dataset_request.dart';

enum _CreateEncryptionMethod { passphrase, keyFile }

enum _KeyFileInputMethod { upload, rawText }

class CreateDatasetDialog extends StatefulWidget {
  const CreateDatasetDialog({required this.parentDatasets, super.key});

  final List<String> parentDatasets;

  @override
  State<CreateDatasetDialog> createState() => _CreateDatasetDialogState();
}

class _CreateDatasetDialogState extends State<CreateDatasetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _datasetNameController = TextEditingController();
  final _passphraseController = TextEditingController();
  final _confirmPassphraseController = TextEditingController();
  final _rawKeyTextController = TextEditingController();

  late String _selectedParent;
  bool _encrypted = false;
  _CreateEncryptionMethod _encryptionMethod =
      _CreateEncryptionMethod.passphrase;
  _KeyFileInputMethod _keyFileInputMethod = _KeyFileInputMethod.upload;
  CreateDatasetEncryptionType _keyFileEncryptionType =
      CreateDatasetEncryptionType.on;
  Uint8List? _keyFileBytes;
  String? _keyFileName;

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
                      _keyFileBytes = null;
                      _keyFileName = null;
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
                      if (rawKeyText.trim().isEmpty) {
                        return 'Raw key text is required.';
                      }
                      final byteLength = utf8.encode(rawKeyText).length;
                      if (byteLength != 32) {
                        return 'Raw key must be exactly 256 bit (32 bytes).';
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
                          else
                            TextFormField(
                              controller: _rawKeyTextController,
                              decoration: const InputDecoration(
                                labelText: 'Raw key text',
                                hintText: 'Enter raw key contents',
                                helperText:
                                    'Text is sent as UTF-8 bytes and must be exactly 32 bytes.',
                              ),
                              minLines: 3,
                              maxLines: 5,
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

    Navigator.of(context).pop(
      CreateDatasetRequest(
        parentDataset: _selectedParent,
        datasetName: _datasetNameController.text.trim(),
        encrypted: _encrypted,
        passphrase:
            _encrypted &&
                _encryptionMethod == _CreateEncryptionMethod.passphrase
            ? _passphraseController.text
            : null,
        keyFileBytes:
            _encrypted && _encryptionMethod == _CreateEncryptionMethod.keyFile
            ? (_keyFileInputMethod == _KeyFileInputMethod.upload
                  ? _keyFileBytes
                  : rawTextBytes)
            : null,
        keyFileEncryptionType:
            _encrypted && _encryptionMethod == _CreateEncryptionMethod.keyFile
            ? _keyFileEncryptionType
            : null,
      ),
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
      return;
    }
    setState(() {
      _keyFileBytes = file.bytes!;
      _keyFileName = file.name;
    });
  }
}
