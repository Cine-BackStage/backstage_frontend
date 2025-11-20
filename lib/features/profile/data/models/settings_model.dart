import '../../domain/entities/settings.dart';

class SettingsModel extends Settings {
  const SettingsModel({
    required super.language,
    required super.theme,
    required super.notifications,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      language: json['language'] as String? ?? 'pt_BR',
      theme: json['theme'] as String? ?? 'dark',
      notifications: json['notifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme': theme,
      'notifications': notifications,
    };
  }

  Settings toEntity() {
    return Settings(
      language: language,
      theme: theme,
      notifications: notifications,
    );
  }
}
