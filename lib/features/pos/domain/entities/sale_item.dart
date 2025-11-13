import 'package:equatable/equatable.dart';

/// Sale item entity
class SaleItem extends Equatable {
  final String id;
  final String saleId;
  final String? sku;
  final String? sessionId;
  final String? seatId;
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime createdAt;

  const SaleItem({
    required this.id,
    required this.saleId,
    this.sku,
    this.sessionId,
    this.seatId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
  });

  /// Check if this is a product item
  bool get isProduct => sku != null;

  /// Check if this is a ticket item
  bool get isTicket => sessionId != null && seatId != null;

  /// Copy with method
  SaleItem copyWith({
    String? id,
    String? saleId,
    String? sku,
    String? sessionId,
    String? seatId,
    String? description,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    DateTime? createdAt,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      sku: sku ?? this.sku,
      sessionId: sessionId ?? this.sessionId,
      seatId: seatId ?? this.seatId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        saleId,
        sku,
        sessionId,
        seatId,
        description,
        quantity,
        unitPrice,
        totalPrice,
        createdAt,
      ];
}
