// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminNotifierHash() => r'8e6f79c859d8e9735a3bf4dc507bf287220267d4';

/// See also [AdminNotifier].
@ProviderFor(AdminNotifier)
final adminNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AdminNotifier, List<AdminModel>>.internal(
  AdminNotifier.new,
  name: r'adminNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AdminNotifier = AutoDisposeAsyncNotifier<List<AdminModel>>;
String _$adminFormNotifierHash() => r'31182aab386a6b26a8a4c111e32dcbe8af0886ee';

/// See also [AdminFormNotifier].
@ProviderFor(AdminFormNotifier)
final adminFormNotifierProvider =
    AutoDisposeNotifierProvider<AdminFormNotifier, AsyncValue<void>>.internal(
  AdminFormNotifier.new,
  name: r'adminFormNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminFormNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AdminFormNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
