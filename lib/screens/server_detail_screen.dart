import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_ce/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remote_zfs_unlock/models/server_profile.dart';
import 'package:remote_zfs_unlock/models/server_secrets.dart';
import 'package:remote_zfs_unlock/models/create_dataset_request.dart';
import 'package:remote_zfs_unlock/models/unlock_request.dart';
import 'package:remote_zfs_unlock/models/zfs_dataset.dart';
import 'package:remote_zfs_unlock/providers/app_providers.dart';
import 'package:remote_zfs_unlock/screens/create_dataset_dialog.dart';
import 'package:remote_zfs_unlock/screens/delete_dataset_dialog.dart';
import 'package:remote_zfs_unlock/screens/lock_dialog.dart';
import 'package:remote_zfs_unlock/screens/widgets/dataset_sort_controls.dart';
import 'package:remote_zfs_unlock/screens/unlock_dialog.dart';

class ServerDetailScreen extends StatefulHookConsumerWidget {
  const ServerDetailScreen({required this.profile, super.key});

  final ServerProfile profile;

  @override
  ConsumerState<ServerDetailScreen> createState() => _ServerDetailScreenState();
}

class _ServerDetailScreenState extends ConsumerState<ServerDetailScreen>
    with WidgetsBindingObserver {
  bool Function()? _isLoading;
  Future<void> Function()? _refreshDatasets;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }
    if (_isLoading?.call() ?? true) {
      return;
    }
    final refreshDatasets = _refreshDatasets;
    if (refreshDatasets != null) {
      Future<void>.microtask(refreshDatasets);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = useState(false);
    final datasets = useState<List<ZfsDataset>>(<ZfsDataset>[]);
    final visibleDatasetTypes = useState<Set<ZfsDatasetType>>({
      ZfsDatasetType.filesystem,
    });
    final selectedSortField = useState<DatasetSortField>(
      DatasetSortField.datasetName,
    );
    final sortDirection = useState<DatasetSortDirection>(
      DatasetSortDirection.ascending,
    );

    final zfsService = ref.watch(zfsServiceProvider);
    final lockUnlockHelper = ref.watch(datasetLockUnlockHelperProvider);
    final clipboardService = ref.watch(clipboardServiceProvider);
    final notifier = ref.read(serverListProvider.notifier);
    final profile = widget.profile;
    final datasetSortKey = 'dataset_sort_${profile.id}';

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
                ? Theme.of(context).colorScheme.error
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
        if (context.mounted) {
          loading.value = false;
        }
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
      });
    }

    _isLoading = () => loading.value;
    _refreshDatasets = refreshDatasets;

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
      final copied = await clipboardService.copyPlainText(value);
      if (!copied) {
        showStatusSnack('Clipboard is unavailable on this platform.');
        return;
      }
      showStatusSnack('Copied $label.');
    }

    Future<void> lockDataset(ZfsDataset dataset) async {
      ZfsDataset? currentDataset;
      final shouldLock = await showDialog<bool>(
        context: context,
        builder: (context) => LockDialog(
          datasetName: dataset.name,
          onSubmitValidation: () async {
            currentDataset = await lockUnlockHelper.refreshAndValidateDatasetState(
              profile: profile,
              readSecrets: readSecrets,
              dataset: dataset,
              expectedMounted: true,
              expectedKeyLoaded: true,
            );
            if (currentDataset == null && context.mounted) {
              showStatusSnack(
                '`${dataset.name}` is no longer in a lockable state.',
                isError: true,
              );
            }
            return currentDataset != null;
          },
        ),
      );

      final lockedDataset = currentDataset;
      if (shouldLock != true || lockedDataset == null) {
        return;
      }

      await withBusy(() async {
        final result = await lockUnlockHelper.lockDataset(
          profile: profile,
          readSecrets: readSecrets,
          dataset: lockedDataset,
        );
        datasets.value = result.datasets;
        showStatusSnack(result.statusMessage);
      });
    }

    Future<void> unlockDataset(ZfsDataset dataset) async {
      ZfsDataset? currentDataset;

      final allowedMethod = lockUnlockHelper.resolveUnlockMethod(dataset);
      if (allowedMethod == null) {
        showStatusSnack(
          'Unable to determine unlock key type for `${dataset.name}`.',
          isError: true,
        );
        return;
      }

      final initialServerKeyFilePath = allowedMethod == UnlockMethod.keyFile
          ? lockUnlockHelper.initialServerKeyFilePath(dataset)
          : null;

      final request = await showDialog<UnlockRequest>(
        context: context,
        builder: (context) => UnlockDialog(
          allowedMethod: allowedMethod,
          initialServerKeyFilePath: initialServerKeyFilePath,
          onSubmitValidation: () async {
            currentDataset = await lockUnlockHelper.refreshAndValidateDatasetState(
              profile: profile,
              readSecrets: readSecrets,
              dataset: dataset,
              expectedMounted: false,
              expectedKeyLoaded: false,
            );
            if (currentDataset == null && context.mounted) {
              showStatusSnack(
                '`${dataset.name}` is no longer in an unlockable state.',
                isError: true,
              );
            }
            return currentDataset != null;
          },
          serverPathSuggestions: (query) async {
            final secrets = await readSecrets();
            return zfsService.suggestServerKeyFilePaths(
              profile: profile,
              secrets: secrets,
              partialPath: query,
            );
          },
        ),
      );
      if (request == null) {
        return;
      }
      if (currentDataset == null) {
        showStatusSnack(
          'Could not verify current dataset state. Try again.',
          isError: true,
        );
        return;
      }
      await withBusy(() async {
        final result = await lockUnlockHelper.unlockDataset(
          profile: profile,
          readSecrets: readSecrets,
          dataset: currentDataset!,
          request: request,
        );
        datasets.value = result.datasets;
        showStatusSnack(result.statusMessage);
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
        builder: (context) => CreateDatasetDialog(
          parentDatasets: parentDatasets,
          serverPathSuggestions: (query) async {
            final secrets = await readSecrets();
            return zfsService.suggestServerKeyFilePaths(
              profile: profile,
              secrets: secrets,
              partialPath: query,
            );
          },
        ),
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

    Future<void> deleteDataset(ZfsDataset dataset) async {
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => DeleteDatasetDialog(datasetName: dataset.name),
      );
      if (shouldProceed != true) {
        return;
      }

      await withBusy(() async {
        final secrets = await readSecrets();
        await zfsService.deleteDataset(
          profile: profile,
          secrets: secrets,
          datasetName: dataset.name,
        );
        datasets.value = await fetchDatasets();
        showStatusSnack('Deleted `${dataset.name}`.');
      });
    }

    useEffect(() {
      Future<void>.microtask(refreshDatasets);
      return null;
    }, const []);

    useEffect(() {
      selectedSortField.value = loadDatasetSortField(profileId: profile.id);
      sortDirection.value = loadDatasetSortDirection(profileId: profile.id);
      return null;
    }, [datasetSortKey]);

    final filteredDatasets = datasets.value
        .where((dataset) => visibleDatasetTypes.value.contains(dataset.type))
        .toList();
    filteredDatasets.sort(
      (a, b) => compareDatasets(
        a,
        b,
        selectedSortField.value,
        direction: sortDirection.value,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile.name),
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
          DatasetSortButton(
            selectedSortField: selectedSortField.value,
            onSortChanged: (field) {
              selectedSortField.value = field;
              unawaited(
                persistDatasetSortSettings(
                  profileId: profile.id,
                  field: field,
                  direction: sortDirection.value,
                ),
              );
            },
          ),
          DatasetSortDirectionButton(
            direction: sortDirection.value,
            onDirectionChanged: (direction) {
              sortDirection.value = direction;
              unawaited(
                persistDatasetSortSettings(
                  profileId: profile.id,
                  field: selectedSortField.value,
                  direction: direction,
                ),
              );
            },
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
                    itemCount: filteredDatasets.isEmpty
                        ? 2
                        : filteredDatasets.length + 1,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _DatasetTypeFilterChips(
                          profileId: profile.id,
                          onSelectionChanged: (selectedTypes) {
                            visibleDatasetTypes.value = selectedTypes;
                          },
                        );
                      }
                      if (filteredDatasets.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.filter_alt_off_outlined, size: 44),
                              SizedBox(height: 12),
                              Text(
                                'No datasets match the selected type filters.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      final dataset = filteredDatasets[index - 1];
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
                      final keyStatusLabel = _formatEnumName(
                        dataset.keyStatus.name,
                      );
                      final hasKeyLocationConfigured =
                          dataset.keyLocation.trim().toLowerCase() != 'none';
                      final actionButton = !dataset.isEncrypted
                          ? const SizedBox.shrink()
                          : !hasKeyLocationConfigured
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
                      final canDeleteDataset =
                          dataset.usedByDataset.trim().toUpperCase() == '234K';

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
                                        Text('Key: $keyStatusLabel'),
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
                              if (dataset.isEncrypted || canDeleteDataset) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (canDeleteDataset)
                                      FilledButton.tonalIcon(
                                        onPressed: loading.value
                                            ? null
                                            : () => deleteDataset(dataset),
                                        icon: const Icon(Icons.delete_outline),
                                        label: const Text('Delete'),
                                      ),
                                    if (dataset.isEncrypted) ...[
                                      if (canDeleteDataset)
                                        const SizedBox(width: 8),
                                      actionButton,
                                    ],
                                  ],
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

class _DatasetTypeFilterChips extends HookWidget {
  const _DatasetTypeFilterChips({
    required this.profileId,
    required this.onSelectionChanged,
  });

  final String profileId;
  final void Function(Set<ZfsDatasetType> selectedTypes) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final selectedTypes = useState<Set<ZfsDatasetType>>({
      ZfsDatasetType.filesystem,
    });
    final uiPreferencesBox = Hive.box<List<dynamic>>(uiPreferencesBoxName);
    final datasetTypeFilterKey = 'dataset_type_filter_$profileId';

    Set<ZfsDatasetType> decodeSelectedTypes(List<dynamic>? encoded) {
      final decoded = <ZfsDatasetType>{};
      if (encoded != null) {
        for (final raw in encoded) {
          if (raw is! String) {
            continue;
          }
          for (final candidate in ZfsDatasetType.values) {
            if (candidate.name == raw) {
              decoded.add(candidate);
              break;
            }
          }
        }
      }
      if (decoded.isEmpty) {
        decoded.add(ZfsDatasetType.filesystem);
      }
      return decoded;
    }

    void persistSelectedTypes(Set<ZfsDatasetType> types) {
      final encoded = types.map((type) => type.name).toList()..sort();
      unawaited(uiPreferencesBox.put(datasetTypeFilterKey, encoded));
    }

    void notifyParentSelectionChanged(
      Set<ZfsDatasetType> types, {
      bool postFrame = false,
    }) {
      if (!postFrame) {
        onSelectionChanged(types);
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onSelectionChanged(types);
      });
    }

    void updateTypeSelection(ZfsDatasetType type, bool shouldSelect) {
      final next = <ZfsDatasetType>{...selectedTypes.value};
      if (shouldSelect) {
        next.add(type);
      } else {
        next.remove(type);
      }
      if (next.isEmpty) {
        next.add(ZfsDatasetType.filesystem);
      }
      selectedTypes.value = next;
      notifyParentSelectionChanged(next);
      persistSelectedTypes(next);
    }

    useEffect(() {
      final decoded = decodeSelectedTypes(uiPreferencesBox.get(datasetTypeFilterKey));
      selectedTypes.value = decoded;
      notifyParentSelectionChanged(decoded, postFrame: true);
      return null;
    }, [datasetTypeFilterKey]);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in ZfsDatasetType.values.where(
              (type) => type != ZfsDatasetType.unknown,
            ))
              FilterChip(
                label: Text(_formatEnumName(type.name)),
                selected: selectedTypes.value.contains(type),
                onSelected: (selected) => updateTypeSelection(type, selected),
              ),
          ],
        ),
      ),
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
