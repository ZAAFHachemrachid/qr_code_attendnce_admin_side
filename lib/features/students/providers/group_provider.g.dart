// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupStudentsHash() => r'faeabd561d33ce22ac74d4e763ac76f4a70f112e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [groupStudents].
@ProviderFor(groupStudents)
const groupStudentsProvider = GroupStudentsFamily();

/// See also [groupStudents].
class GroupStudentsFamily extends Family<AsyncValue<List<StudentModel>>> {
  /// See also [groupStudents].
  const GroupStudentsFamily();

  /// See also [groupStudents].
  GroupStudentsProvider call(
    String groupId,
  ) {
    return GroupStudentsProvider(
      groupId,
    );
  }

  @override
  GroupStudentsProvider getProviderOverride(
    covariant GroupStudentsProvider provider,
  ) {
    return call(
      provider.groupId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupStudentsProvider';
}

/// See also [groupStudents].
class GroupStudentsProvider
    extends AutoDisposeFutureProvider<List<StudentModel>> {
  /// See also [groupStudents].
  GroupStudentsProvider(
    String groupId,
  ) : this._internal(
          (ref) => groupStudents(
            ref as GroupStudentsRef,
            groupId,
          ),
          from: groupStudentsProvider,
          name: r'groupStudentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupStudentsHash,
          dependencies: GroupStudentsFamily._dependencies,
          allTransitiveDependencies:
              GroupStudentsFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  GroupStudentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    FutureOr<List<StudentModel>> Function(GroupStudentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupStudentsProvider._internal(
        (ref) => create(ref as GroupStudentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<StudentModel>> createElement() {
    return _GroupStudentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupStudentsProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupStudentsRef on AutoDisposeFutureProviderRef<List<StudentModel>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupStudentsProviderElement
    extends AutoDisposeFutureProviderElement<List<StudentModel>>
    with GroupStudentsRef {
  _GroupStudentsProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupStudentsProvider).groupId;
}

String _$groupNotifierHash() => r'8d26d2e315ec58b89f028223520e7583d4f30983';

/// See also [GroupNotifier].
@ProviderFor(GroupNotifier)
final groupNotifierProvider =
    AutoDisposeAsyncNotifierProvider<GroupNotifier, List<GroupModel>>.internal(
  GroupNotifier.new,
  name: r'groupNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groupNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GroupNotifier = AutoDisposeAsyncNotifier<List<GroupModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
