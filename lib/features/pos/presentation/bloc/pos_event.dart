import 'package:equatable/equatable.dart';
import '../../domain/entities/payment.dart';

/// POS events
abstract class PosEvent extends Equatable {
  const PosEvent();

  @override
  List<Object?> get props => [];
}

/// Load available products
class LoadProducts extends PosEvent {
  const LoadProducts();
}

/// Create a new sale
class CreateSale extends PosEvent {
  final String? buyerCpf;

  const CreateSale({this.buyerCpf});

  @override
  List<Object?> get props => [buyerCpf];
}

/// Load existing sale
class LoadSale extends PosEvent {
  final String saleId;

  const LoadSale({required this.saleId});

  @override
  List<Object?> get props => [saleId];
}

/// Add item to cart
class AddItemToCart extends PosEvent {
  final String productSku;
  final String description;
  final double unitPrice;
  final int quantity;
  final String? sessionId;
  final String? seatId;

  const AddItemToCart({
    required this.productSku,
    required this.description,
    required this.unitPrice,
    this.quantity = 1,
    this.sessionId,
    this.seatId,
  });

  @override
  List<Object?> get props => [
        productSku,
        description,
        unitPrice,
        quantity,
        sessionId,
        seatId,
      ];
}

/// Remove item from cart
class RemoveItemFromCart extends PosEvent {
  final String itemId;

  const RemoveItemFromCart({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

/// Apply discount code
class ApplyDiscount extends PosEvent {
  final String code;

  const ApplyDiscount({required this.code});

  @override
  List<Object?> get props => [code];
}

/// Add payment to sale
class AddPayment extends PosEvent {
  final PaymentMethod method;
  final double amount;
  final String? authCode;

  const AddPayment({
    required this.method,
    required this.amount,
    this.authCode,
  });

  @override
  List<Object?> get props => [method, amount, authCode];
}

/// Remove payment from sale
class RemovePayment extends PosEvent {
  final String paymentId;

  const RemovePayment({required this.paymentId});

  @override
  List<Object?> get props => [paymentId];
}

/// Finalize sale (complete transaction)
class FinalizeSale extends PosEvent {
  const FinalizeSale();
}

/// Cancel sale
class CancelSale extends PosEvent {
  const CancelSale();
}

/// Reset to initial state
class ResetPos extends PosEvent {
  const ResetPos();
}
