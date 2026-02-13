import 'package:flutter/material.dart';

class LockDialog extends StatefulWidget {
  const LockDialog({required this.datasetName, required this.onSubmitValidation, super.key});

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
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lock'),
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
