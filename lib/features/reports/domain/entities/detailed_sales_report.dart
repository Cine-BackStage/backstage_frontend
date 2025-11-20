import 'package:equatable/equatable.dart';

/// Detailed sales report entity
class DetailedSalesReport extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final String groupBy;
  final ReportSummary summary;
  final List<SalesGroupData> groupedData;

  const DetailedSalesReport({
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

/// Report summary
class ReportSummary extends Equatable {
  final int totalSales;
  final double totalRevenue;
  final double totalDiscount;
  final double averageSaleValue;

  const ReportSummary({
    required this.totalSales,
    required this.totalRevenue,
    required this.totalDiscount,
    required this.averageSaleValue,
  });

  @override
  List<Object?> get props => [
        totalSales,
        totalRevenue,
        totalDiscount,
        averageSaleValue,
      ];
}

/// Sales group data
class SalesGroupData extends Equatable {
  final String key;
  final String label;
  final int salesCount;
  final double revenue;

  const SalesGroupData({
    required this.key,
    required this.label,
    required this.salesCount,
    required this.revenue,
  });

  @override
  List<Object?> get props => [key, label, salesCount, revenue];
}
