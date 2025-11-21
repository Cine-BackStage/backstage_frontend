import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/dashboard/data/models/session_summary_model.dart';
import 'package:backstage_frontend/features/dashboard/domain/entities/session_summary.dart';

void main() {
  const tSessionSummaryModel = SessionSummaryModel(
    activeSessionsToday: 3,
    upcomingSessions: 5,
    totalSessionsToday: 8,
    averageOccupancy: 75.5,
    totalTicketsSold: 150,
  );

  test('should be a subclass of SessionSummary entity', () {
    expect(tSessionSummaryModel, isA<SessionSummary>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'activeSessionsToday': 3,
        'upcomingSessions': 5,
        'totalSessionsToday': 8,
        'averageOccupancy': 75.5,
        'totalTicketsSold': 150,
      };

      // Act
      final result = SessionSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result, equals(tSessionSummaryModel));
    });

    test('should return model with default values when fields are missing', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {};

      // Act
      final result = SessionSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result.activeSessionsToday, 0);
      expect(result.upcomingSessions, 0);
      expect(result.totalSessionsToday, 0);
      expect(result.averageOccupancy, 0.0);
      expect(result.totalTicketsSold, 0);
    });

    test('should handle integer values for double fields', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'activeSessionsToday': 3,
        'upcomingSessions': 5,
        'totalSessionsToday': 8,
        'averageOccupancy': 75,
        'totalTicketsSold': 150,
      };

      // Act
      final result = SessionSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result.averageOccupancy, 75.0);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tSessionSummaryModel.toJson();

      // Assert
      final expectedMap = {
        'activeSessionsToday': 3,
        'upcomingSessions': 5,
        'totalSessionsToday': 8,
        'averageOccupancy': 75.5,
        'totalTicketsSold': 150,
      };
      expect(result, equals(expectedMap));
    });
  });

  group('fromEntity', () {
    test('should convert SessionSummary entity to SessionSummaryModel', () {
      // Arrange
      const tSessionSummary = SessionSummary(
        activeSessionsToday: 3,
        upcomingSessions: 5,
        totalSessionsToday: 8,
        averageOccupancy: 75.5,
        totalTicketsSold: 150,
      );

      // Act
      final result = SessionSummaryModel.fromEntity(tSessionSummary);

      // Assert
      expect(result, equals(tSessionSummaryModel));
    });
  });
}
