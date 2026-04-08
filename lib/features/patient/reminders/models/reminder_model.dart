import 'package:flutter/material.dart';

class ReminderModel {
  final String id;
  final String title;
  final String body;
  final bool isEnabled;
  final TimeOfDay time;
  final int notificationId;
  final IconData icon;
  final Color color;

  ReminderModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isEnabled,
    required this.time,
    required this.notificationId,
    required this.icon,
    required this.color,
  });

  ReminderModel copyWith({
    String? id,
    String? title,
    String? body,
    bool? isEnabled,
    TimeOfDay? time,
    int? notificationId,
    IconData? icon,
    Color? color,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isEnabled: isEnabled ?? this.isEnabled,
      time: time ?? this.time,
      notificationId: notificationId ?? this.notificationId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': body,
      'is_active': isEnabled,
      'reminder_time': "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00",
      'repeat_daily': true,
    };
  }

  factory ReminderModel.fromSupabase(Map<String, dynamic> json, IconData icon, Color color, int notificationId) {
    final timeStr = json['reminder_time'] as String;
    final timeParts = timeStr.split(':');
    return ReminderModel(
      id: json['id'],
      title: json['title'],
      body: json['description'],
      isEnabled: json['is_active'],
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      notificationId: notificationId,
      icon: icon,
      color: color,
    );
  }

  // Local storage mapping
  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      title: json['title'],
      body: json['description'] ?? json['body'],
      isEnabled: json['isEnabled'] ?? json['is_active'],
      time: TimeOfDay(hour: json['hour'] ?? 8, minute: json['minute'] ?? 0),
      notificationId: json['notificationId'],
      icon: Icons.notifications, 
      color: Colors.blue, 
    );
  }
}
