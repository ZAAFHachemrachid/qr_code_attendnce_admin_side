import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        title: const Text('Students & Groups Management'),
        bottom: TabBar(
          controller: _tabController,
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
