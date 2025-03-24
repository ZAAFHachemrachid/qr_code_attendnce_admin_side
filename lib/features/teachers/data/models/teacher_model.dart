import 'package:flutter/foundation.dart';

@immutable
class TeacherModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String employeeId;
  final String? departmentId; // Make departmentId optional
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeacherModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.employeeId,
    this.departmentId, // Make departmentId optional
    required this.createdAt,
    required this.updatedAt,
  });

  TeacherModel copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? employeeId,
    String? departmentId,
  }) {
    return TeacherModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      employeeId: employeeId ?? this.employeeId,
      departmentId: departmentId ?? this.departmentId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing teacher JSON: $json');

    final teacherProfile =
        (json['teacher_profiles'] as Map<String, dynamic>?) ??
            (throw Exception('Teacher profile data is missing'));

    debugPrint('Teacher profile data: $teacherProfile');

    try {
      return TeacherModel(
        id: json['id'] as String? ?? (throw Exception('Teacher id is missing')),
        firstName: json['first_name'] as String? ??
            (throw Exception('Teacher first_name is missing')),
        lastName: json['last_name'] as String? ??
            (throw Exception('Teacher last_name is missing')),
        phone: json['phone'] as String?,
        employeeId: teacherProfile['employee_id'] as String? ??
            (throw Exception('Teacher employee_id is missing')),
        departmentId:
            teacherProfile['department_id'] as String?, // Make this optional
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : (throw Exception('Teacher created_at is missing')),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : (throw Exception('Teacher updated_at is missing')),
      );
    } catch (e) {
      debugPrint('Error creating TeacherModel from JSON: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'teacher_profiles': {
        'employee_id': employeeId,
        'department_id': departmentId,
      },
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TeacherModel &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phone == phone &&
        other.employeeId == employeeId &&
        other.departmentId == departmentId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      firstName,
      lastName,
      phone,
      employeeId,
      departmentId,
      createdAt,
      updatedAt,
    );
  }
}
