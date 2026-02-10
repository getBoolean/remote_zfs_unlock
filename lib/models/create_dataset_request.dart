import 'dart:typed_data';

enum CreateDatasetEncryptionType {
  off,
  on,
  aes128Ccm,
  aes192Ccm,
  aes256Ccm,
  aes128Gcm,
  aes192Gcm,
  aes256Gcm,
}

extension CreateDatasetEncryptionTypeValue on CreateDatasetEncryptionType? {
  String get zfsValue {
    switch (this) {
      case null:
      case CreateDatasetEncryptionType.on:
        return 'on';
      case CreateDatasetEncryptionType.off:
        return 'off';
      case CreateDatasetEncryptionType.aes128Ccm:
        return 'aes-128-ccm';
      case CreateDatasetEncryptionType.aes192Ccm:
        return 'aes-192-ccm';
      case CreateDatasetEncryptionType.aes256Ccm:
        return 'aes-256-ccm';
      case CreateDatasetEncryptionType.aes128Gcm:
        return 'aes-128-gcm';
      case CreateDatasetEncryptionType.aes192Gcm:
        return 'aes-192-gcm';
      case CreateDatasetEncryptionType.aes256Gcm:
        return 'aes-256-gcm';
    }
  }
}

class CreateDatasetRequest {
  const CreateDatasetRequest({
    required this.parentDataset,
    required this.datasetName,
    required this.encrypted,
    this.passphrase,
    this.keyFileBytes,
    this.keyFileEncryptionType,
  });

  final String parentDataset;
  final String datasetName;
  final bool encrypted;
  final String? passphrase;
  final Uint8List? keyFileBytes;
  final CreateDatasetEncryptionType? keyFileEncryptionType;
}
