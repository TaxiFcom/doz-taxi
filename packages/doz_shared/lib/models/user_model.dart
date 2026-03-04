import 'enums.dart';

class UserModel {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final UserRole role;
  final String? avatarUrl;
  final String lang;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
    this.lang = 'ar',
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String? ?? '',
      role: UserRole.fromJson(json['role'] as String?),
      avatarUrl: json['avatarUrl'] as String?,
      lang: json['lang'] as String? ?? 'ar',
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (email != null) 'email': email,
      'phone': phone,
      'role': role.toJson(),
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'lang': lang,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? avatarUrl,
    String? lang,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lang: lang ?? this.lang,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, name: $name, role: $role)';
}
