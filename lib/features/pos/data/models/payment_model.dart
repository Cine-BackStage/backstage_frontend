import '../../domain/entities/payment.dart';

/// Payment data model
class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.saleId,
    required super.method,
    required super.amount,
    super.authCode,
    required super.createdAt,
  });

  /// Create from JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely get string value
    String safeString(String key, [String defaultValue = '']) {
      final value = json[key];
      if (value == null) return defaultValue;
      return value.toString();
    }

    return PaymentModel(
      id: safeString('id'),
      saleId: safeString('saleId'),
      method: PaymentMethod.fromString(safeString('method', 'CASH')),
      amount: _parseDecimal(json['amount']),
      authCode: json['authCode'] as String?,
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
      'method': method.value,
      'amount': amount,
      if (authCode != null) 'authCode': authCode,
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
  Payment toEntity() {
    return Payment(
      id: id,
      saleId: saleId,
      method: method,
      amount: amount,
      authCode: authCode,
      createdAt: createdAt,
    );
  }
}
