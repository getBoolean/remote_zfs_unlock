import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:remote_zfs_unlock/models/zfs_dataset.dart';
import 'package:remote_zfs_unlock/screens/widgets/dataset_sort_controls.dart';
import 'package:hive_ce/hive.dart';
import 'package:remote_zfs_unlock/providers/app_providers.dart';

part 'server_detail_ui_state_provider.g.dart';

class ServerDetailUiState {
  const ServerDetailUiState({
    required this.loading,
    required this.datasets,
    required this.visibleDatasetTypes,
    required this.selectedSortField,
    required this.sortDirection,
  });

  factory ServerDetailUiState.initial({required String profileId}) {
    final uiPreferencesBox = Hive.box<List<dynamic>>(uiPreferencesBoxName);
    final datasetTypeFilterKey = 'dataset_type_filter_$profileId';

    final visibleTypes = _decodeSelectedTypes(
      uiPreferencesBox.get(datasetTypeFilterKey),
    );

    return ServerDetailUiState(
      loading: false,
      datasets: const <ZfsDataset>[],
      visibleDatasetTypes: visibleTypes,
      selectedSortField: loadDatasetSortField(profileId: profileId),
      sortDirection: loadDatasetSortDirection(profileId: profileId),
    );
  }

  final bool loading;
  final List<ZfsDataset> datasets;
  final Set<ZfsDatasetType> visibleDatasetTypes;
  final DatasetSortField selectedSortField;
  final DatasetSortDirection sortDirection;

  List<ZfsDataset> get filteredDatasets {
    final filtered = datasets
        .where((dataset) => visibleDatasetTypes.contains(dataset.type))
        .toList();
    filtered.sort(
      (a, b) =>
          compareDatasets(a, b, selectedSortField, direction: sortDirection),
    );
    return filtered;
  }

  ServerDetailUiState copyWith({
    bool? loading,
    List<ZfsDataset>? datasets,
    Set<ZfsDatasetType>? visibleDatasetTypes,
    DatasetSortField? selectedSortField,
    DatasetSortDirection? sortDirection,
  }) {
    return ServerDetailUiState(
      loading: loading ?? this.loading,
      datasets: datasets ?? this.datasets,
      visibleDatasetTypes: visibleDatasetTypes ?? this.visibleDatasetTypes,
      selectedSortField: selectedSortField ?? this.selectedSortField,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

Set<ZfsDatasetType> _decodeSelectedTypes(List<dynamic>? encoded) {
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

@riverpod
class ServerDetailUiStateNotifier extends _$ServerDetailUiStateNotifier {
  static const _operationTimeout = Duration(seconds: 10);

  @override
  ServerDetailUiState build(String profileId) {
    return ServerDetailUiState.initial(profileId: profileId);
  }

  Future<void> runBusy(Future<void> Function() action) async {
    state = state.copyWith(loading: true);
    try {
      await action().timeout(_operationTimeout);
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('runBusy: Action timed out after ${_operationTimeout.inSeconds} seconds');
      }
      // Loading state will still be set to false in the finally block
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  void setDatasets(List<ZfsDataset> datasets) {
    state = state.copyWith(datasets: List<ZfsDataset>.unmodifiable(datasets));
  }

  void setVisibleDatasetTypes(Set<ZfsDatasetType> selectedTypes) {
    final next = selectedTypes.isEmpty
        ? <ZfsDatasetType>{ZfsDatasetType.filesystem}
        : <ZfsDatasetType>{...selectedTypes};
    state = state.copyWith(visibleDatasetTypes: next);
    _persistSelectedTypes(profileId: profileId, types: next);
  }

  Future<void> waitForIdle() async {
    if (!state.loading) {
      return;
    }
    final completer = Completer<void>();
    
    final removeListener = listenSelf((previous, next) {
      if (previous?.loading == true &&
          !next.loading &&
          !completer.isCompleted) {
        completer.complete();
      }
    });
    try {
      await completer.future.timeout(_operationTimeout);
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('waitForIdle: Timeout after ${_operationTimeout.inSeconds} seconds - loading state did not change to false');
      }
      // This is expected behavior to prevent indefinite hanging
    } finally {
      removeListener();
    }
  }

  ZfsDataset? findDatasetByNameAndKeyLoaded({
    required String datasetName,
    required bool expectedKeyLoaded,
  }) {
    for (final candidate in state.datasets) {
      if (candidate.name == datasetName &&
          candidate.isKeyLoaded == expectedKeyLoaded) {
        return candidate;
      }
    }
    return null;
  }

  Future<void> setSortField(DatasetSortField field) async {
    state = state.copyWith(selectedSortField: field);
    await persistDatasetSortSettings(
      profileId: profileId,
      field: field,
      direction: state.sortDirection,
    );
  }

  Future<void> setSortDirection(DatasetSortDirection direction) async {
    state = state.copyWith(sortDirection: direction);
    await persistDatasetSortSettings(
      profileId: profileId,
      field: state.selectedSortField,
      direction: direction,
    );
  }

  void _persistSelectedTypes({
    required String profileId,
    required Set<ZfsDatasetType> types,
  }) {
    final uiPreferencesBox = Hive.box<List<dynamic>>(uiPreferencesBoxName);
    final datasetTypeFilterKey = 'dataset_type_filter_$profileId';
    final encoded = types.map((type) => type.name).toList()..sort();
    unawaited(uiPreferencesBox.put(datasetTypeFilterKey, encoded));
  }
}
