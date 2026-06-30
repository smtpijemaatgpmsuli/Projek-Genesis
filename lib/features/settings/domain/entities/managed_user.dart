import '../../../authentication/domain/value_objects/user_role.dart';

class ManagedUser {
  const ManagedUser({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.isActive = true,
  });

  final String id;
  final String email;
  final UserRole role;
  final String? fullName;
  final bool isActive;

  ManagedUser copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? fullName,
    bool? isActive,
  }) {
    return ManagedUser(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      isActive: isActive ?? this.isActive,
    );
  }

  factory ManagedUser.fromMap(Map<String, dynamic> map) {
    final roleValue = map['role'] as String?;
    return ManagedUser(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      role: UserRoleConverter().fromJson(roleValue ?? 'pengasuh'),
      fullName: map['full_name'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'role': role.value,
        'full_name': fullName,
        'is_active': isActive,
      };
}
