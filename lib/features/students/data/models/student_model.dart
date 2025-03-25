import 'package:flutter/foundation.dart';

@immutable
class StudentModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String studentNumber;
  final String? groupId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.studentNumber,
    this.groupId,
    required this.createdAt,
    required this.updatedAt,
  });

  StudentModel copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? studentNumber,
    String? groupId,
  }) {
    return StudentModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      studentNumber: studentNumber ?? this.studentNumber,
      groupId: groupId ?? this.groupId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing student JSON: $json');

    final studentProfile =
        (json['student_profiles'] as Map<String, dynamic>?) ??
            (throw Exception('Student profile data is missing'));

    debugPrint('Student profile data: $studentProfile');

    try {
      return StudentModel(
        id: json['id'] as String? ?? (throw Exception('Student id is missing')),
        firstName: json['first_name'] as String? ??
            (throw Exception('Student first_name is missing')),
        lastName: json['last_name'] as String? ??
            (throw Exception('Student last_name is missing')),
        phone: json['phone'] as String?,
        studentNumber: studentProfile['student_number'] as String? ??
            (throw Exception('Student student_number is missing')),
        groupId: studentProfile['group_id'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : (throw Exception('Student created_at is missing')),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : (throw Exception('Student updated_at is missing')),
      );
    } catch (e) {
      debugPrint('Error creating StudentModel from JSON: $e');
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
      'student_profiles': {
        'student_number': studentNumber,
        'group_id': groupId,
      },
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StudentModel &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phone == phone &&
        other.studentNumber == studentNumber &&
        other.groupId == groupId &&
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
      studentNumber,
      groupId,
      createdAt,
      updatedAt,
    );
  }
}
