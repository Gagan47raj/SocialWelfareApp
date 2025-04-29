import 'package:cloud_firestore/cloud_firestore.dart';

class Department {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String type;
  final String governmentLevel;
  final String parentMinistry;
  final List<String> complaintCategories;
  final DateTime createdAt;

  Department({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    required this.governmentLevel,
    required this.parentMinistry,
    required this.complaintCategories,
    required this.createdAt,
  });

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      type: map['type'],
      governmentLevel: map['governmentLevel'],
      parentMinistry: map['parentMinistry'],
      complaintCategories: List<String>.from(map['complaintCategories'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'type': type,
      'governmentLevel': governmentLevel,
      'parentMinistry': parentMinistry,
      'complaintCategories': complaintCategories,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
