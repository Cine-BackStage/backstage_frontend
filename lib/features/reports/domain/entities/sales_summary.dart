import 'package:equatable/equatable.dart';

/// Sales summary entity
class SalesSummary extends Equatable {
  final double todayRevenue;
  final int todayTransactions;
  final double weekRevenue;
  final int weekTransactions;
  final double monthRevenue;
  final int monthTransactions;
  final double lastMonthRevenue;
  final int lastMonthTransactions;
  final double growthPercentage;

  const SalesSummary({
    required this.todayRevenue,
    required this.todayTransactions,
    required this.weekRevenue,
    required this.weekTransactions,
    required this.monthRevenue,
    required this.monthTransactions,
    required this.lastMonthRevenue,
    required this.lastMonthTransactions,
    required this.growthPercentage,
  });

  @override
  List<Object?> get props => [
        todayRevenue,
        todayTransactions,
        weekRevenue,
        weekTransactions,
        monthRevenue,
        monthTransactions,
        lastMonthRevenue,
        lastMonthTransactions,
        growthPercentage,
      ];
}
