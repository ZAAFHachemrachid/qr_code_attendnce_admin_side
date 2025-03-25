import 'package:flutter/foundation.dart';

@immutable
class GroupModel {
  final String id;
  final String departmentId;
  final int academicYear;
  final int currentYear;
  final String section;
  final String? name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroupModel({
    required this.id,
    required this.departmentId,
    required this.academicYear,
    required this.currentYear,
    required this.section,
    this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  GroupModel copyWith({
    String? departmentId,
    int? academicYear,
    int? currentYear,
    String? section,
    String? name,
  }) {
    return GroupModel(
      id: id,
      departmentId: departmentId ?? this.departmentId,
      academicYear: academicYear ?? this.academicYear,
      currentYear: currentYear ?? this.currentYear,
      section: section ?? this.section,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing group JSON: $json');

    try {
      return GroupModel(
        id: json['id'] as String? ?? (throw Exception('Group id is missing')),
        departmentId: json['department_id'] as String? ??
            (throw Exception('Department id is missing')),
        academicYear: json['academic_year'] as int? ??
            (throw Exception('Academic year is missing')),
        currentYear: json['current_year'] as int? ??
            (throw Exception('Current year is missing')),
        section: json['section'] as String? ??
            (throw Exception('Section is missing')),
        name: json['name'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : (throw Exception('Created at is missing')),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : (throw Exception('Updated at is missing')),
      );
    } catch (e) {
      debugPrint('Error creating GroupModel from JSON: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'department_id': departmentId,
      'academic_year': academicYear,
      'current_year': currentYear,
      'section': section,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GroupModel &&
        other.id == id &&
        other.departmentId == departmentId &&
        other.academicYear == academicYear &&
        other.currentYear == currentYear &&
        other.section == section &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      departmentId,
      academicYear,
      currentYear,
      section,
      name,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'GroupModel(id: $id, departmentId: $departmentId, academicYear: $academicYear, currentYear: $currentYear, section: $section, name: $name)';
  }
}
