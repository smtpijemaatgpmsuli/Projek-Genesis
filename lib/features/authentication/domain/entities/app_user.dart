import 'package:freezed_annotation/freezed_annotation.dart';

import '../value_objects/user_role.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    @UserRoleConverter() required UserRole role,
    String? displayName,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
