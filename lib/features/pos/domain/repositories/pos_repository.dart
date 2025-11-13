import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../entities/sale.dart';
import '../entities/sale_item.dart';
import '../entities/payment.dart';

/// POS repository interface
abstract class PosRepository {
  /// Get all available products
  Future<Either<Failure, List<Product>>> getProducts();

  /// Create a new sale
  Future<Either<Failure, Sale>> createSale({String? buyerCpf});

  /// Get sale by ID
  Future<Either<Failure, Sale>> getSaleById(String saleId);

  /// Add item to sale
  Future<Either<Failure, SaleItem>> addItemToSale({
    required String saleId,
    String? sku,
    String? sessionId,
    String? seatId,
    required String description,
    required int quantity,
    required double unitPrice,
  });

  /// Remove item from sale
  Future<Either<Failure, void>> removeItemFromSale({
    required String saleId,
    required String itemId,
  });

  /// Validate discount code
  Future<Either<Failure, Map<String, dynamic>>> validateDiscount({
    required String code,
    required double subtotal,
  });

  /// Apply discount code to sale
  Future<Either<Failure, Sale>> applyDiscount({
    required String saleId,
    required String code,
  });

  /// Add payment to sale
  Future<Either<Failure, Payment>> addPayment({
    required String saleId,
    required PaymentMethod method,
    required double amount,
    String? authCode,
  });

  /// Remove payment from sale
  Future<Either<Failure, void>> removePayment({
    required String saleId,
    required String paymentId,
  });

  /// Finalize sale (complete transaction)
  Future<Either<Failure, Sale>> finalizeSale(String saleId);

  /// Cancel sale
  Future<Either<Failure, Sale>> cancelSale(String saleId);
}
