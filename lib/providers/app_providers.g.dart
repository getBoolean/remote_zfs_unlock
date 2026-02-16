// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(serverProfilesBox)
final serverProfilesBoxProvider = ServerProfilesBoxProvider._();

final class ServerProfilesBoxProvider
    extends
        $FunctionalProvider<
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>
        >
    with $Provider<Box<Map<dynamic, dynamic>>> {
  ServerProfilesBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverProfilesBoxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverProfilesBoxHash();

  @$internal
  @override
  $ProviderElement<Box<Map<dynamic, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Box<Map<dynamic, dynamic>> create(Ref ref) {
    return serverProfilesBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<Map<dynamic, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<Map<dynamic, dynamic>>>(value),
    );
  }
}

String _$serverProfilesBoxHash() => r'ef02642248991afde7e8fb1a897b6f926c47bb53';

@ProviderFor(flutterSecureStorage)
final flutterSecureStorageProvider = FlutterSecureStorageProvider._();

final class FlutterSecureStorageProvider
    extends
        $FunctionalProvider<
          FlutterSecureStorage,
          FlutterSecureStorage,
          FlutterSecureStorage
        >
    with $Provider<FlutterSecureStorage> {
  FlutterSecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flutterSecureStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flutterSecureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return flutterSecureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$flutterSecureStorageHash() =>
    r'f97cebdb66b3b308d6e0361de8bf70dc62753579';

@ProviderFor(secureStorageService)
final secureStorageServiceProvider = SecureStorageServiceProvider._();

final class SecureStorageServiceProvider
    extends
        $FunctionalProvider<
          SecureStorageService,
          SecureStorageService,
          SecureStorageService
        >
    with $Provider<SecureStorageService> {
  SecureStorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageServiceHash();

  @$internal
  @override
  $ProviderElement<SecureStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SecureStorageService create(Ref ref) {
    return secureStorageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureStorageService>(value),
    );
  }
}

String _$secureStorageServiceHash() =>
    r'e6048c625f6ebd04addd3953abbed782094bd510';

@ProviderFor(serverRepository)
final serverRepositoryProvider = ServerRepositoryProvider._();

final class ServerRepositoryProvider
    extends
        $FunctionalProvider<
          ServerRepository,
          ServerRepository,
          ServerRepository
        >
    with $Provider<ServerRepository> {
  ServerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServerRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ServerRepository create(Ref ref) {
    return serverRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerRepository>(value),
    );
  }
}

String _$serverRepositoryHash() => r'0d75598d848de9369473a534e890e551784de1f1';

@ProviderFor(wolService)
final wolServiceProvider = WolServiceProvider._();

final class WolServiceProvider
    extends $FunctionalProvider<WolService, WolService, WolService>
    with $Provider<WolService> {
  WolServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wolServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wolServiceHash();

  @$internal
  @override
  $ProviderElement<WolService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WolService create(Ref ref) {
    return wolService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WolService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WolService>(value),
    );
  }
}

String _$wolServiceHash() => r'2456f3449d0288e564da556a7b2b296f65fb9bda';

@ProviderFor(sshService)
final sshServiceProvider = SshServiceProvider._();

final class SshServiceProvider
    extends $FunctionalProvider<SshService, SshService, SshService>
    with $Provider<SshService> {
  SshServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sshServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sshServiceHash();

  @$internal
  @override
  $ProviderElement<SshService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SshService create(Ref ref) {
    return sshService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SshService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SshService>(value),
    );
  }
}

String _$sshServiceHash() => r'dbbfbdce2b76c7d000bec8b7a4b8d885b80c1cc8';

@ProviderFor(zfsService)
final zfsServiceProvider = ZfsServiceProvider._();

final class ZfsServiceProvider
    extends $FunctionalProvider<ZfsService, ZfsService, ZfsService>
    with $Provider<ZfsService> {
  ZfsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'zfsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$zfsServiceHash();

  @$internal
  @override
  $ProviderElement<ZfsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ZfsService create(Ref ref) {
    return zfsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ZfsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ZfsService>(value),
    );
  }
}

String _$zfsServiceHash() => r'1d7c2dcb919a47079d1a0cc6c6a325a1a01ea131';

@ProviderFor(serverReachable)
final serverReachableProvider = ServerReachableFamily._();

final class ServerReachableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  ServerReachableProvider._({
    required ServerReachableFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'serverReachableProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serverReachableHash();

  @override
  String toString() {
    return r'serverReachableProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as (String, int);
    return serverReachable(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ServerReachableProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverReachableHash() => r'8f3aa4fd6d08da24b7eb4567c077bbbabba74337';

final class ServerReachableFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, (String, int)> {
  ServerReachableFamily._()
    : super(
        retry: null,
        name: r'serverReachableProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ServerReachableProvider call(String host, int port) =>
      ServerReachableProvider._(argument: (host, port), from: this);

  @override
  String toString() => r'serverReachableProvider';
}

@ProviderFor(ServerList)
final serverListProvider = ServerListProvider._();

final class ServerListProvider
    extends $AsyncNotifierProvider<ServerList, List<ServerProfile>> {
  ServerListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverListHash();

  @$internal
  @override
  ServerList create() => ServerList();
}

String _$serverListHash() => r'74cca9b28f5aa122146d08c19a6723485c5e05d1';

abstract class _$ServerList extends $AsyncNotifier<List<ServerProfile>> {
  FutureOr<List<ServerProfile>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ServerProfile>>, List<ServerProfile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ServerProfile>>, List<ServerProfile>>,
              AsyncValue<List<ServerProfile>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
