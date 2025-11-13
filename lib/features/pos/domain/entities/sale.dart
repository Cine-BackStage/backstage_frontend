import 'package:equatable/equatable.dart';
import 'sale_item.dart';
import 'payment.dart';

/// Sale entity
class Sale extends Equatable {
  final String id;
  final String companyId;
  final String cashierCpf;
  final String? buyerCpf;
  final DateTime createdAt;
  final String status; // OPEN, FINALIZED, CANCELED, REFUNDED
  final double subtotal;
  final double discountAmount;
  final double grandTotal;
  final List<SaleItem> items;
  final List<Payment> payments;
  final String? discountCode;

  const Sale({
    required this.id,
    required this.companyId,
    required this.cashierCpf,
    this.buyerCpf,
    required this.createdAt,
    required this.status,
    required this.subtotal,
    required this.discountAmount,
    required this.grandTotal,
    this.items = const [],
    this.payments = const [],
    this.discountCode,
  });

  /// Check if sale is open
  bool get isOpen => status == 'OPEN';

  /// Check if sale is finalized
  bool get isFinalized => status == 'FINALIZED';

  /// Check if payment is complete
  bool get isPaymentComplete => totalPaid >= grandTotal;

  /// Total amount paid
  double get totalPaid => payments.fold(0.0, (sum, payment) => sum + payment.amount);

  /// Remaining amount to pay
  double get remainingAmount => grandTotal - totalPaid;

  /// Total items count
  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Copy with method
  Sale copyWith({
    String? id,
    String? companyId,
    String? cashierCpf,
    String? buyerCpf,
    DateTime? createdAt,
    String? status,
    double? subtotal,
    double? discountAmount,
    double? grandTotal,
    List<SaleItem>? items,
    List<Payment>? payments,
    String? discountCode,
  }) {
    return Sale(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      cashierCpf: cashierCpf ?? this.cashierCpf,
      buyerCpf: buyerCpf ?? this.buyerCpf,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      discountCode: discountCode ?? this.discountCode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        cashierCpf,
        buyerCpf,
        createdAt,
        status,
        subtotal,
        discountAmount,
        grandTotal,
        items,
        payments,
        discountCode,
      ];
}
