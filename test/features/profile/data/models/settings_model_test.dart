import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/profile/data/models/settings_model.dart';
import 'package:backstage_frontend/features/profile/domain/entities/settings.dart';

void main() {
  const tSettingsModel = SettingsModel(
    language: 'en_US',
    theme: 'light',
    notifications: false,
  );

  test('should be a subclass of Settings entity', () {
    expect(tSettingsModel, isA<Settings>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'language': 'en_US',
        'theme': 'light',
        'notifications': false,
      };

      // Act
      final result = SettingsModel.fromJson(jsonMap);

      // Assert
      expect(result, equals(tSettingsModel));
    });

    test('should return model with default language when not provided', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'theme': 'light',
        'notifications': false,
      };

      // Act
      final result = SettingsModel.fromJson(jsonMap);

      // Assert
      expect(result.language, 'pt_BR');
    });

    test('should return model with default theme when not provided', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'language': 'en_US',
        'notifications': false,
      };

      // Act
      final result = SettingsModel.fromJson(jsonMap);

      // Assert
      expect(result.theme, 'dark');
    });

    test('should return model with default notifications when not provided', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'language': 'en_US',
        'theme': 'light',
      };

      // Act
      final result = SettingsModel.fromJson(jsonMap);

      // Assert
      expect(result.notifications, true);
    });

    test('should return model with all defaults when empty JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {};

      // Act
      final result = SettingsModel.fromJson(jsonMap);

      // Assert
      expect(result.language, 'pt_BR');
      expect(result.theme, 'dark');
      expect(result.notifications, true);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tSettingsModel.toJson();

      // Assert
      final expectedMap = {
        'language': 'en_US',
        'theme': 'light',
        'notifications': false,
      };
      expect(result, equals(expectedMap));
    });
  });

  group('toEntity', () {
    test('should convert SettingsModel to Settings entity', () {
      // Act
      final result = tSettingsModel.toEntity();

      // Assert
      expect(result, isA<Settings>());
      expect(result.language, tSettingsModel.language);
      expect(result.theme, tSettingsModel.theme);
      expect(result.notifications, tSettingsModel.notifications);
    });

    test('should create entity with same values', () {
      // Arrange
      const expectedSettings = Settings(
        language: 'en_US',
        theme: 'light',
        notifications: false,
      );

      // Act
      final result = tSettingsModel.toEntity();

      // Assert
      expect(result, equals(expectedSettings));
    });
  });
}
