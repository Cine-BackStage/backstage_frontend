import 'package:equatable/equatable.dart';

/// App settings entity
class Settings extends Equatable {
  final String language;
  final String theme;
  final bool notifications;

  const Settings({
    required this.language,
    required this.theme,
    required this.notifications,
  });

  Settings copyWith({
    String? language,
    String? theme,
    bool? notifications,
  }) {
    return Settings(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [language, theme, notifications];
}
