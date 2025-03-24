import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/admin_model.dart';
import '../data/repositories/admin_repository.dart';

part 'admin_provider.g.dart';

@riverpod
class AdminNotifier extends _$AdminNotifier {
  @override
  Future<List<AdminModel>> build() {
    return _fetchAdmins();
  }

  Future<List<AdminModel>> _fetchAdmins() async {
    final repository = ref.read(adminRepositoryProvider);
    return repository.getAllAdmins();
  }

  Future<void> createAdmin({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required String accessLevel,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(adminRepositoryProvider);
      await repository.createAdmin(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        accessLevel: accessLevel,
      );
      return _fetchAdmins();
    });
  }

  Future<void> updateAdmin({
    required String id,
    required String firstName,
    required String lastName,
    String? phone,
    required String accessLevel,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(adminRepositoryProvider);
      await repository.updateAdmin(
        id: id,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        accessLevel: accessLevel,
      );
      return _fetchAdmins();
    });
  }

  Future<void> deleteAdmin(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(adminRepositoryProvider);
      await repository.deleteAdmin(id);
      return _fetchAdmins();
    });
  }
}

@riverpod
class AdminFormNotifier extends _$AdminFormNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> submitForm({
    String? id,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required String accessLevel,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final adminNotifier = ref.read(adminNotifierProvider.notifier);

      if (id != null) {
        await adminNotifier.updateAdmin(
          id: id,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          accessLevel: accessLevel,
        );
      } else {
        await adminNotifier.createAdmin(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          accessLevel: accessLevel,
        );
      }
    });
  }
}
