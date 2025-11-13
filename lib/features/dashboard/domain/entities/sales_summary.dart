import 'package:equatable/equatable.dart';

/// Sales summary entity
class SalesSummary extends Equatable {
  final double todayRevenue;
  final int todayTransactions;
  final double averageTicketPrice;
  final double weekRevenue;
  final double monthRevenue;
  final double growthPercentage;

  const SalesSummary({
    required this.todayRevenue,
    required this.todayTransactions,
    required this.averageTicketPrice,
    required this.weekRevenue,
    required this.monthRevenue,
    required this.growthPercentage,
  });

  @override
  List<Object?> get props => [
        todayRevenue,
        todayTransactions,
        averageTicketPrice,
        weekRevenue,
        monthRevenue,
        growthPercentage,
      ];
}
