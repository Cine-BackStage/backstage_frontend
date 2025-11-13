import 'package:equatable/equatable.dart';

/// Session summary entity
class SessionSummary extends Equatable {
  final int activeSessionsToday;
  final int upcomingSessions;
  final int totalSessionsToday;
  final double averageOccupancy;
  final int totalTicketsSold;

  const SessionSummary({
    required this.activeSessionsToday,
    required this.upcomingSessions,
    required this.totalSessionsToday,
    required this.averageOccupancy,
    required this.totalTicketsSold,
  });

  @override
  List<Object?> get props => [
        activeSessionsToday,
        upcomingSessions,
        totalSessionsToday,
        averageOccupancy,
        totalTicketsSold,
      ];
}
