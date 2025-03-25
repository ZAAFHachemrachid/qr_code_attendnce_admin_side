import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tab_provider.dart';
import 'students_page.dart';
import 'groups_page.dart';

class StudentAndGroupsPage extends ConsumerStatefulWidget {
  const StudentAndGroupsPage({super.key});

  @override
  ConsumerState<StudentAndGroupsPage> createState() =>
      _StudentAndGroupsPageState();
}

class _StudentAndGroupsPageState extends ConsumerState<StudentAndGroupsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    ref.read(mainTabIndexProvider.notifier).state = _tabController.index;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Students Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(
                  icon: Icon(Icons.people),
                  text: 'Students',
                ),
                Tab(
                  icon: Icon(Icons.group_work),
                  text: 'Groups',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          StudentsPage(),
          GroupsPage(),
        ],
      ),
    );
  }
}
