import 'dart:convert';
import '../../../../adapters/storage/local_storage.dart';
import '../models/settings_model.dart';

abstract class ProfileLocalDataSource {
  Future<SettingsModel> getSettings();
  Future<void> saveSettings(SettingsModel settings);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final LocalStorage storage;
  static const String _settingsKey = 'app_settings';

  ProfileLocalDataSourceImpl(this.storage);

  @override
  Future<SettingsModel> getSettings() async {
    final jsonString = storage.getString(_settingsKey);

    if (jsonString == null) {
      // Return default settings
      return const SettingsModel(
        language: 'pt_BR',
        theme: 'dark',
        notifications: true,
      );
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return SettingsModel.fromJson(json);
    } catch (e) {
      // If parsing fails, return default settings
      return const SettingsModel(
        language: 'pt_BR',
        theme: 'dark',
        notifications: true,
      );
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    final jsonString = jsonEncode(settings.toJson());
    await storage.setString(_settingsKey, jsonString);
  }
}
