import '../../domain/entities/session_summary.dart';

/// Session summary data model
class SessionSummaryModel extends SessionSummary {
  const SessionSummaryModel({
    required super.activeSessionsToday,
    required super.upcomingSessions,
    required super.totalSessionsToday,
    required super.averageOccupancy,
    required super.totalTicketsSold,
  });

  /// Create from JSON (backend response)
  factory SessionSummaryModel.fromJson(Map<String, dynamic> json) {
    return SessionSummaryModel(
      activeSessionsToday: (json['activeSessionsToday'] as int?) ?? 0,
      upcomingSessions: (json['upcomingSessions'] as int?) ?? 0,
      totalSessionsToday: (json['totalSessionsToday'] as int?) ?? 0,
      averageOccupancy: (json['averageOccupancy'] as num?)?.toDouble() ?? 0.0,
      totalTicketsSold: (json['totalTicketsSold'] as int?) ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'activeSessionsToday': activeSessionsToday,
      'upcomingSessions': upcomingSessions,
      'totalSessionsToday': totalSessionsToday,
      'averageOccupancy': averageOccupancy,
      'totalTicketsSold': totalTicketsSold,
    };
  }

  /// Create from domain entity
  factory SessionSummaryModel.fromEntity(SessionSummary entity) {
    return SessionSummaryModel(
      activeSessionsToday: entity.activeSessionsToday,
      upcomingSessions: entity.upcomingSessions,
      totalSessionsToday: entity.totalSessionsToday,
      averageOccupancy: entity.averageOccupancy,
      totalTicketsSold: entity.totalTicketsSold,
    );
  }
}
