import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/adapters/storage/local_storage.dart' hide StorageKeys;
import 'package:backstage_frontend/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:backstage_frontend/features/profile/data/models/settings_model.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  late ProfileLocalDataSourceImpl dataSource;
  late MockLocalStorage mockStorage;

  setUp(() {
    mockStorage = MockLocalStorage();
    dataSource = ProfileLocalDataSourceImpl(mockStorage);
  });

  const tSettingsModel = SettingsModel(
    language: 'en_US',
    theme: 'light',
    notifications: false,
  );

  group('getSettings', () {
    test('should return settings from LocalStorage when data exists', () async {
      // Arrange
      final jsonString = jsonEncode({
        'language': 'en_US',
        'theme': 'light',
        'notifications': false,
      });
      when(() => mockStorage.getString(any())).thenReturn(jsonString);

      // Act
      final result = await dataSource.getSettings();

      // Assert
      expect(result, equals(tSettingsModel));
      verify(() => mockStorage.getString('app_settings')).called(1);
    });

    test('should return default settings when no data exists', () async {
      // Arrange
      when(() => mockStorage.getString(any())).thenReturn(null);

      // Act
      final result = await dataSource.getSettings();

      // Assert
      expect(result.language, 'pt_BR');
      expect(result.theme, 'dark');
      expect(result.notifications, true);
    });

    test('should return default settings when JSON parsing fails', () async {
      // Arrange
      when(() => mockStorage.getString(any())).thenReturn('invalid json');

      // Act
      final result = await dataSource.getSettings();

      // Assert
      expect(result.language, 'pt_BR');
      expect(result.theme, 'dark');
      expect(result.notifications, true);
    });
  });

  group('saveSettings', () {
    test('should call LocalStorage to save settings', () async {
      // Arrange
      when(() => mockStorage.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.saveSettings(tSettingsModel);

      // Assert
      final expectedJsonString = jsonEncode({
        'language': 'en_US',
        'theme': 'light',
        'notifications': false,
      });
      verify(() => mockStorage.setString('app_settings', expectedJsonString))
          .called(1);
    });
  });
}
