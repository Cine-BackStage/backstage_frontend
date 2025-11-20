import 'package:equatable/equatable.dart';

/// Product entity
class Product extends Equatable {
  final String sku;
  final String name;
  final double unitPrice;
  final String category;
  final int qtyOnHand;
  final int reorderLevel;
  final String? barcode;
  final bool isActive;
  final DateTime? expiryDate;

  const Product({
    required this.sku,
    required this.name,
    required this.unitPrice,
    required this.category,
    required this.qtyOnHand,
    required this.reorderLevel,
    this.barcode,
    this.isActive = true,
    this.expiryDate,
  });

  /// Check if product is available for sale
  bool get isAvailable => isActive && qtyOnHand > 0;

  /// Check if product is low stock
  bool get isLowStock => qtyOnHand <= reorderLevel;

  /// Check if product is expired
  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());

  /// Check if product is expiring soon (within 7 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate!.difference(now).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= 7;
  }

  @override
  List<Object?> get props => [
        sku,
        name,
        unitPrice,
        category,
        qtyOnHand,
        reorderLevel,
        barcode,
        isActive,
        expiryDate,
      ];
}
