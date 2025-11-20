import '../../domain/entities/ticket_sales_report.dart';

/// Ticket sales report model
class TicketSalesReportModel extends TicketSalesReport {
  const TicketSalesReportModel({
    required super.startDate,
    required super.endDate,
    required super.groupBy,
    required super.summary,
    required super.groupedData,
  });

  factory TicketSalesReportModel.fromJson(Map<String, dynamic> json) {
    print('[TicketSalesReportModel] Parsing JSON: $json');

    final period = json['period'] as Map<String, dynamic>? ?? {};
    final summaryJson = json['summary'] as Map<String, dynamic>? ?? {};
    final groupedDataJson = json['groupedData'] as List? ?? [];

    print('[TicketSalesReportModel] Period: $period');
    print('[TicketSalesReportModel] Summary: $summaryJson');
    print('[TicketSalesReportModel] GroupedData: $groupedDataJson');

    return TicketSalesReportModel(
      startDate: DateTime.parse(period['startDate'] as String),
      endDate: DateTime.parse(period['endDate'] as String),
      groupBy: period['groupBy'] as String? ?? json['groupBy'] as String? ?? 'day',
      summary: TicketReportSummaryModel.fromJson(summaryJson),
      groupedData: groupedDataJson
          .map((item) => TicketGroupDataModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Ticket report summary model
class TicketReportSummaryModel extends TicketReportSummary {
  const TicketReportSummaryModel({
    required super.totalTickets,
    required super.totalRevenue,
    required super.averageTicketPrice,
    required super.cancelledTickets,
  });

  factory TicketReportSummaryModel.fromJson(Map<String, dynamic> json) {
    print('[TicketReportSummaryModel] Parsing summary: $json');

    final totalTickets = (json['totalTickets'] ?? 0) as int;
    final totalRevenue = (json['totalRevenue'] ?? 0).toDouble();

    // Calculate average if not provided
    final averageTicketPrice = json['averageTicketPrice'] != null
        ? (json['averageTicketPrice'] as num).toDouble()
        : (totalTickets > 0 ? totalRevenue / totalTickets : 0.0);

    // Get cancelled/refunded tickets count from ticketsByStatus or default to 0
    final ticketsByStatus = json['ticketsByStatus'] as Map<String, dynamic>?;
    final cancelledTickets = ticketsByStatus != null
        ? ((ticketsByStatus['refunded'] ?? 0) as int)
        : (json['cancelledTickets'] ?? 0) as int;

    print('[TicketReportSummaryModel] Calculated averageTicketPrice: $averageTicketPrice');
    print('[TicketReportSummaryModel] Cancelled tickets: $cancelledTickets');

    return TicketReportSummaryModel(
      totalTickets: totalTickets,
      totalRevenue: totalRevenue,
      averageTicketPrice: averageTicketPrice,
      cancelledTickets: cancelledTickets,
    );
  }
}

/// Ticket group data model
class TicketGroupDataModel extends TicketGroupData {
  const TicketGroupDataModel({
    required super.key,
    required super.label,
    required super.ticketCount,
    required super.revenue,
  });

  factory TicketGroupDataModel.fromJson(Map<String, dynamic> json) {
    // Handle different grouping structures
    String key;
    String label;

    if (json.containsKey('movieId')) {
      // Grouped by movie
      key = json['movieId'] as String;
      label = json['movieTitle'] as String? ?? key;
    } else if (json.containsKey('employeeCpf')) {
      // Grouped by employee
      key = json['employeeCpf'] as String;
      label = json['employeeName'] as String? ?? key;
    } else if (json.containsKey('date')) {
      // Grouped by day
      key = json['date'] as String;
      label = key;
    } else {
      key = json['key'] as String? ?? 'unknown';
      label = json['label'] as String? ?? key;
    }

    return TicketGroupDataModel(
      key: key,
      label: label,
      ticketCount: (json['ticketCount'] ?? json['count'] ?? 0) as int,
      revenue: (json['revenue'] ?? json['total'] ?? 0).toDouble(),
    );
  }
}
