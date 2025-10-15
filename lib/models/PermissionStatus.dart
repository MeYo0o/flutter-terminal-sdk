import 'dart:convert';

class PermissionStatus {
  final String? permission;
  final bool? isGranted;

  PermissionStatus({this.permission, this.isGranted});

  factory PermissionStatus.fromJson(dynamic json) {
    return PermissionStatus(
      permission: json['permission'],
      isGranted: json['isGranted'],
    );
  }
}
