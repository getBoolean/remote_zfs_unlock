import 'package:dart_mappable/dart_mappable.dart';

part 'zfs_dataset.mapper.dart';

@MappableEnum()
enum ZfsDatasetType { filesystem, volume, snapshot, bookmark, unknown }

@MappableEnum()
enum ZfsEncryptionType {
  @MappableValue('on')
  on,
  @MappableValue('off')
  off,
  @MappableValue('aes-128-ccm')
  aes128Ccm,
  @MappableValue('aes-192-ccm')
  aes192Ccm,
  @MappableValue('aes-256-ccm')
  aes256Ccm,
  @MappableValue('aes-128-gcm')
  aes128Gcm,
  @MappableValue('aes-192-gcm')
  aes192Gcm,
  @MappableValue('aes-256-gcm')
  aes256Gcm,
  @MappableValue('unknown')
  unknown,
}

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

@MappableEnum()
enum ZfsKeyStatusType {
  @MappableValue('none')
  none,
  @MappableValue('unavailable')
  unavailable,
  @MappableValue('available')
  available,
  @MappableValue('unknown')
  unknown,
}

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
  final ZfsEncryptionType encryption;
  final ZfsKeyStatusType keyStatus;
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
    switch (encryption) {
      case ZfsEncryptionType.off:
        return false;
      case ZfsEncryptionType.on:
      case ZfsEncryptionType.aes128Ccm:
      case ZfsEncryptionType.aes192Ccm:
      case ZfsEncryptionType.aes256Ccm:
      case ZfsEncryptionType.aes128Gcm:
      case ZfsEncryptionType.aes192Gcm:
      case ZfsEncryptionType.aes256Gcm:
        return true;
      case ZfsEncryptionType.unknown:
        return false;
    }
  }

  bool get isKeyLoaded => keyStatus == ZfsKeyStatusType.available;
}
