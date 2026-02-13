import 'package:flutter/material.dart';
import 'package:remote_zfs_unlock/screens/widgets/futuristic_cancel_button.dart';

class DeleteDatasetDialog extends StatefulWidget {
  const DeleteDatasetDialog({required this.datasetName, super.key});

  final String datasetName;

  @override
  State<DeleteDatasetDialog> createState() => _DeleteDatasetDialogState();
}

class _DeleteDatasetDialogState extends State<DeleteDatasetDialog> {
  final TextEditingController _confirmationController = TextEditingController();

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete dataset'),
      content: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _confirmationController,
        builder: (context, value, child) {
          final isExactMatch = value.text == widget.datasetName;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Permanently destroy `${widget.datasetName}`?\n\n'
                'This cannot be undone.',
              ),
              const SizedBox(height: 12),
              Text(
                'Type the dataset name to confirm:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmationController,
                autofocus: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: widget.datasetName,
                  helperText: isExactMatch
                      ? 'Name matches. You can delete now.'
                      : 'Name must match exactly.',
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        FuturisticCancelButton(
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _confirmationController,
          builder: (context, value, child) {
            final isExactMatch = value.text == widget.datasetName;
            return FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: isExactMatch
                  ? () => Navigator.of(context).pop(true)
                  : null,
              child: const Text('Delete'),
            );
          },
        ),
      ],
    );
  }
}
