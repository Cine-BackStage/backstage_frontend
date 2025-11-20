import 'package:equatable/equatable.dart';

/// Stock adjustment types
enum AdjustmentType {
  addition,
  removal,
  correction,
  damage,
  expiry,
  transfer,
}

/// Stock adjustment entity
class StockAdjustment extends Equatable {
  final String id;
  final String sku;
  final String productName;
  final AdjustmentType type;
  final int quantityBefore;
  final int quantityAfter;
  final int quantityChanged;
  final String? reason;
  final String? notes;
  final String employeeName;
  final DateTime timestamp;

  const StockAdjustment({
    required this.id,
    required this.sku,
    required this.productName,
    required this.type,
    required this.quantityBefore,
    required this.quantityAfter,
    required this.quantityChanged,
    this.reason,
    this.notes,
    required this.employeeName,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        sku,
        productName,
        type,
        quantityBefore,
        quantityAfter,
        quantityChanged,
        reason,
        notes,
        employeeName,
        timestamp,
      ];
}
