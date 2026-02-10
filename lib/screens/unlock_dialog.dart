import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:remote_zfs_unlock/models/unlock_request.dart';

enum _UnlockKeyInputMethod { upload, serverPath }

class UnlockDialog extends StatefulWidget {
  const UnlockDialog({
    required this.allowedMethod,
    required this.serverPathSuggestions,
    this.initialServerKeyFilePath,
    super.key,
  });

  final UnlockMethod allowedMethod;
  final Future<List<String>> Function(String query) serverPathSuggestions;
  final String? initialServerKeyFilePath;

  @override
  State<UnlockDialog> createState() => _UnlockDialogState();
}

class _UnlockDialogState extends State<UnlockDialog> {
  final _passphraseController = TextEditingController();
  final _serverPathController = TextEditingController();
  final _serverPathFocusNode = FocusNode();
  Uint8List? _keyFileBytes;
  String? _keyFileName;
  _UnlockKeyInputMethod _keyInputMethod = _UnlockKeyInputMethod.upload;

  @override
  void initState() {
    super.initState();
    final initialPath = widget.initialServerKeyFilePath?.trim();
    if (initialPath != null && initialPath.isNotEmpty) {
      _serverPathController.text = initialPath;
      _keyInputMethod = _UnlockKeyInputMethod.serverPath;
    }
  }

  @override
  void dispose() {
    _passphraseController.dispose();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.allowedMethod == UnlockMethod.passphrase)
              TextField(
                controller: _passphraseController,
                decoration: const InputDecoration(labelText: 'Passphrase'),
                obscureText: true,
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<_UnlockKeyInputMethod>(
                    segments: const [
                      ButtonSegment<_UnlockKeyInputMethod>(
                        value: _UnlockKeyInputMethod.upload,
                        label: Text('Upload keyfile'),
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
                      setState(() => _keyInputMethod = selection.first);
                    },
                  ),
                  const SizedBox(height: 8),
                  if (_keyInputMethod == _UnlockKeyInputMethod.upload)
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickKeyFile,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload keyfile'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_keyFileName ?? 'No file selected'),
                        ),
                      ],
                    )
                  else
                    Autocomplete<String>(
                      textEditingController: _serverPathController,
                      focusNode: _serverPathFocusNode,
                      optionsBuilder: _loadServerPathOptions,
                      onSelected: (_) {},
                      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onSubmitted: (_) => onSubmit(),
                          decoration: const InputDecoration(
                            labelText: 'Keyfile path on server',
                            hintText: '/root/zfs.keys/dataset.key',
                            helperText:
                                'Select a keyfile path reachable by zfs load-key.',
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
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
                                    onTap: () => _handleServerPathOptionTap(
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
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Unlock')),
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
    if (file.bytes == null) {
      return;
    }
    setState(() {
      _keyFileBytes = file.bytes!;
      _keyFileName = file.name;
    });
  }

  void _submit() {
    if (widget.allowedMethod == UnlockMethod.passphrase) {
      final passphrase = _passphraseController.text;
      if (passphrase.trim().isEmpty) {
        _showValidationError('Passphrase is required.');
        return;
      }
      Navigator.of(context).pop(UnlockRequest.passphrase(passphrase));
      return;
    }

    if (_keyInputMethod == _UnlockKeyInputMethod.upload) {
      if (_keyFileBytes == null || _keyFileBytes!.isEmpty) {
        _showValidationError('Keyfile is required.');
        return;
      }
      final byteLength = _keyFileBytes!.length;
      if (byteLength != 32) {
        _showValidationError('Keyfile must be exactly 256 bit (32 bytes).');
        return;
      }
      Navigator.of(context).pop(UnlockRequest.keyFile(_keyFileBytes!));
      return;
    }

    final keyFilePath = _serverPathController.text.trim();
    if (keyFilePath.isEmpty) {
      _showValidationError('Keyfile path on server is required.');
      return;
    }
    Navigator.of(context).pop(UnlockRequest.keyFilePathOnServer(keyFilePath));
  }

  void _showValidationError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
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
}
