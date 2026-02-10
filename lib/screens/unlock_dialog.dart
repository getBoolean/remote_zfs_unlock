import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:remote_zfs_unlock/models/unlock_request.dart';

class UnlockDialog extends StatefulWidget {
  const UnlockDialog({super.key});

  @override
  State<UnlockDialog> createState() => _UnlockDialogState();
}

class _UnlockDialogState extends State<UnlockDialog> {
  UnlockMethod _method = UnlockMethod.passphrase;
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
            SegmentedButton<UnlockMethod>(
              segments: const [
                ButtonSegment<UnlockMethod>(
                  value: UnlockMethod.passphrase,
                  label: Text('Passphrase'),
                ),
                ButtonSegment<UnlockMethod>(
                  value: UnlockMethod.keyFile,
                  label: Text('Keyfile'),
                ),
              ],
              selected: {_method},
              onSelectionChanged: (selection) {
                if (selection.isEmpty) {
                  return;
                }
                setState(() => _method = selection.first);
              },
            ),
            if (_method == UnlockMethod.passphrase)
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
    if (_method == UnlockMethod.passphrase) {
      final passphrase = _passphraseController.text;
      if (passphrase.trim().isEmpty) {
        return;
      }
      Navigator.of(context).pop(UnlockRequest.passphrase(passphrase));
      return;
    }

    if (_keyFileBytes == null || _keyFileBytes!.isEmpty) {
      return;
    }
    Navigator.of(context).pop(UnlockRequest.keyFile(_keyFileBytes!));
  }
}
