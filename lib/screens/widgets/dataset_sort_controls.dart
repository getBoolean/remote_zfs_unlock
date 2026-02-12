import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:remote_zfs_unlock/models/zfs_dataset.dart';
import 'package:remote_zfs_unlock/providers/app_providers.dart';

enum DatasetSortField {
  datasetName('Name'),
  encrypted('Encrypted'),
  mounted('Mounted'),
  used('Used'),
  available('Available'),
  mountpoint('Mountpoint');

  const DatasetSortField(this.label);

  final String label;

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
    return PopupMenuButton<DatasetSortField>(
      tooltip: 'Sort datasets',
      icon: const Icon(Icons.sort),
      initialValue: selectedSortField,
      onSelected: (DatasetSortField field) {
        onSortChanged(field);
      },
      itemBuilder: (context) => [
        for (final field in DatasetSortField.values)
          PopupMenuItem<DatasetSortField>(
            value: field,
            child: Text(field.label),
          ),
      ],
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

DatasetSortField loadDatasetSortField({required String profileId}) {
  final uiPreferencesBox = Hive.box<List<dynamic>>(uiPreferencesBoxName);
  final datasetSortKey = 'dataset_sort_$profileId';
  return decodeDatasetSortField(uiPreferencesBox.get(datasetSortKey));
}

Future<void> persistDatasetSortField({
  required String profileId,
  required DatasetSortField field,
}) {
  final uiPreferencesBox = Hive.box<List<dynamic>>(uiPreferencesBoxName);
  final datasetSortKey = 'dataset_sort_$profileId';
  return uiPreferencesBox.put(datasetSortKey, <String>[field.storageValue]);
}

int compareDatasets(ZfsDataset a, ZfsDataset b, DatasetSortField sortField) {
  if (sortField == DatasetSortField.datasetName) {
    return _compareNameCaseInsensitive(a.name, b.name);
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
    return byChosenField;
  }
  return _compareNameCaseInsensitive(a.name, b.name);
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
