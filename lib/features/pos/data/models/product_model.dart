import '../../domain/entities/product.dart';

/// Product data model
class ProductModel extends Product {
  const ProductModel({
    required super.sku,
    required super.name,
    required super.unitPrice,
    required super.category,
    required super.qtyOnHand,
    super.barcode,
    super.isActive,
  });

  /// Create from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely get string value
    String safeString(String key, [String defaultValue = '']) {
      final value = json[key];
      if (value == null) return defaultValue;
      return value.toString();
    }

    // Handle both food and collectable items
    final bool isFood = json['food'] != null;
    final itemData = isFood ? json['food'] : json['collectable'];

    String category = 'Other';
    if (isFood && itemData != null) {
      category = itemData['category'] ?? 'Snacks';
    } else if (itemData != null) {
      category = 'Collectables';
    }

    return ProductModel(
      sku: safeString('sku'),
      name: safeString('name', 'Unknown Product'),
      unitPrice: _parseDecimal(json['unitPrice']),
      category: category,
      qtyOnHand: _parseInt(json['qtyOnHand']),
      barcode: json['barcode'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'name': name,
      'unitPrice': unitPrice,
      'category': category,
      'qtyOnHand': qtyOnHand,
      'barcode': barcode,
      'isActive': isActive,
    };
  }

  /// Parse decimal/string to double
  static double _parseDecimal(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Parse int/string to int
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Convert to domain entity
  Product toEntity() {
    return Product(
      sku: sku,
      name: name,
      unitPrice: unitPrice,
      category: category,
      qtyOnHand: qtyOnHand,
      barcode: barcode,
      isActive: isActive,
    );
  }
}
