import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Feature info for carousel display on login screen
class FeatureInfo extends Equatable {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;

  const FeatureInfo({
    required this.title,
    required this.description,
    required this.icon,
    this.color,
  });

  @override
  List<Object?> get props => [title, description, icon, color];
}
