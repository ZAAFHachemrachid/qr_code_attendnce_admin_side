import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/enums/management_tab.dart';

final mainTabIndexProvider = StateProvider<int>((ref) => 0);
final studentsTabProvider =
    StateProvider<ManagementTab>((ref) => ManagementTab.view);
final groupsTabProvider =
    StateProvider<ManagementTab>((ref) => ManagementTab.view);

class TabState {
  final ManagementTab currentTab;
  final String? selectedId;

  const TabState({
    required this.currentTab,
    this.selectedId,
  });

  TabState copyWith({
    ManagementTab? currentTab,
    String? selectedId,
  }) {
    return TabState(
      currentTab: currentTab ?? this.currentTab,
      selectedId: selectedId ?? this.selectedId,
    );
  }
}

class TabNotifier extends StateNotifier<TabState> {
  TabNotifier() : super(const TabState(currentTab: ManagementTab.view));

  void setTab(ManagementTab tab) {
    state = state.copyWith(currentTab: tab);
  }

  void selectItem(String? id) {
    state = state.copyWith(selectedId: id);
  }

  void resetSelection() {
    state = state.copyWith(selectedId: null);
  }

  void reset() {
    state = const TabState(currentTab: ManagementTab.view);
  }
}

final studentsTabNotifierProvider =
    StateNotifierProvider<TabNotifier, TabState>((ref) => TabNotifier());

final groupsTabNotifierProvider =
    StateNotifierProvider<TabNotifier, TabState>((ref) => TabNotifier());
