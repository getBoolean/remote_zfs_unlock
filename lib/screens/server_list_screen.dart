import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_zfs_unlock/models/server_profile.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';
import 'package:remote_zfs_unlock/providers/app_providers.dart';
import 'package:remote_zfs_unlock/screens/server_detail_screen.dart';
import 'package:remote_zfs_unlock/screens/widgets/futuristic_cancel_button.dart';
import 'package:remote_zfs_unlock/screens/widgets/futuristic_outlined_button.dart';
import 'package:remote_zfs_unlock/screens/widgets/server_form_dialog.dart';
class ServerListScreen extends ConsumerWidget {
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
          scrollable: true,
          title: const Text('Delete server'),
          content: Text('Delete "${profile.name}" and all stored secrets?'),
          actions: [
            FuturisticCancelButton(
              onPressed: () => Navigator.of(context).pop(false),
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
          : SizedBox(
              height: 56,
              child: FuturisticOutlinedButton(
                onPressed: () => openForm(),
                icon: Icons.add_rounded,
                label: 'Add server',
                accentColor: Theme.of(context).colorScheme.primary,
                borderRadius: 20,
              ),
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
              return _ServerListTile(
                profile: profile,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ServerDetailScreen(profile: profile),
                    ),
                  );
                },
                onEdit: () => openForm(profile: profile),
                onDelete: () => deleteProfile(profile),
              );
            },
          );
        },
      ),
    );
  }
}

class _ServerListTile extends ConsumerStatefulWidget {
  const _ServerListTile({
    required this.profile,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final ServerProfile profile;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  ConsumerState<_ServerListTile> createState() => _ServerListTileState();
}

class _ServerListTileState extends ConsumerState<_ServerListTile> {
  bool _sendingWol = false;

  Future<void> _sendWol() async {
    final mac = widget.profile.macAddress;
    if (mac == null || mac.isEmpty) return;

    setState(() => _sendingWol = true);
    try {
      final wol = ref.read(wolServiceProvider);
      await wol.sendMagicPacket(
        macAddress: mac,
        broadcastAddress: widget.profile.broadcastAddress,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Magic packet sent to ${widget.profile.name}'),
          ),
        );
        // Refresh reachability after a short delay
        ref.invalidate(
          serverReachableProvider(widget.profile.host, widget.profile.port),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send magic packet: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingWol = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final reachableAsync = ref.watch(
      serverReachableProvider(profile.host, profile.port),
    );
    final scheme = Theme.of(context).colorScheme;
    final hasMac = profile.macAddress != null && profile.macAddress!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              child: Text(
                profile.name.trim().isEmpty
                    ? '?'
                    : profile.name.trim()[0].toUpperCase(),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: reachableAsync.when(
                data: (online) => Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: online
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFEF5350),
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.surface, width: 2),
                  ),
                ),
                loading: () => SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.outline,
                  ),
                ),
                error: (_, _) => Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: scheme.outline,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.surface, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          profile.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${profile.username}@${profile.host}:${profile.port}',
              ),
              reachableAsync.when(
                data: (online) => Text(
                  online ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: online
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFEF5350),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading: () => Text(
                  'Checking...',
                  style: TextStyle(
                    color: scheme.outline,
                    fontSize: 12,
                  ),
                ),
                error: (_, _) => Text(
                  'Unknown',
                  style: TextStyle(
                    color: scheme.outline,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: widget.onTap,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasMac)
              reachableAsync.maybeWhen(
                data: (online) => online
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: 'Wake on LAN',
                        onPressed: _sendingWol ? null : _sendWol,
                        icon: _sendingWol
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: scheme.primary,
                                ),
                              )
                            : const Icon(Icons.power_settings_new),
                      ),
                orElse: () => const SizedBox.shrink(),
              ),
            IconButton(
              tooltip: 'Edit',
              onPressed: widget.onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: widget.onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
