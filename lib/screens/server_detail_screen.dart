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
  const ServerDetailScreen({
    required this.profile,
    super.key,
  });

  final ServerProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState(false);
    final statusMessage = useState<String?>(null);
    final datasets = useState<List<ZfsDataset>>(<ZfsDataset>[]);

    final zfsService = ref.watch(zfsServiceProvider);
    final notifier = ref.read(serverListProvider.notifier);

    Future<void> withBusy(Future<void> Function() action) async {
      loading.value = true;
      statusMessage.value = null;
      try {
        await action();
      } catch (error) {
        statusMessage.value = '$error';
      } finally {
        loading.value = false;
      }
    }

    Future<ServerSecrets> readSecrets() => notifier.readSecrets(profile.id);

    Future<List<ZfsDataset>> fetchDatasets() async {
      final secrets = await readSecrets();
      return zfsService.listDatasets(
        profile: profile,
        secrets: secrets,
      );
    }

    Future<void> refreshDatasets() {
      return withBusy(() async {
        datasets.value = await fetchDatasets();
        statusMessage.value = 'Dataset list refreshed.';
      });
    }

    Future<void> testConnection() {
      return withBusy(() async {
        final secrets = await readSecrets();
        final output = await zfsService.testConnection(
          profile: profile,
          secrets: secrets,
        );
        statusMessage.value = output.trim().isEmpty ? 'Connected.' : output.trim();
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
        statusMessage.value = 'Locked `${dataset.name}`.';
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
        statusMessage.value = 'Unlocked `${dataset.name}`.';
      });
    }

    useEffect(
      () {
        Future<void>.microtask(refreshDatasets);
        return null;
      },
      const [],
    );

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
          if (statusMessage.value != null)
            MaterialBanner(
              content: Text(statusMessage.value!),
              actions: [
                TextButton(
                  onPressed: () => statusMessage.value = null,
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          Expanded(
            child: ListView.separated(
              itemCount: datasets.value.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final dataset = datasets.value[index];
                final encryptedLabel = dataset.isEncrypted ? 'encrypted' : 'not encrypted';
                final actionButton = !dataset.isEncrypted
                    ? const SizedBox.shrink()
                    : dataset.isKeyLoaded
                        ? FilledButton.tonal(
                            onPressed: loading.value ? null : () => lockDataset(dataset),
                            child: const Text('Lock'),
                          )
                        : FilledButton(
                            onPressed: loading.value ? null : () => unlockDataset(dataset),
                            child: const Text('Unlock'),
                          );

                return ListTile(
                  title: Text(dataset.name),
                  subtitle: Text(
                    '$encryptedLabel - key: ${dataset.keyStatus} - mounted: ${dataset.mounted}',
                  ),
                  trailing: actionButton,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
