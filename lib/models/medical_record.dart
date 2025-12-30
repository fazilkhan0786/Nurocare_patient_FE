
import 'package:flutter/material.dart';

class MedicalRecord {
  final String title;
  final String filePath;
  final DateTime date;
  final IconData icon;

  MedicalRecord({
    required this.title,
    required this.filePath,
    required this.date,
    required this.icon,
  });

  // From JSON
  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      title: json['title'],
      filePath: json['filePath'],
      date: DateTime.parse(json['date']),
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'filePath': filePath,
      'date': date.toIso8601String(),
      'icon': icon.codePoint,
    };
  }
}
