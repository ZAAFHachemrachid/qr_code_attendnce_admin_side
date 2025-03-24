import 'package:flutter/foundation.dart';

@immutable
class AdminModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String accessLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.accessLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String?,
      accessLevel: json['access_level'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'access_level': accessLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AdminModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? accessLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      accessLevel: accessLevel ?? this.accessLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AdminModel &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phone == phone &&
        other.accessLevel == accessLevel &&
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
      accessLevel,
      createdAt,
      updatedAt,
    );
  }
}
