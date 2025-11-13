import 'package:equatable/equatable.dart';

/// Payment method enum
enum PaymentMethod {
  cash('CASH', 'Dinheiro'),
  card('CARD', 'Cartão'),
  pix('PIX', 'PIX'),
  other('OTHER', 'Outro');

  final String value;
  final String label;

  const PaymentMethod(this.value, this.label);

  /// Display name for UI
  String get displayName => label;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

/// Payment entity
class Payment extends Equatable {
  final String id;
  final String saleId;
  final PaymentMethod method;
  final double amount;
  final String? authCode;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.saleId,
    required this.method,
    required this.amount,
    this.authCode,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        saleId,
        method,
        amount,
        authCode,
        createdAt,
      ];
}
