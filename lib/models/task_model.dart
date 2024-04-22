// Updated task_model.dart

import 'dart:convert';

class Task {
  int? id;
  String title;
  String description;
  String? priority; // Added priority field
  DateTime? dateTime; // Added DateTime field
  String? color; // Added color field

  Task({
    this.id,
    required this.title,
    required this.description,
    this.priority,
    this.dateTime,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'dateTime': dateTime?.toIso8601String(), // Convert DateTime to string
      'color': color,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      priority: map['priority'],
      dateTime: _parseDateTime(map['dateTime']),
      color: map['color'].toString(),
    );
  }

  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;

    // Try to parse the date in 'dd-MM-yyyy' format
    try {
      return DateTime.parse(dateTime);
    } catch (e) {
      // Handle the exception, and try to parse in another format if necessary
      // For example, if the date is stored as a string in ISO8601 format
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        print("Error parsing date: $e");
        return null;
      }
    }
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}
