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
import 'features/reports/presentation/pages/reports_page.dart';
import 'features/students/presentation/pages/students_page.dart';
import 'features/teachers/presentation/pages/teachers_page.dart';

// Auth imports
import 'features/auth/presentation/widgets/auth_wrapper.dart';

// Shared imports
import 'shared/constants/supabase_constants.dart';
import 'shared/providers/navigation_provider.dart';
import 'shared/widgets/sidebar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        child: Row(
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
                  StudentsPage(),
                  AttendancePage(),
                  ReportsPage(),
                  AdminPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
