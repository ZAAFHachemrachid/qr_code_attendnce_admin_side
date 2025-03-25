import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/management_tab.dart';

class ManagementTabView extends ConsumerStatefulWidget {
  final List<Widget> views;
  final StateProvider<ManagementTab> tabProvider;
  final String title;
  final bool hideUpdateDelete;
  final List<String> tabLabels;

  const ManagementTabView({
    super.key,
    required this.views,
    required this.tabProvider,
    required this.title,
    this.hideUpdateDelete = true,
    this.tabLabels = const [],
  });

  @override
  ConsumerState<ManagementTabView> createState() => _ManagementTabViewState();
}

class _ManagementTabViewState extends ConsumerState<ManagementTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.hideUpdateDelete ? 2 : ManagementTab.values.length,
      vsync: this,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;

    final newTab = widget.hideUpdateDelete
        ? _tabController.index == 0
            ? ManagementTab.view
            : ManagementTab.create
        : ManagementTab.values[_tabController.index];

    ref.read(widget.tabProvider.notifier).state = newTab;
  }

  @override
  void didUpdateWidget(ManagementTabView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update tab controller if number of tabs changes
    if ((widget.hideUpdateDelete != oldWidget.hideUpdateDelete) ||
        (widget.hideUpdateDelete ? 2 : ManagementTab.values.length) !=
            _tabController.length) {
      _tabController.dispose();
      _tabController = TabController(
        length: widget.hideUpdateDelete ? 2 : ManagementTab.values.length,
        vsync: this,
      );
      _tabController.addListener(_handleTabChange);
    }

    // Update tab index based on current tab state
    final currentTab = ref.read(widget.tabProvider);
    final targetIndex = widget.hideUpdateDelete
        ? (currentTab == ManagementTab.view ? 0 : 1)
        : ManagementTab.values.indexOf(currentTab);

    if (_tabController.index != targetIndex) {
      _tabController.animateTo(targetIndex);
    }
  }

  List<Widget> _buildTabs() {
    if (widget.hideUpdateDelete) {
      return const [
        Tab(text: 'View'),
        Tab(text: 'Create'),
      ];
    }

    if (widget.tabLabels.isNotEmpty) {
      return widget.tabLabels.map((label) => Tab(text: label)).toList();
    }

    return ManagementTab.values.map((tab) => Tab(text: tab.name)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: _buildTabs(),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.views,
          ),
        ),
      ],
    );
  }
}
