import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/course_provider.dart';
import '../../../../shared/widgets/common/data_table_widget.dart';
import '../widgets/course_form_dialog.dart';

class CoursesPage extends ConsumerWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(asyncCourseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        centerTitle: true,
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error: ${error.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(asyncCourseListProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (courses) {
          final columns = [
            const CustomDataColumn(
              label: 'Course Code',
              field: 'code',
            ),
            const CustomDataColumn(
              label: 'Title',
              field: 'title',
            ),
            const CustomDataColumn(
              label: 'Credit Hours',
              field: 'creditHours',
            ),
            const CustomDataColumn(
              label: 'Year of Study',
              field: 'yearOfStudy',
            ),
            const CustomDataColumn(
              label: 'Semester',
              field: 'semester',
            ),
            CustomDataColumn(
              label: 'Description',
              field: 'description',
              customBuilder: (value) => Text(
                value as String? ?? 'No description',
                style: TextStyle(
                  color: value == null ? Colors.grey : null,
                  fontStyle: value == null ? FontStyle.italic : null,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ];

          final data = courses
              .map((course) => {
                    'id': course.id,
                    'code': course.code,
                    'title': course.title,
                    'description': course.description,
                    'creditHours': course.creditHours.toString(),
                    'departmentId': course.departmentId,
                    'yearOfStudy': course.yearOfStudy.toString(),
                    'semester': course.semester,
                  })
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: DataTableWidget(
              columns: columns,
              data: data,
              isLoading: false,
              onAdd: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => const CourseFormDialog(),
                );

                if (result == true) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Course added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  ref.invalidate(asyncCourseListProvider);
                }
              },
              onEdit: (course) async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => CourseFormDialog(
                    id: course['id'] as String,
                    code: course['code'] as String,
                    title: course['title'] as String,
                    description: course['description'] as String?,
                    creditHours: int.parse(course['creditHours']),
                    departmentId: course['departmentId'] as String,
                    yearOfStudy: int.parse(course['yearOfStudy']),
                    semester: course['semester'] as String,
                  ),
                );

                if (result == true) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Course updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  ref.invalidate(asyncCourseListProvider);
                }
              },
              onDelete: (course) async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: Text(
                      'Are you sure you want to delete ${course['code']} - ${course['title']}? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    await ref
                        .read(asyncCourseListProvider.notifier)
                        .deleteCourse(course['id'] as String);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Course deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Error deleting course: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              noDataMessage: 'No courses found',
            ),
          );
        },
      ),
    );
  }
}
