import 'package:dart_mappable/dart_mappable.dart';

part 'zfs_dataset.mapper.dart';

@MappableClass()
class ZfsDataset with ZfsDatasetMappable {
  const ZfsDataset({
    required this.name,
    required this.encryption,
    required this.keyStatus,
    required this.mounted,
  });

  final String name;
  final String encryption;
  final String keyStatus;
  final String mounted;

  bool get isEncrypted {
    final value = encryption.toLowerCase().trim();
    return value.isNotEmpty && value != '-' && value != 'off';
  }

  bool get isKeyLoaded => keyStatus.toLowerCase().trim() == 'available';
}
