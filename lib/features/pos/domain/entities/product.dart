import 'package:equatable/equatable.dart';

/// Product entity
class Product extends Equatable {
  final String sku;
  final String name;
  final double unitPrice;
  final String category;
  final int qtyOnHand;
  final String? barcode;
  final bool isActive;

  const Product({
    required this.sku,
    required this.name,
    required this.unitPrice,
    required this.category,
    required this.qtyOnHand,
    this.barcode,
    this.isActive = true,
  });

  /// Check if product is available for sale
  bool get isAvailable => isActive && qtyOnHand > 0;

  @override
  List<Object?> get props => [
        sku,
        name,
        unitPrice,
        category,
        qtyOnHand,
        barcode,
        isActive,
      ];
}
