import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remote_zfs_unlock/models/server_profile.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';
import 'package:remote_zfs_unlock/models/create_dataset_request.dart';
import 'package:remote_zfs_unlock/models/unlock_request.dart';
import 'package:remote_zfs_unlock/models/zfs_dataset.dart';
import 'package:remote_zfs_unlock/providers/app_providers.dart';
import 'package:remote_zfs_unlock/screens/create_dataset_dialog.dart';
import 'package:remote_zfs_unlock/screens/unlock_dialog.dart';
import 'package:super_clipboard/super_clipboard.dart';

class ServerDetailScreen extends HookConsumerWidget {
  const ServerDetailScreen({required this.profile, super.key});

  final ServerProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState(false);
    final datasets = useState<List<ZfsDataset>>(<ZfsDataset>[]);

    final zfsService = ref.watch(zfsServiceProvider);
    final notifier = ref.read(serverListProvider.notifier);

    void showStatusSnack(String message, {bool isError = false}) {
      if (!context.mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isError
                ? Theme.of(context).colorScheme.errorContainer
                : null,
          ),
        );
    }

    Future<void> withBusy(Future<void> Function() action) async {
      loading.value = true;
      try {
        await action();
      } catch (error) {
        showStatusSnack('$error', isError: true);
      } finally {
        loading.value = false;
      }
    }

    Future<ServerSecrets> readSecrets() => notifier.readSecrets(profile.id);

    Future<List<ZfsDataset>> fetchDatasets() async {
      final secrets = await readSecrets();
      return zfsService.listDatasets(profile: profile, secrets: secrets);
    }

    Future<void> refreshDatasets() {
      return withBusy(() async {
        datasets.value = await fetchDatasets();
        showStatusSnack('Dataset list refreshed.');
      });
    }

    Future<void> testConnection() {
      return withBusy(() async {
        final secrets = await readSecrets();
        final output = await zfsService.testConnection(
          profile: profile,
          secrets: secrets,
        );
        showStatusSnack(output.trim().isEmpty ? 'Connected.' : output.trim());
      });
    }

    Future<void> copyPropertyToClipboard({
      required String label,
      required String value,
    }) async {
      final clipboard = SystemClipboard.instance;
      if (clipboard == null) {
        showStatusSnack('Clipboard is unavailable on this platform.');
        return;
      }
      final item = DataWriterItem();
      item.add(Formats.plainText(value));
      await clipboard.write([item]);
      showStatusSnack('Copied $label.');
    }

    Future<void> lockDataset(ZfsDataset dataset) async {
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lock dataset'),
          content: Text('Unload key for `${dataset.name}`?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Lock'),
            ),
          ],
        ),
      );

      if (shouldProceed != true) {
        return;
      }

      await withBusy(() async {
        final secrets = await readSecrets();
        await zfsService.lockDataset(
          profile: profile,
          secrets: secrets,
          datasetName: dataset.name,
        );
        datasets.value = await fetchDatasets();
        showStatusSnack('Locked `${dataset.name}`.');
      });
    }

    Future<void> unlockDataset(ZfsDataset dataset) async {
      final request = await showDialog<UnlockRequest>(
        context: context,
        builder: (context) => const UnlockDialog(),
      );
      if (request == null) {
        return;
      }
      await withBusy(() async {
        final secrets = await readSecrets();
        await zfsService.unlockDataset(
          profile: profile,
          secrets: secrets,
          datasetName: dataset.name,
          request: request,
        );
        datasets.value = await fetchDatasets();
        showStatusSnack('Unlocked `${dataset.name}`.');
      });
    }

    Future<void> createDataset() async {
      final parentDatasets =
          datasets.value
              .map((dataset) => dataset.name.trim())
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      if (parentDatasets.isEmpty) {
        showStatusSnack(
          'No parent datasets available. Refresh datasets first.',
          isError: true,
        );
        return;
      }

      final request = await showDialog<CreateDatasetRequest>(
        context: context,
        builder: (context) =>
            CreateDatasetDialog(parentDatasets: parentDatasets),
      );
      if (request == null) {
        return;
      }

      await withBusy(() async {
        final secrets = await readSecrets();
        await zfsService.createDataset(
          profile: profile,
          secrets: secrets,
          request: request,
        );
        datasets.value = await fetchDatasets();
        showStatusSnack(
          'Created `${request.parentDataset}/${request.datasetName}`.',
        );
      });
    }

    useEffect(() {
      Future<void>.microtask(refreshDatasets);
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: Text(profile.name),
        actions: [
          IconButton(
            tooltip: 'Test connection',
            onPressed: loading.value ? null : testConnection,
            icon: const Icon(Icons.link),
          ),
          IconButton(
            tooltip: 'Create dataset',
            onPressed: loading.value ? null : createDataset,
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
          IconButton(
            tooltip: 'Refresh datasets',
            onPressed: loading.value ? null : refreshDatasets,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (loading.value) const LinearProgressIndicator(),
          Expanded(
            child: datasets.value.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 44),
                          SizedBox(height: 12),
                          Text(
                            'No datasets found for this server.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: datasets.value.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    itemBuilder: (context, index) {
                      final dataset = datasets.value[index];
                      final encryptedLabel = dataset.isEncrypted
                          ? 'Encrypted'
                          : 'Not encrypted';
                      final isMounted =
                          dataset.mounted.toLowerCase().trim() == 'yes';
                      final typeLabel = _formatEnumName(dataset.type.name);
                      final dedupLabel = _formatEnumName(dataset.dedup.name);
                      final compressionLabel = _formatEnumName(
                        dataset.compression.name,
                      );
                      final keyFormatLabel = _formatEnumName(
                        dataset.keyFormat.name,
                      );
                      final actionButton = !dataset.isEncrypted
                          ? const SizedBox.shrink()
                          : dataset.isKeyLoaded
                          ? FilledButton.tonalIcon(
                              onPressed: loading.value
                                  ? null
                                  : () => lockDataset(dataset),
                              icon: const Icon(Icons.lock_outline),
                              label: const Text('Lock'),
                            )
                          : FilledButton.icon(
                              onPressed: loading.value
                                  ? null
                                  : () => unlockDataset(dataset),
                              icon: const Icon(Icons.lock_open_outlined),
                              label: const Text('Unlock'),
                            );

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      dataset.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  Chip(
                                    avatar: Icon(
                                      dataset.isEncrypted
                                          ? Icons.shield_outlined
                                          : Icons.shield_moon_outlined,
                                      size: 16,
                                    ),
                                    label: Text(encryptedLabel),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 6,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isMounted
                                            ? Icons.check_circle_outline
                                            : Icons.cancel_outlined,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isMounted ? 'Mounted' : 'Not mounted',
                                      ),
                                    ],
                                  ),
                                  if (dataset.isEncrypted) ...[
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.vpn_key_outlined,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text('Key: ${dataset.keyStatus}'),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _DatasetPropertyChip(
                                    label: 'Type',
                                    value: typeLabel,
                                    icon: Icons.category_outlined,
                                    onPressed: () => copyPropertyToClipboard(
                                      label: 'Type',
                                      value: typeLabel,
                                    ),
                                  ),
                                  _DatasetPropertyChip(
                                    label: 'Used',
                                    value: _displayValue(dataset.usedByDataset),
                                    icon: Icons.data_usage_outlined,
                                    onPressed: () => copyPropertyToClipboard(
                                      label: 'Used',
                                      value: _displayValue(
                                        dataset.usedByDataset,
                                      ),
                                    ),
                                  ),
                                  _DatasetPropertyChip(
                                    label: 'Available',
                                    value: _displayValue(dataset.available),
                                    icon: Icons.storage_outlined,
                                    onPressed: () => copyPropertyToClipboard(
                                      label: 'Available',
                                      value: _displayValue(dataset.available),
                                    ),
                                  ),
                                  _DatasetPropertyChip(
                                    label: 'Compression',
                                    value: compressionLabel,
                                    icon: Icons.compress_outlined,
                                    onPressed: () => copyPropertyToClipboard(
                                      label: 'Compression',
                                      value: compressionLabel,
                                    ),
                                  ),
                                  _DatasetPropertyChip(
                                    label: 'Dedup',
                                    value: dedupLabel,
                                    icon: Icons.copy_all_outlined,
                                    onPressed: () => copyPropertyToClipboard(
                                      label: 'Dedup',
                                      value: dedupLabel,
                                    ),
                                  ),
                                  _DatasetPropertyChip(
                                    label: 'Mountpoint',
                                    value: _displayValue(dataset.mountPoint),
                                    icon: Icons.folder_open_outlined,
                                    onPressed: () => copyPropertyToClipboard(
                                      label: 'Mountpoint',
                                      value: _displayValue(dataset.mountPoint),
                                    ),
                                  ),
                                  if (dataset.isEncrypted) ...[
                                    _DatasetPropertyChip(
                                      label: 'Key format',
                                      value: keyFormatLabel,
                                      icon: Icons.vpn_key_outlined,
                                      onPressed: () => copyPropertyToClipboard(
                                        label: 'Key format',
                                        value: keyFormatLabel,
                                      ),
                                    ),
                                    _DatasetPropertyChip(
                                      label: 'Key location',
                                      value: _displayValue(dataset.keyLocation),
                                      icon: Icons.location_on_outlined,
                                      onPressed: () => copyPropertyToClipboard(
                                        label: 'Key location',
                                        value: _displayValue(
                                          dataset.keyLocation,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (dataset.isEncrypted) ...[
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: actionButton,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DatasetPropertyChip extends StatelessWidget {
  const _DatasetPropertyChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }
}

String _formatEnumName(String raw) {
  final withSpaces = raw.replaceAllMapped(
    RegExp('([a-z0-9])([A-Z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  return withSpaces
      .split(' ')
      .where((part) => part.trim().isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _displayValue(String raw) {
  final value = raw.trim();
  if (value.isEmpty || value == '-') {
    return 'N/A';
  }
  return value;
}
