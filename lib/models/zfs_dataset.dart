import 'package:dart_mappable/dart_mappable.dart';

part 'zfs_dataset.mapper.dart';

@MappableEnum()
enum ZfsDatasetType { filesystem, volume, snapshot, bookmark, unknown }

@MappableEnum()
enum ZfsDedupType {
  on,
  off,
  verify,
  sha256,
  sha256Verify,
  sha512,
  sha512Verify,
  skein,
  skeinVerify,
  edonrVerify,
  blake3,
  blake3Verify,
  unknown,
}

@MappableEnum()
enum ZfsCompressionType {
  on,
  off,
  lzjb,
  gzip,
  zle,
  lz4,
  zstd,
  zstdFast,
  unknown,
}

@MappableEnum()
enum ZfsKeyFormatType { none, raw, hex, passphrase, unknown }

@MappableClass()
class ZfsDataset with ZfsDatasetMappable {
  const ZfsDataset({
    required this.name,
    required this.encryption,
    required this.keyStatus,
    required this.mounted,
    required this.usedByDataset,
    required this.available,
    required this.type,
    required this.dedup,
    required this.compression,
    required this.keyFormat,
    required this.keyLocation,
    required this.mountPoint,
  });

  final String name;
  final String encryption;
  final String keyStatus;
  final String mounted;
  final String usedByDataset;
  final String available;
  final ZfsDatasetType type;
  final ZfsDedupType dedup;
  final ZfsCompressionType compression;
  final ZfsKeyFormatType keyFormat;
  final String keyLocation;
  final String mountPoint;

  bool get isEncrypted {
    final value = encryption.toLowerCase().trim();
    return value.isNotEmpty && value != '-' && value != 'off';
  }

  bool get isKeyLoaded => keyStatus.toLowerCase().trim() == 'available';
}
