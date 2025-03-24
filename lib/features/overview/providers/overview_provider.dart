import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'overview_provider.g.dart';

@riverpod
class OverviewStats extends _$OverviewStats {
  @override
  Future<Map<String, int>> build() async {
    return _fetchStats();
  }

  Future<Map<String, int>> _fetchStats() async {
    final supabase = Supabase.instance.client;
    final stats = <String, int>{};

    try {
      // Get total students count
      final studentsCount =
          await supabase.from('profiles').count().eq('role', 'student');
      stats['students'] = studentsCount;

      // Get total teachers count
      final teachersCount =
          await supabase.from('profiles').count().eq('role', 'teacher');
      stats['teachers'] = teachersCount;

      // Get total classes count
      final classesCount = await supabase.from('student_groups').count();
      stats['classes'] = classesCount;

      // Get total departments count
      final departmentsCount = await supabase.from('departments').count();
      stats['departments'] = departmentsCount;

      // Get today's attendance count
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final attendanceCount = await supabase
          .from('attendance')
          .count()
          .gte('created_at', todayStart.toIso8601String())
          .lt('created_at', todayEnd.toIso8601String());
      stats['todayAttendance'] = attendanceCount;

      // Get total admins count
      final adminsCount =
          await supabase.from('profiles').count().eq('role', 'admin');
      stats['admins'] = adminsCount;

      return stats;
    } catch (e) {
      throw Exception('Failed to fetch stats: ${e.toString()}');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}
