import 'package:flutter/foundation.dart';

@immutable
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool read;
  final String? type;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.read,
    this.type,
  });

  NotificationModel copyWith({bool? read}) => NotificationModel(
    id: id,
    title: title,
    message: message,
    createdAt: createdAt,
    read: read ?? this.read,
    type: type,
  );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      read: json['read'] as bool,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'read': read,
    'type': type,
  };
}
