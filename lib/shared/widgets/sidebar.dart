import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../../features/auth/auth.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationControllerProvider);
    final user = ref.watch(authNotifierProvider).user;

    print('Sidebar build');
    print('- Current Index: $currentIndex');
    print('- User: ${user?.email}');

    return Container(
      constraints: const BoxConstraints(
        minWidth: 200,
        maxWidth: 280,
      ),
      child: Builder(
        builder: (context) {
          try {
            return NavigationRail(
              extended: true,
              backgroundColor: Theme.of(context).primaryColor,
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                print('Navigation selected: $index');
                ref
                    .read(navigationControllerProvider.notifier)
                    .changePage(index);
              },
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.qr_code,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'QR Attendance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        user.email ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    child: FilledButton.icon(
                      onPressed: () {
                        print('Logout pressed');
                        ref.read(authNotifierProvider.notifier).signOut();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.business),
                  label: Text('Department'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.class_),
                  label: Text('Classes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Teachers'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.groups),
                  label: Text('Groups'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.school),
                  label: Text('Students'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.qr_code),
                  label: Text('Attendance'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assessment),
                  label: Text('Reports'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.admin_panel_settings),
                  label: Text('Admins'),
                ),
              ],
            );
          } catch (e) {
            print('Error in Sidebar: $e');
            return const Center(
              child: Text(
                'Navigation Error',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
        },
      ),
    );
  }
}
