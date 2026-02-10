import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:remote_zfs_unlock/models/auth_mode.dart';
import 'package:remote_zfs_unlock/models/server_profile.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';
import 'package:uuid/uuid.dart';

class ServerFormResult {
  const ServerFormResult({
    required this.profile,
    required this.secrets,
  });

  final ServerProfile profile;
  final ServerSecrets secrets;
}

class ServerFormDialog extends StatefulWidget {
  const ServerFormDialog({
    required this.initialProfile,
    required this.initialSecrets,
    super.key,
  });

  final ServerProfile? initialProfile;
  final ServerSecrets initialSecrets;

  @override
  State<ServerFormDialog> createState() => _ServerFormDialogState();
}

class _ServerFormDialogState extends State<ServerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _keyPemController = TextEditingController();
  final _keyPassphraseController = TextEditingController();

  late SshAuthMode _authMode;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _nameController.text = profile?.name ?? '';
    _hostController.text = profile?.host ?? '';
    _portController.text = (profile?.port ?? 22).toString();
    _usernameController.text = profile?.username ?? '';
    _passwordController.text = widget.initialSecrets.password ?? '';
    _keyPemController.text = widget.initialSecrets.privateKeyPem ?? '';
    _keyPassphraseController.text = widget.initialSecrets.privateKeyPassphrase ?? '';
    _authMode = profile?.authMode ?? SshAuthMode.password;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _keyPemController.dispose();
    _keyPassphraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialProfile == null ? 'Add server' : 'Edit server'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Display name'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(labelText: 'Host'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  controller: _portController,
                  decoration: const InputDecoration(labelText: 'Port'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid port';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<SshAuthMode>(
                  initialValue: _authMode,
                  decoration: const InputDecoration(labelText: 'Authentication'),
                  items: const [
                    DropdownMenuItem(
                      value: SshAuthMode.password,
                      child: Text('Password'),
                    ),
                    DropdownMenuItem(
                      value: SshAuthMode.privateKey,
                      child: Text('Private key'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _authMode = value);
                  },
                ),
                const SizedBox(height: 8),
                if (_authMode == SshAuthMode.password)
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: _requiredValidator,
                  )
                else ...[
                  TextFormField(
                    controller: _keyPemController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Private key PEM',
                      hintText: '-----BEGIN ...',
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickPrivateKey,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload keyfile'),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _keyPassphraseController,
                    decoration: const InputDecoration(
                      labelText: 'Private key passphrase (optional)',
                    ),
                    obscureText: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickPrivateKey() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      dialogTitle: 'Select private key file',
    );
    final files = result?.files;
    if (files == null || files.isEmpty) {
      return;
    }
    final file = files.first;
    if (file.bytes == null) {
      return;
    }
    _keyPemController.text = utf8.decode(file.bytes!);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profile = ServerProfile(
      id: widget.initialProfile?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      host: _hostController.text.trim(),
      port: int.parse(_portController.text.trim()),
      username: _usernameController.text.trim(),
      authMode: _authMode,
    );

    final secrets = _authMode == SshAuthMode.password
        ? ServerSecrets(password: _passwordController.text)
        : ServerSecrets(
            privateKeyPem: _keyPemController.text,
            privateKeyPassphrase: _keyPassphraseController.text.trim().isEmpty
                ? null
                : _keyPassphraseController.text,
          );

    Navigator.of(context).pop(ServerFormResult(profile: profile, secrets: secrets));
  }
}
