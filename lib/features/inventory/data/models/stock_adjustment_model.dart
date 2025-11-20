import '../../domain/entities/stock_adjustment.dart';

/// Stock adjustment model
class StockAdjustmentModel extends StockAdjustment {
  const StockAdjustmentModel({
    required super.id,
    required super.sku,
    required super.productName,
    required super.type,
    required super.quantityBefore,
    required super.quantityAfter,
    required super.quantityChanged,
    super.reason,
    super.notes,
    required super.employeeName,
    required super.timestamp,
  });

  factory StockAdjustmentModel.fromJson(Map<String, dynamic> json) {
    return StockAdjustmentModel(
      id: json['id'] as String,
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      type: _parseAdjustmentType(json['adjustmentType'] as String),
      quantityBefore: json['qtyBefore'] as int,
      quantityAfter: json['qtyAfter'] as int,
      quantityChanged: json['qtyChanged'] as int,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      employeeName: json['employeeName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static AdjustmentType _parseAdjustmentType(String type) {
    switch (type.toUpperCase()) {
      case 'ADDITION':
        return AdjustmentType.addition;
      case 'REMOVAL':
        return AdjustmentType.removal;
      case 'CORRECTION':
        return AdjustmentType.correction;
      case 'DAMAGE':
        return AdjustmentType.damage;
      case 'EXPIRY':
        return AdjustmentType.expiry;
      case 'TRANSFER':
        return AdjustmentType.transfer;
      default:
        return AdjustmentType.correction;
    }
  }
}
