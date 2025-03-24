import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

@riverpod
class NavigationController extends _$NavigationController {
  @override
  int build() => 0; // Default to Overview page

  void changePage(int index) {
    state = index;
  }
}
