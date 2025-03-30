import 'package:flutter/foundation.dart';

@immutable
class CourseModel {
  final String id;
  final String code;
  final String title;
  final String? description;
  final int creditHours;
  final String departmentId;
  final int yearOfStudy;
  final String semester;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseModel({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.creditHours,
    required this.departmentId,
    required this.yearOfStudy,
    required this.semester,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      creditHours: json['credit_hours'] as int,
      departmentId: json['department_id'] as String,
      yearOfStudy: json['year_of_study'] as int,
      semester: json['semester'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'credit_hours': creditHours,
      'department_id': departmentId,
      'year_of_study': yearOfStudy,
      'semester': semester,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CourseModel copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    int? creditHours,
    String? departmentId,
    int? yearOfStudy,
    String? semester,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      creditHours: creditHours ?? this.creditHours,
      departmentId: departmentId ?? this.departmentId,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      semester: semester ?? this.semester,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
