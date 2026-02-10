import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remote_zfs_unlock/models/server_profile.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';
import 'package:remote_zfs_unlock/models/unlock_request.dart';
import 'package:remote_zfs_unlock/models/zfs_dataset.dart';
import 'package:remote_zfs_unlock/providers/app_providers.dart';
import 'package:remote_zfs_unlock/screens/unlock_dialog.dart';

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
