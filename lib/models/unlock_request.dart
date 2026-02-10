import 'dart:typed_data';

import 'package:dart_mappable/dart_mappable.dart';

part 'unlock_request.mapper.dart';

@MappableEnum()
enum UnlockMethod {
  @MappableValue('passphrase')
  passphrase,
  @MappableValue('keyFile')
  keyFile,
}

@MappableClass()
class UnlockRequest with UnlockRequestMappable {
  const UnlockRequest.passphrase(this.passphrase)
    : method = UnlockMethod.passphrase,
      keyFileBytes = null;

  const UnlockRequest.keyFile(this.keyFileBytes)
    : method = UnlockMethod.keyFile,
      passphrase = null;

  final UnlockMethod method;
  final String? passphrase;
  final Uint8List? keyFileBytes;
}
