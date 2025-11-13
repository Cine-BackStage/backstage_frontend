import '../../domain/entities/sale_item.dart';

/// Sale item data model
class SaleItemModel extends SaleItem {
  const SaleItemModel({
    required super.id,
    required super.saleId,
    super.sku,
    super.sessionId,
    super.seatId,
    required super.description,
    required super.quantity,
    required super.unitPrice,
    required super.totalPrice,
    required super.createdAt,
  });

  /// Create from JSON
  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely get string value
    String safeString(String key, [String defaultValue = '']) {
      final value = json[key];
      if (value == null) return defaultValue;
      return value.toString();
    }

    // Helper to safely get int value
    int safeInt(String key, [int defaultValue = 0]) {
      final value = json[key];
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    // Debug logging for price fields
    print('[SaleItemModel] Parsing item: ${json['description']}');
    print('[SaleItemModel] unitPrice raw: ${json['unitPrice']} (${json['unitPrice'].runtimeType})');
    print('[SaleItemModel] totalPrice raw: ${json['totalPrice']} (${json['totalPrice'].runtimeType})');

    final unitPrice = _parseDecimal(json['unitPrice']);
    final quantity = safeInt('quantity', 1);

    // Calculate totalPrice if not provided by backend
    final totalPrice = json['totalPrice'] != null
        ? _parseDecimal(json['totalPrice'])
        : unitPrice * quantity;

    print('[SaleItemModel] unitPrice parsed: $unitPrice');
    print('[SaleItemModel] quantity: $quantity');
    print('[SaleItemModel] totalPrice parsed: $totalPrice');

    return SaleItemModel(
      id: safeString('id'),
      saleId: safeString('saleId'),
      sku: json['sku'] as String?,
      sessionId: json['sessionId'] as String?,
      seatId: json['seatId'] as String?,
      description: safeString('description'),
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'saleId': saleId,
      if (sku != null) 'sku': sku,
      if (sessionId != null) 'sessionId': sessionId,
      if (seatId != null) 'seatId': seatId,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Parse decimal/string to double
  static double _parseDecimal(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Convert to domain entity
  SaleItem toEntity() {
    return SaleItem(
      id: id,
      saleId: saleId,
      sku: sku,
      sessionId: sessionId,
      seatId: seatId,
      description: description,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      createdAt: createdAt,
    );
  }
}
