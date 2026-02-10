import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:remote_zfs_unlock/models/unlock_request.dart';

class UnlockDialog extends StatefulWidget {
  const UnlockDialog({required this.allowedMethod, super.key});

  final UnlockMethod allowedMethod;

  @override
  State<UnlockDialog> createState() => _UnlockDialogState();
}

class _UnlockDialogState extends State<UnlockDialog> {
  final _passphraseController = TextEditingController();
  Uint8List? _keyFileBytes;
  String? _keyFileName;

  @override
  void dispose() {
    _passphraseController.dispose();
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
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickKeyFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload keyfile'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_keyFileName ?? 'No file selected')),
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

    if (_keyFileBytes == null || _keyFileBytes!.isEmpty) {
      _showValidationError('Keyfile is required.');
      return;
    }
    final byteLength = _keyFileBytes!.length;
    if (byteLength != 32) {
      _showValidationError(
        'Keyfile must be exactly 256 bit (32 bytes).',
      );
      return;
    }
    Navigator.of(context).pop(UnlockRequest.keyFile(_keyFileBytes!));
  }

  void _showValidationError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
