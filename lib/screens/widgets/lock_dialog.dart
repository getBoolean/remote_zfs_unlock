import 'package:flutter/material.dart';
import 'package:remote_zfs_unlock/screens/widgets/futuristic_cancel_button.dart';
import 'package:remote_zfs_unlock/screens/widgets/futuristic_outlined_button.dart';

class LockDialog extends StatefulWidget {
  const LockDialog({
    required this.datasetName,
    required this.onSubmitValidation,
    super.key,
  });

  final String datasetName;
  final Future<bool> Function() onSubmitValidation;

  @override
  State<LockDialog> createState() => _LockDialogState();
}

class _LockDialogState extends State<LockDialog> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lock dataset'),
      content: Text('Unload key for `${widget.datasetName}`?'),
      actions: [
        FuturisticCancelButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
        FuturisticOutlinedButton(
          onPressed: _isSubmitting ? null : _submit,
          icon: Icons.lock_outline,
          label: 'Lock',
          accentColor: Theme.of(context).colorScheme.tertiary,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final isValid = await widget.onSubmitValidation();
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (!isValid) {
      return;
    }
    Navigator.of(context).pop(true);
  }
}
