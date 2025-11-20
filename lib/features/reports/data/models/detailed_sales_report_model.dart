import '../../domain/entities/detailed_sales_report.dart';

/// Detailed sales report model
class DetailedSalesReportModel extends DetailedSalesReport {
  const DetailedSalesReportModel({
    required super.startDate,
    required super.endDate,
    required super.groupBy,
    required super.summary,
    required super.groupedData,
  });

  factory DetailedSalesReportModel.fromJson(Map<String, dynamic> json) {
    final period = json['period'] as Map<String, dynamic>? ?? {};
    final summaryJson = json['summary'] as Map<String, dynamic>? ?? {};
    final groupedDataJson = json['groupedData'] as List? ?? [];

    return DetailedSalesReportModel(
      startDate: DateTime.parse(period['startDate'] as String),
      endDate: DateTime.parse(period['endDate'] as String),
      groupBy: period['groupBy'] as String? ?? json['groupBy'] as String? ?? 'day',
      summary: ReportSummaryModel.fromJson(summaryJson),
      groupedData: groupedDataJson
          .map((item) => SalesGroupDataModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Report summary model
class ReportSummaryModel extends ReportSummary {
  const ReportSummaryModel({
    required super.totalSales,
    required super.totalRevenue,
    required super.totalDiscount,
    required super.averageSaleValue,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      totalSales: (json['totalSales'] ?? 0) as int,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalDiscount: (json['totalDiscount'] ?? 0).toDouble(),
      averageSaleValue: (json['averageSaleValue'] ?? 0).toDouble(),
    );
  }
}

/// Sales group data model
class SalesGroupDataModel extends SalesGroupData {
  const SalesGroupDataModel({
    required super.key,
    required super.label,
    required super.salesCount,
    required super.revenue,
  });

  factory SalesGroupDataModel.fromJson(Map<String, dynamic> json) {
    // Handle different grouping structures
    String key;
    String label;

    if (json.containsKey('cashierCpf')) {
      // Grouped by cashier
      key = json['cashierCpf'] as String;
      label = json['cashierName'] as String? ?? key;
    } else if (json.containsKey('method')) {
      // Grouped by payment method
      key = json['method'] as String;
      label = _formatPaymentMethod(key);
    } else if (json.containsKey('date')) {
      // Grouped by day
      key = json['date'] as String;
      label = key;
    } else {
      key = json['key'] as String? ?? 'unknown';
      label = json['label'] as String? ?? key;
    }

    return SalesGroupDataModel(
      key: key,
      label: label,
      salesCount: (json['salesCount'] ?? json['count'] ?? 0) as int,
      revenue: (json['revenue'] ?? json['total'] ?? 0).toDouble(),
    );
  }

  static String _formatPaymentMethod(String method) {
    switch (method.toUpperCase()) {
      case 'CASH':
        return 'Dinheiro';
      case 'CREDIT_CARD':
        return 'Cartão de Crédito';
      case 'DEBIT_CARD':
        return 'Cartão de Débito';
      case 'PIX':
        return 'PIX';
      default:
        return method;
    }
  }
}
