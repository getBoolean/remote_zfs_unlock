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

    Future<void> openForm({
      ServerProfile? profile,
    }) async {
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

      await notifier.saveProfile(profile: result.profile, secrets: result.secrets);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add server'),
      ),
      body: profilesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load profiles: $error')),
        data: (profiles) {
          if (profiles.isEmpty) {
            return const Center(
              child: Text('No servers yet. Tap "Add server" to begin.'),
            );
          }
          return ListView.separated(
            itemCount: profiles.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return ListTile(
                title: Text(profile.name),
                subtitle: Text('${profile.username}@${profile.host}:${profile.port}'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ServerDetailScreen(profile: profile),
                    ),
                  );
                },
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: () => openForm(profile: profile),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () => deleteProfile(profile),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
