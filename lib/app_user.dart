import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_user.g.dart';

@JsonSerializable()
class AppUser extends Equatable {
  AppUser(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.password,
      this.isAdmin = false});

  String firstName;
  String lastName;
  String email;
  String password;
  bool isAdmin;

  factory AppUser.fromJson(Map<String,dynamic> json) => _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);
  @override
  // TODO: implement props
  List<Object?> get props =>[firstName, lastName, email, password, isAdmin];
}
