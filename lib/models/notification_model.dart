import 'package:flutter/material.dart';
import 'dart:convert';

class AppNotification {
  final String id;
  final String? adminId;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    this.adminId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    try {
      // Parse createdAt with better error handling
      DateTime parseCreatedAt(dynamic dateTime) {
        if (dateTime == null) return DateTime.now();

        try {
          if (dateTime is String) {
            // Handle both 'Y-m-d H:i:s' and ISO format
            if (dateTime.contains(' ')) {
              return DateTime.parse(dateTime.replaceAll(' ', 'T'));
            }
            return DateTime.parse(dateTime);
          }
          return DateTime.now();
        } catch (e) {
          print('Error parsing date: $dateTime, error: $e');
          return DateTime.now();
        }
      }

      // Parse data field with better error handling
      Map<String, dynamic>? parseData(dynamic data) {
        if (data == null) return null;

        try {
          if (data is Map<String, dynamic>) {
            return data;
          }

          if (data is String) {
            if (data.trim().isEmpty) return null;
            return jsonDecode(data);
          }

          return null;
        } catch (e) {
          print('Error parsing notification data: $data, error: $e');
          return null;
        }
      }

      // Parse notification type
      NotificationType parseType(dynamic type) {
        if (type == null) return NotificationType.system;

        final typeString = type.toString().toLowerCase();
        switch (typeString) {
          case 'order':
            return NotificationType.order;
          case 'system':
            return NotificationType.system;
          case 'promotion':
            return NotificationType.promotion;
          case 'delivery':
            return NotificationType.delivery;
          default:
            return NotificationType.system;
        }
      }

      return AppNotification(
        id: json['id']?.toString() ?? '',
        adminId: json['admin_id']?.toString(),
        title: json['title']?.toString() ?? 'No Title',
        message: json['message']?.toString() ?? '',
        type: parseType(json['type']),
        createdAt: parseCreatedAt(json['created_at']),
        isRead: json['is_read'] == true ||
            json['is_read'] == 1 ||
            (json['is_read'] is String && json['is_read'] == '1'),
        data: parseData(json['data']),
      );
    } catch (e) {
      print('Error creating AppNotification from JSON: $json, error: $e');
      // Return a default notification instead of throwing
      return AppNotification(
        id: json['id']?.toString() ?? 'error',
        title: 'Error Loading Notification',
        message: 'Could not load this notification',
        type: NotificationType.system,
        createdAt: DateTime.now(),
        isRead: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'title': title,
      'message': message,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead ? 1 : 0,
      'data': data != null ? jsonEncode(data) : null,
    };
  }

  AppNotification copyWith({
    String? id,
    String? adminId,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'AppNotification{id: $id, title: $title, type: $type, isRead: $isRead}';
  }
}

enum NotificationType {
  order('Order', Icons.shopping_bag, Colors.green),
  system('System', Icons.notifications, Colors.blue),
  promotion('Promotion', Icons.local_offer, Colors.orange),
  delivery('Delivery', Icons.delivery_dining, Colors.purple);

  final String displayName;
  final IconData icon;
  final Color color;

  const NotificationType(this.displayName, this.icon, this.color);
}