import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/overview_provider.dart';

class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(overviewStatsProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    ref.read(overviewStatsProvider.notifier).refresh(),
                tooltip: 'Refresh stats',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: statsAsync.when(
              data: (stats) => GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _StatCard(
                    title: 'Total Students',
                    value: (stats['students'] ?? 0).toString(),
                    icon: Icons.school,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: 'Total Teachers',
                    value: (stats['teachers'] ?? 0).toString(),
                    icon: Icons.people,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: 'Total Classes',
                    value: (stats['classes'] ?? 0).toString(),
                    icon: Icons.class_,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    title: 'Departments',
                    value: (stats['departments'] ?? 0).toString(),
                    icon: Icons.business,
                    color: Colors.purple,
                  ),
                  _StatCard(
                    title: 'Today\'s Attendance',
                    value: (stats['todayAttendance'] ?? 0).toString(),
                    icon: Icons.qr_code,
                    color: Colors.teal,
                  ),
                  _StatCard(
                    title: 'Total Admins',
                    value: (stats['admins'] ?? 0).toString(),
                    icon: Icons.admin_panel_settings,
                    color: Colors.red,
                  ),
                ],
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${error.toString()}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(overviewStatsProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
