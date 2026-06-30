import 'package:freezed_annotation/freezed_annotation.dart';

enum UserRole {
  superAdmin,
  admin,
  pengasuh,
  orangTua,
}

extension UserRoleMapper on UserRole {
  String get value => switch (this) {
        UserRole.superAdmin => 'super_admin',
        UserRole.admin => 'admin',
        UserRole.pengasuh => 'pengasuh',
        UserRole.orangTua => 'orang_tua',
      };

  String get label => switch (this) {
        UserRole.superAdmin => 'Super Admin',
        UserRole.admin => 'Admin',
        UserRole.pengasuh => 'Pengasuh',
        UserRole.orangTua => 'Orang Tua / Anak',
      };

  bool get canManageUsers =>
      this == UserRole.superAdmin || this == UserRole.admin;
}

class UserRoleConverter implements JsonConverter<UserRole, String> {
  const UserRoleConverter();

  @override
  UserRole fromJson(String json) {
    return switch (json) {
      'super_admin' => UserRole.superAdmin,
      'admin' => UserRole.admin,
      'pengasuh' => UserRole.pengasuh,
      'orang_tua' => UserRole.orangTua,
      _ => UserRole.pengasuh,
    };
  }

  @override
  String toJson(UserRole object) => object.value;
}
