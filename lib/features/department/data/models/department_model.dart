import 'package:flutter/foundation.dart';

@immutable
class DepartmentModel {
  final String id;
  final String name;
  final String code;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    required this.createdAt,
    required this.updatedAt,
  });

  DepartmentModel copyWith({
    String? name,
    String? code,
  }) {
    return DepartmentModel(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DepartmentModel &&
        other.id == id &&
        other.name == name &&
        other.code == code &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      code,
      createdAt,
      updatedAt,
    );
  }
}
