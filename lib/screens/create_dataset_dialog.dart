import 'package:flutter/material.dart';
import 'package:remote_zfs_unlock/models/create_dataset_request.dart';

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

  late String _selectedParent;
  bool _encrypted = false;

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
                title: const Text('Encrypt with passphrase'),
                subtitle: const Text('Require a passphrase to load keys.'),
                value: _encrypted,
                onChanged: (value) {
                  setState(() => _encrypted = value);
                },
              ),
              if (_encrypted) ...[
                TextFormField(
                  controller: _passphraseController,
                  decoration: const InputDecoration(labelText: 'Passphrase'),
                  obscureText: true,
                  validator: (value) {
                    if (!_encrypted) {
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
                    if (!_encrypted) {
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

    Navigator.of(context).pop(
      CreateDatasetRequest(
        parentDataset: _selectedParent,
        datasetName: _datasetNameController.text.trim(),
        encrypted: _encrypted,
        passphrase: _encrypted ? _passphraseController.text : null,
      ),
    );
  }
}
