import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class Store {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final bool isActive;
  final String managerName;
  final String managerPhone;
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final List<String> workingDays;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isOpen;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.isActive = true,
    required this.managerName,
    required this.managerPhone,
    required this.openingTime,
    required this.closingTime,
    required this.workingDays,
    required this.createdAt,
    this.updatedAt,
    this.isOpen = false,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    TimeOfDay parseTime(String timeString) {
      final timeParts = timeString.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    }

    List<String> workingDays = [];
    if (json['working_days'] != null) {
      if (json['working_days'] is String) {
        try {
          final decoded = jsonDecode(json['working_days']);
          if (decoded is List) {
            workingDays = List<String>.from(decoded);
          }
        } catch (e) {
          if (json['working_days'].contains(',')) {
            workingDays = json['working_days'].split(',').map((day) => day.trim()).toList();
          } else {
            workingDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
          }
        }
      } else if (json['working_days'] is List) {
        workingDays = List<String>.from(json['working_days']);
      }
    } else {
      workingDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    }

    return Store(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['image_url'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      managerName: json['manager_name'] ?? '',
      managerPhone: json['manager_phone'] ?? '',
      openingTime: json['opening_time'] != null
          ? parseTime(json['opening_time'])
          : const TimeOfDay(hour: 9, minute: 0),
      closingTime: json['closing_time'] != null
          ? parseTime(json['closing_time'])
          : const TimeOfDay(hour: 3, minute: 0), // Changed default to 3 AM
      workingDays: workingDays,
      isOpen: json['is_open'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'image_url': imageUrl,
      'is_active': isActive ? 1 : 0,
      'manager_name': managerName,
      'manager_phone': managerPhone,
      'opening_time': '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}:00',
      'closing_time': '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}:00',
      'working_days': jsonEncode(workingDays),
    };
  }

  Map<String, dynamic> toFormData() {
    final workingDaysJson = jsonEncode(workingDays);

    print('=== Store.toFormData() ===');
    print('Working days list: $workingDays');
    print('Working days JSON: $workingDaysJson');

    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'manager_name': managerName,
      'manager_phone': managerPhone,
      'opening_time': '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}:00',
      'closing_time': '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}:00',
      'working_days': workingDaysJson,
      'is_active': isActive ? '1' : '0',
    };
  }

  Map<String, dynamic> toUpdateFormData() {
    final workingDaysJson = jsonEncode(workingDays);

    print('=== Store.toUpdateFormData() ===');
    print('Working days list: $workingDays');
    print('Working days JSON: $workingDaysJson');

    return {
      'store_id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'manager_name': managerName,
      'manager_phone': managerPhone,
      'opening_time': '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}:00',
      'closing_time': '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}:00',
      'working_days': workingDaysJson,
      'is_active': isActive ? '1' : '0',
    };
  }

  Store copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    double? latitude,
    double? longitude,
    String? imageUrl,
    bool? isActive,
    String? managerName,
    String? managerPhone,
    TimeOfDay? openingTime,
    TimeOfDay? closingTime,
    List<String>? workingDays,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOpen,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      managerName: managerName ?? this.managerName,
      managerPhone: managerPhone ?? this.managerPhone,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      workingDays: workingDays ?? this.workingDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  String get formattedHours {
    final opening = '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}';

    // Format closing time for display (handle 24-hour format)
    String closingDisplay;
    if (closingTime.hour < 5) { // If closing time is between midnight and 5 AM, show as next day
      closingDisplay = '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')} (next day)';
    } else {
      closingDisplay = '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}';
    }

    return '$opening - $closingDisplay';
  }

  String get workingDaysFormatted {
    return workingDays.join(', ');
  }

  bool get isCurrentlyOpen {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final currentDay = DateFormat('EEEE').format(now);

    return isActive &&
        workingDays.contains(currentDay) &&
        _isTimeBetweenOvernight(currentTime, openingTime, closingTime);
  }

  // UPDATED: Handle overnight hours (9 AM to 3 AM next day)
  bool _isTimeBetweenOvernight(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    // If closing time is earlier than opening time (overnight operation)
    if (endMinutes < startMinutes) {
      // Store is open if current time is after opening OR before closing (next day)
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    } else {
      // Normal operation (same day)
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    }
  }

  // Helper method to validate if the time range makes sense
  bool get hasValidHours {
    final openingMinutes = openingTime.hour * 60 + openingTime.minute;
    final closingMinutes = closingTime.hour * 60 + closingTime.minute;

    // Allow overnight operations (closing time can be less than opening time)
    // But ensure times are within valid 24-hour range
    return openingTime.hour >= 0 && openingTime.hour < 24 &&
        closingTime.hour >= 0 && closingTime.hour < 24 &&
        openingTime.minute >= 0 && openingTime.minute < 60 &&
        closingTime.minute >= 0 && closingTime.minute < 60;
  }
}