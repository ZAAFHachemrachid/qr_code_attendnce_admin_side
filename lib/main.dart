// Flutter & Dart imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Feature imports
import 'features/admin/admin.dart';
import 'features/overview/overview.dart';
import 'features/attendance/presentation/pages/attendance_page.dart';
import 'features/classes/presentation/pages/classes_page.dart';
import 'features/department/presentation/pages/department_page.dart';
import 'features/groups/presentation/pages/groups_page.dart';
import 'features/reports/presentation/pages/reports_page.dart';
import 'features/students/presentation/pages/students_page.dart';
import 'features/teachers/presentation/pages/teachers_page.dart';

// Auth imports
import 'features/auth/presentation/widgets/auth_wrapper.dart';
import 'features/auth/providers/auth_provider.dart';

// Shared imports
import 'shared/constants/supabase_constants.dart';
import 'shared/providers/navigation_provider.dart';
import 'shared/widgets/sidebar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Initializing Supabase with service role...');
  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.serviceKey, // Use service key for all operations
  );
  print('Supabase initialized');

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(navigationControllerProvider);
    print('MainApp build - Navigation Index: $navIndex');

    final authState = ref.watch(authNotifierProvider);
    print('MainApp build - User Authenticated: ${authState.user != null}');
    print('MainApp build - User Email: ${authState.user?.email}');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: AuthWrapper(
        child: Builder(
          builder: (context) {
            return Scaffold(
              body: Row(
                children: [
                  const Sidebar(),
                  Expanded(
                    child: IndexedStack(
                      index: ref.watch(navigationControllerProvider),
                      children: const [
                        OverviewPage(),
                        DepartmentPage(),
                        ClassesPage(),
                        TeachersPage(),
                        GroupsPage(),
                        StudentsPage(),
                        AttendancePage(),
                        ReportsPage(),
                        AdminPage(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
