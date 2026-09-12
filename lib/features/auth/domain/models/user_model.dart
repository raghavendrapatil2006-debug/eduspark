import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'student' or 'teacher'
  final String? standard;
  final String? board;
  final String? school;
  final String? specialization;
  final String? phone;
  final String? avatarUrl;
  final bool isDemo;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.standard,
    this.board,
    this.school,
    this.specialization,
    this.phone,
    this.avatarUrl,
    this.isDemo = false,
    required this.createdAt,
  });

  bool get isStudent => role.toLowerCase() == 'student';
  bool get isTeacher => role.toLowerCase() == 'teacher';

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? standard,
    String? board,
    String? school,
    String? specialization,
    String? phone,
    String? avatarUrl,
    bool? isDemo,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      standard: standard ?? this.standard,
      board: board ?? this.board,
      school: school ?? this.school,
      specialization: specialization ?? this.specialization,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isDemo: isDemo ?? this.isDemo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'standard': standard,
      'board': board,
      'school': school,
      'specialization': specialization,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'isDemo': isDemo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'EduSpark User',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'student',
      standard: map['standard'] as String?,
      board: map['board'] as String?,
      school: map['school'] as String?,
      specialization: map['specialization'] as String?,
      phone: map['phone'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      isDemo: map['isDemo'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
