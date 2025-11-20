import 'package:equatable/equatable.dart';

/// Ticket sales report entity
class TicketSalesReport extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final String groupBy;
  final TicketReportSummary summary;
  final List<TicketGroupData> groupedData;

  const TicketSalesReport({
    required this.startDate,
    required this.endDate,
    required this.groupBy,
    required this.summary,
    required this.groupedData,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        groupBy,
        summary,
        groupedData,
      ];
}

/// Ticket report summary
class TicketReportSummary extends Equatable {
  final int totalTickets;
  final double totalRevenue;
  final double averageTicketPrice;
  final int cancelledTickets;

  const TicketReportSummary({
    required this.totalTickets,
    required this.totalRevenue,
    required this.averageTicketPrice,
    required this.cancelledTickets,
  });

  @override
  List<Object?> get props => [
        totalTickets,
        totalRevenue,
        averageTicketPrice,
        cancelledTickets,
      ];
}

/// Ticket group data
class TicketGroupData extends Equatable {
  final String key;
  final String label;
  final int ticketCount;
  final double revenue;

  const TicketGroupData({
    required this.key,
    required this.label,
    required this.ticketCount,
    required this.revenue,
  });

  @override
  List<Object?> get props => [key, label, ticketCount, revenue];
}
