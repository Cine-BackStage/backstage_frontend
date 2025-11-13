import '../../domain/entities/sale.dart';
import 'sale_item_model.dart';
import 'payment_model.dart';

/// Sale data model
class SaleModel extends Sale {
  const SaleModel({
    required super.id,
    required super.companyId,
    required super.cashierCpf,
    super.buyerCpf,
    required super.createdAt,
    required super.status,
    required super.subtotal,
    required super.discountAmount,
    required super.grandTotal,
    super.items,
    super.payments,
    super.discountCode,
  });

  /// Create from JSON
  factory SaleModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely get string value
    String safeString(String key, [String defaultValue = '']) {
      final value = json[key];
      if (value == null) return defaultValue;
      return value.toString();
    }

    print('[SaleModel] Parsing sale with ${(json['items'] as List?)?.length ?? 0} items');
    print('[SaleModel] Sale totals - subtotal: ${json['subtotal']}, discount: ${json['discountAmount']}, grandTotal: ${json['grandTotal']}');

    // Parse items first
    final items = (json['items'] as List?)
            ?.map((item) => SaleItemModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    // Calculate subtotal from items if not provided by backend
    final calculatedSubtotal = items.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    final subtotal = json['subtotal'] != null
        ? _parseDecimal(json['subtotal'])
        : calculatedSubtotal;

    final discountAmount = _parseDecimal(json['discountAmount']);
    final grandTotal = _parseDecimal(json['grandTotal']);

    print('[SaleModel] Calculated subtotal: $calculatedSubtotal');
    print('[SaleModel] Final subtotal: $subtotal, discount: $discountAmount, grandTotal: $grandTotal');

    return SaleModel(
      id: safeString('id'),
      companyId: safeString('companyId'),
      cashierCpf: safeString('cashierCpf'),
      buyerCpf: json['buyerCpf'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      status: safeString('status', 'OPEN'),
      subtotal: subtotal,
      discountAmount: discountAmount,
      grandTotal: grandTotal,
      items: items,
      payments: (json['payments'] as List?)
              ?.map((payment) => PaymentModel.fromJson(payment as Map<String, dynamic>))
              .toList() ??
          [],
      discountCode: json['discountCode'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'cashierCpf': cashierCpf,
      if (buyerCpf != null) 'buyerCpf': buyerCpf,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'grandTotal': grandTotal,
      'items': items.map((item) {
        if (item is SaleItemModel) {
          return item.toJson();
        }
        return SaleItemModel(
          id: item.id,
          saleId: item.saleId,
          sku: item.sku,
          sessionId: item.sessionId,
          seatId: item.seatId,
          description: item.description,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalPrice: item.totalPrice,
          createdAt: item.createdAt,
        ).toJson();
      }).toList(),
      'payments': payments.map((payment) {
        if (payment is PaymentModel) {
          return payment.toJson();
        }
        return PaymentModel(
          id: payment.id,
          saleId: payment.saleId,
          method: payment.method,
          amount: payment.amount,
          authCode: payment.authCode,
          createdAt: payment.createdAt,
        ).toJson();
      }).toList(),
      if (discountCode != null) 'discountCode': discountCode,
    };
  }

  /// Parse decimal/string to double
  static double _parseDecimal(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Convert to domain entity
  Sale toEntity() {
    return Sale(
      id: id,
      companyId: companyId,
      cashierCpf: cashierCpf,
      buyerCpf: buyerCpf,
      createdAt: createdAt,
      status: status,
      subtotal: subtotal,
      discountAmount: discountAmount,
      grandTotal: grandTotal,
      items: items,
      payments: payments,
      discountCode: discountCode,
    );
  }
}
