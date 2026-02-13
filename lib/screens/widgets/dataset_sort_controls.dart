import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:remote_zfs_unlock/models/zfs_dataset.dart';
import 'package:remote_zfs_unlock/providers/app_providers.dart';

const _dropdownMenuColor = Color.fromARGB(255, 17, 35, 58);
const _dropdownTextStyle = TextStyle(
  color: Color(0xFFEAF5FF),
  fontWeight: FontWeight.w600,
  letterSpacing: 0.2,
);

enum DatasetSortField {
  datasetName('Name', Icons.label_outlined),
  encrypted('Encrypted', Icons.shield_moon_outlined),
  mounted('Mounted', Icons.folder_open_outlined),
  used('Used', Icons.data_usage_outlined),
  available('Available', Icons.storage_outlined),
  mountpoint('Mountpoint', Icons.folder_open_outlined);

  const DatasetSortField(this.label, this.icon);

  final String label;
  final IconData icon;

  String get storageValue => name;
}

enum DatasetSortDirection {
  ascending('Ascending', Icons.arrow_upward),
  descending('Descending', Icons.arrow_downward);

  const DatasetSortDirection(this.label, this.icon);

  final String label;
  final IconData icon;

  String get storageValue => name;
}

class DatasetSortButton extends StatelessWidget {
  const DatasetSortButton({
    required this.selectedSortField,
    required this.onSortChanged,
    super.key,
  });

  final DatasetSortField selectedSortField;
  final void Function(DatasetSortField field) onSortChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<DatasetSortField>(
      tooltip: 'Sort datasets',
      icon: Icon(Icons.sort, color: scheme.primary),
      initialValue: selectedSortField,
      color: _dropdownMenuColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      menuPadding: const EdgeInsets.symmetric(vertical: 4),
      onSelected: (DatasetSortField field) {
        onSortChanged(field);
      },
      itemBuilder: (context) => [
        for (final field in DatasetSortField.values)
          PopupMenuItem<DatasetSortField>(
            value: field,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(field.icon, size: 18, color: _dropdownTextStyle.color),
                const SizedBox(width: 10),
                Text(field.label, style: _dropdownTextStyle),
              ],
            ),
          ),
      ],
    );
  }
}

class DatasetSortDirectionButton extends StatelessWidget {
  const DatasetSortDirectionButton({
    required this.direction,
    required this.onDirectionChanged,
    super.key,
  });

  final DatasetSortDirection direction;
  final void Function(DatasetSortDirection direction) onDirectionChanged;

  @override
  Widget build(BuildContext context) {
    final nextDirection = direction == DatasetSortDirection.ascending
        ? DatasetSortDirection.descending
        : DatasetSortDirection.ascending;
    return IconButton(
      tooltip: 'Sort ${direction.label.toLowerCase()}',
      onPressed: () {
        onDirectionChanged(nextDirection);
      },
      icon: Icon(direction.icon),
    );
  }
}

DatasetSortField decodeDatasetSortField(List<dynamic>? encoded) {
  final rawValue = encoded == null || encoded.isEmpty ? null : encoded.first;
  if (rawValue is! String) {
    return DatasetSortField.datasetName;
  }
  for (final candidate in DatasetSortField.values) {
    if (candidate.storageValue == rawValue || candidate.name == rawValue) {
      return candidate;
    }
  }
  return DatasetSortField.datasetName;
}

DatasetSortDirection decodeDatasetSortDirection(List<dynamic>? encoded) {
  if (encoded == null || encoded.length < 2) {
    return DatasetSortDirection.ascending;
  }
  final rawValue = encoded[1];
  if (rawValue is! String) {
    return DatasetSortDirection.ascending;
  }
  for (final candidate in DatasetSortDirection.values) {
    if (candidate.storageValue == rawValue || candidate.name == rawValue) {
      return candidate;
    }
  }
  return DatasetSortDirection.ascending;
}

DatasetSortField loadDatasetSortField({required String profileId}) {
  final uiPreferencesBox = Hive.box<List<dynamic>>(uiPreferencesBoxName);
  final datasetSortKey = 'dataset_sort_$profileId';
  return decodeDatasetSortField(uiPreferencesBox.get(datasetSortKey));
}

DatasetSortDirection loadDatasetSortDirection({required String profileId}) {
  final uiPreferencesBox = Hive.box<List<dynamic>>(uiPreferencesBoxName);
  final datasetSortKey = 'dataset_sort_$profileId';
  return decodeDatasetSortDirection(uiPreferencesBox.get(datasetSortKey));
}

Future<void> persistDatasetSortField({
  required String profileId,
  required DatasetSortField field,
}) {
  final currentDirection = loadDatasetSortDirection(profileId: profileId);
  return persistDatasetSortSettings(
    profileId: profileId,
    field: field,
    direction: currentDirection,
  );
}

Future<void> persistDatasetSortDirection({
  required String profileId,
  required DatasetSortDirection direction,
}) {
  final currentField = loadDatasetSortField(profileId: profileId);
  return persistDatasetSortSettings(
    profileId: profileId,
    field: currentField,
    direction: direction,
  );
}

Future<void> persistDatasetSortSettings({
  required String profileId,
  required DatasetSortField field,
  required DatasetSortDirection direction,
}) {
  final uiPreferencesBox = Hive.box<List<dynamic>>(uiPreferencesBoxName);
  final datasetSortKey = 'dataset_sort_$profileId';
  return uiPreferencesBox.put(datasetSortKey, <String>[
    field.storageValue,
    direction.storageValue,
  ]);
}

int compareDatasets(
  ZfsDataset a,
  ZfsDataset b,
  DatasetSortField sortField, {
  DatasetSortDirection direction = DatasetSortDirection.ascending,
}) {
  if (sortField == DatasetSortField.datasetName) {
    final byName = _compareNameCaseInsensitive(a.name, b.name);
    return direction == DatasetSortDirection.ascending ? byName : -byName;
  }

  final byChosenField = switch (sortField) {
    DatasetSortField.datasetName => 0,
    DatasetSortField.encrypted => _compareBoolTrueFirst(
      a.isEncrypted,
      b.isEncrypted,
    ),
    DatasetSortField.mounted => _compareBoolTrueFirst(
      _isMountedDataset(a),
      _isMountedDataset(b),
    ),
    DatasetSortField.used => _compareSizeStringsDescending(
      a.usedByDataset,
      b.usedByDataset,
    ),
    DatasetSortField.available => _compareSizeStringsDescending(
      a.available,
      b.available,
    ),
    DatasetSortField.mountpoint => a.mountPoint.compareTo(b.mountPoint),
  };

  if (byChosenField != 0) {
    return direction == DatasetSortDirection.ascending
        ? byChosenField
        : -byChosenField;
  }
  final byName = _compareNameCaseInsensitive(a.name, b.name);
  return direction == DatasetSortDirection.ascending ? byName : -byName;
}

bool _isMountedDataset(ZfsDataset dataset) =>
    dataset.mounted.toLowerCase().trim() == 'yes';

int _compareBoolTrueFirst(bool a, bool b) {
  if (a == b) {
    return 0;
  }
  return a ? -1 : 1;
}

int _compareSizeStringsDescending(String a, String b) {
  final parsedA = _parseDatasetSize(a);
  final parsedB = _parseDatasetSize(b);
  if (parsedA == null && parsedB == null) {
    return 0;
  }
  if (parsedA == null) {
    return 1;
  }
  if (parsedB == null) {
    return -1;
  }
  return parsedB.compareTo(parsedA);
}

double? _parseDatasetSize(String raw) {
  final normalized = raw.trim();
  if (normalized.isEmpty || normalized == '-') {
    return null;
  }
  final match = RegExp(
    r'^([0-9]+(?:\.[0-9]+)?)\s*([KMGTPEZYkmgtpezy]?)\s*(?:i?B)?$',
  ).firstMatch(normalized);
  if (match == null) {
    return null;
  }
  final value = double.tryParse(match.group(1)!);
  if (value == null) {
    return null;
  }
  final unit = (match.group(2) ?? '').toUpperCase();
  final exponent = switch (unit) {
    '' => 0,
    'K' => 1,
    'M' => 2,
    'G' => 3,
    'T' => 4,
    'P' => 5,
    'E' => 6,
    'Z' => 7,
    'Y' => 8,
    _ => 0,
  };

  var multiplier = 1.0;
  for (var i = 0; i < exponent; i++) {
    multiplier *= 1024;
  }
  return value * multiplier;
}

int _compareNameCaseInsensitive(String a, String b) {
  final lowerCaseComparison = a.toLowerCase().compareTo(b.toLowerCase());
  if (lowerCaseComparison != 0) {
    return lowerCaseComparison;
  }
  return a.compareTo(b);
}
