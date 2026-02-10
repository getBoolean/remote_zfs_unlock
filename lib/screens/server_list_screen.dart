import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remote_zfs_unlock/models/server_profile.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';
import 'package:remote_zfs_unlock/providers/app_providers.dart';
import 'package:remote_zfs_unlock/screens/server_detail_screen.dart';
import 'package:remote_zfs_unlock/screens/server_form_dialog.dart';

class ServerListScreen extends HookConsumerWidget {
  const ServerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(serverListProvider);
    final notifier = ref.read(serverListProvider.notifier);
    final canAddServer = !kIsWeb;

    Future<void> openForm({ServerProfile? profile}) async {
      final initialSecrets = profile == null
          ? const ServerSecrets()
          : await notifier.readSecrets(profile.id);
      if (!context.mounted) {
        return;
      }

      final result = await showDialog<ServerFormResult>(
        context: context,
        builder: (context) => ServerFormDialog(
          initialProfile: profile,
          initialSecrets: initialSecrets,
        ),
      );
      if (result == null) {
        return;
      }

      await notifier.saveProfile(
        profile: result.profile,
        secrets: result.secrets,
      );
    }

    Future<void> deleteProfile(ServerProfile profile) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete server'),
          content: Text('Delete "${profile.name}" and all stored secrets?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return;
      }
      await notifier.deleteProfile(profile.id);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Servers'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: notifier.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: !canAddServer
          ? null
          : FloatingActionButton.extended(
              onPressed: () => openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add server'),
            ),
      body: profilesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load profiles: $error')),
        data: (profiles) {
          if (kIsWeb) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 44),
                    SizedBox(height: 12),
                    Text(
                      'Connecting to SSH servers is unsupported on web.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          if (profiles.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dns_outlined, size: 44),
                    SizedBox(height: 12),
                    Text(
                      'No servers yet. Tap "Add server" to begin.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: profiles.length,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    child: Text(
                      profile.name.trim().isEmpty
                          ? '?'
                          : profile.name.trim()[0].toUpperCase(),
                    ),
                  ),
                  title: Text(
                    profile.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${profile.username}@${profile.host}:${profile.port}',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ServerDetailScreen(profile: profile),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () => openForm(profile: profile),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () => deleteProfile(profile),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
