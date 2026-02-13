// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_detail_ui_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServerDetailUiStateNotifier)
final serverDetailUiStateProvider = ServerDetailUiStateNotifierFamily._();

final class ServerDetailUiStateNotifierProvider
    extends
        $NotifierProvider<ServerDetailUiStateNotifier, ServerDetailUiState> {
  ServerDetailUiStateNotifierProvider._({
    required ServerDetailUiStateNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'serverDetailUiStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serverDetailUiStateNotifierHash();

  @override
  String toString() {
    return r'serverDetailUiStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ServerDetailUiStateNotifier create() => ServerDetailUiStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerDetailUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerDetailUiState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ServerDetailUiStateNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serverDetailUiStateNotifierHash() =>
    r'a2ce7047b428c4453f7c59018ad8ed5bf3e6af3b';

final class ServerDetailUiStateNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ServerDetailUiStateNotifier,
          ServerDetailUiState,
          ServerDetailUiState,
          ServerDetailUiState,
          String
        > {
  ServerDetailUiStateNotifierFamily._()
    : super(
        retry: null,
        name: r'serverDetailUiStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ServerDetailUiStateNotifierProvider call(String profileId) =>
      ServerDetailUiStateNotifierProvider._(argument: profileId, from: this);

  @override
  String toString() => r'serverDetailUiStateProvider';
}

abstract class _$ServerDetailUiStateNotifier
    extends $Notifier<ServerDetailUiState> {
  late final _$args = ref.$arg as String;
  String get profileId => _$args;

  ServerDetailUiState build(String profileId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ServerDetailUiState, ServerDetailUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ServerDetailUiState, ServerDetailUiState>,
              ServerDetailUiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
