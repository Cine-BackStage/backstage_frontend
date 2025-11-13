import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/pos_repository.dart';
import '../datasources/pos_remote_datasource.dart';

/// POS repository implementation
class PosRepositoryImpl implements PosRepository {
  final PosRemoteDataSource remoteDataSource;

  PosRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return Right(products.map((model) => model.toEntity()).toList());
    } on AppException catch (e) {
      return Left(GenericFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Sale>> createSale({String? buyerCpf}) async {
    try {
      final sale = await remoteDataSource.createSale(buyerCpf: buyerCpf);
      return Right(sale.toEntity());
    } on AppException catch (e) {
      return Left(GenericFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Sale>> getSaleById(String saleId) async {
    try {
      final sale = await remoteDataSource.getSaleById(saleId);
      return Right(sale.toEntity());
    } on AppException catch (e) {
      return Left(GenericFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SaleItem>> addItemToSale({
    required String saleId,
    String? sku,
    String? sessionId,
    String? seatId,
    required String description,
    required int quantity,
    required double unitPrice,
  }) async {
    try {
      final item = await remoteDataSource.addItemToSale(
        saleId: saleId,
        sku: sku,
        sessionId: sessionId,
        seatId: seatId,
        description: description,
        quantity: quantity,
        unitPrice: unitPrice,
      );
      return Right(item.toEntity());
    } on AppException catch (e) {
      return Left(GenericFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeItemFromSale({
    required String saleId,
    required String itemId,
  }) async {
    try {
      await remoteDataSource.removeItemFromSale(
        saleId: saleId,
        itemId: itemId,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(GenericFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> validateDiscount({
    required String code,
    required double subtotal,
  }) async {
    try {
      final discountData = await remoteDataSource.validateDiscount(
        code: code,
        subtotal: subtotal,
      );
      return Right(discountData);
    } on AppException catch (e) {
      return Left(GenericFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Sale>> applyDiscount({
    required String saleId,
    required String code,
  }) async {
    try {
      final sale = await remoteDataSource.applyDiscount(
        saleId: saleId,
        code: code,
      );
      return Right(sale.toEntity());
    } on AppException catch (e) {
      return Left(GenericFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Payment>> addPayment({
    required String saleId,
    required PaymentMethod method,
    required double amount,
    String? authCode,
  }) async {
    try {
      final payment = await remoteDataSource.addPayment(
        saleId: saleId,
        method: method,
        amount: amount,
        authCode: authCode,
      );
      return Right(payment.toEntity());
    } on AppException catch (e) {
      return Left(GenericFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removePayment({
    required String saleId,
    required String paymentId,
  }) async {
    try {
      await remoteDataSource.removePayment(
        saleId: saleId,
        paymentId: paymentId,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(GenericFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Sale>> finalizeSale(String saleId) async {
    try {
      final sale = await remoteDataSource.finalizeSale(saleId);
      return Right(sale.toEntity());
    } on AppException catch (e) {
      return Left(GenericFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Sale>> cancelSale(String saleId) async {
    try {
      final sale = await remoteDataSource.cancelSale(saleId);
      return Right(sale.toEntity());
    } on AppException catch (e) {
      return Left(GenericFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: 'Unexpected error: $e'));
    }
  }
}
