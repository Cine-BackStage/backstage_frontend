import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../entities/sale.dart';
import '../entities/sale_item.dart';
import '../entities/payment.dart';
import '../repositories/pos_repository.dart';

/// Get products use case
abstract class GetProductsUseCase {
  Future<Either<Failure, List<Product>>> call(NoParams params);
}

class GetProductsUseCaseImpl implements GetProductsUseCase {
  final PosRepository repository;

  GetProductsUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) async {
    return await repository.getProducts();
  }
}

/// Create sale use case
class CreateSaleParams {
  final String? buyerCpf;

  CreateSaleParams({this.buyerCpf});
}

abstract class CreateSaleUseCase {
  Future<Either<Failure, Sale>> call(CreateSaleParams params);
}

class CreateSaleUseCaseImpl implements CreateSaleUseCase {
  final PosRepository repository;

  CreateSaleUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Sale>> call(CreateSaleParams params) async {
    return await repository.createSale(buyerCpf: params.buyerCpf);
  }
}

/// Get sale by ID use case
class GetSaleParams {
  final String saleId;

  GetSaleParams({required this.saleId});
}

abstract class GetSaleUseCase {
  Future<Either<Failure, Sale>> call(GetSaleParams params);
}

class GetSaleUseCaseImpl implements GetSaleUseCase {
  final PosRepository repository;

  GetSaleUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Sale>> call(GetSaleParams params) async {
    return await repository.getSaleById(params.saleId);
  }
}

/// Add item to sale use case
class AddItemParams {
  final String saleId;
  final String? sku;
  final String? sessionId;
  final String? seatId;
  final String description;
  final int quantity;
  final double unitPrice;

  AddItemParams({
    required this.saleId,
    this.sku,
    this.sessionId,
    this.seatId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });
}

abstract class AddItemToSaleUseCase {
  Future<Either<Failure, SaleItem>> call(AddItemParams params);
}

class AddItemToSaleUseCaseImpl implements AddItemToSaleUseCase {
  final PosRepository repository;

  AddItemToSaleUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, SaleItem>> call(AddItemParams params) async {
    return await repository.addItemToSale(
      saleId: params.saleId,
      sku: params.sku,
      sessionId: params.sessionId,
      seatId: params.seatId,
      description: params.description,
      quantity: params.quantity,
      unitPrice: params.unitPrice,
    );
  }
}

/// Remove item from sale use case
class RemoveItemParams {
  final String saleId;
  final String itemId;

  RemoveItemParams({
    required this.saleId,
    required this.itemId,
  });
}

abstract class RemoveItemFromSaleUseCase {
  Future<Either<Failure, void>> call(RemoveItemParams params);
}

class RemoveItemFromSaleUseCaseImpl implements RemoveItemFromSaleUseCase {
  final PosRepository repository;

  RemoveItemFromSaleUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveItemParams params) async {
    return await repository.removeItemFromSale(
      saleId: params.saleId,
      itemId: params.itemId,
    );
  }
}

/// Validate discount use case
class ValidateDiscountParams {
  final String code;
  final double subtotal;

  ValidateDiscountParams({
    required this.code,
    required this.subtotal,
  });
}

abstract class ValidateDiscountUseCase {
  Future<Either<Failure, Map<String, dynamic>>> call(ValidateDiscountParams params);
}

class ValidateDiscountUseCaseImpl implements ValidateDiscountUseCase {
  final PosRepository repository;

  ValidateDiscountUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(ValidateDiscountParams params) async {
    return await repository.validateDiscount(
      code: params.code,
      subtotal: params.subtotal,
    );
  }
}

/// Apply discount use case
class ApplyDiscountParams {
  final String saleId;
  final String code;

  ApplyDiscountParams({
    required this.saleId,
    required this.code,
  });
}

abstract class ApplyDiscountUseCase {
  Future<Either<Failure, Sale>> call(ApplyDiscountParams params);
}

class ApplyDiscountUseCaseImpl implements ApplyDiscountUseCase {
  final PosRepository repository;

  ApplyDiscountUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Sale>> call(ApplyDiscountParams params) async {
    return await repository.applyDiscount(
      saleId: params.saleId,
      code: params.code,
    );
  }
}

/// Add payment use case
class AddPaymentParams {
  final String saleId;
  final PaymentMethod method;
  final double amount;
  final String? authCode;

  AddPaymentParams({
    required this.saleId,
    required this.method,
    required this.amount,
    this.authCode,
  });
}

abstract class AddPaymentUseCase {
  Future<Either<Failure, Payment>> call(AddPaymentParams params);
}

class AddPaymentUseCaseImpl implements AddPaymentUseCase {
  final PosRepository repository;

  AddPaymentUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Payment>> call(AddPaymentParams params) async {
    return await repository.addPayment(
      saleId: params.saleId,
      method: params.method,
      amount: params.amount,
      authCode: params.authCode,
    );
  }
}

/// Remove payment use case
class RemovePaymentParams {
  final String saleId;
  final String paymentId;

  RemovePaymentParams({
    required this.saleId,
    required this.paymentId,
  });
}

abstract class RemovePaymentUseCase {
  Future<Either<Failure, void>> call(RemovePaymentParams params);
}

class RemovePaymentUseCaseImpl implements RemovePaymentUseCase {
  final PosRepository repository;

  RemovePaymentUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(RemovePaymentParams params) async {
    return await repository.removePayment(
      saleId: params.saleId,
      paymentId: params.paymentId,
    );
  }
}

/// Finalize sale use case
class FinalizeSaleParams {
  final String saleId;

  FinalizeSaleParams({required this.saleId});
}

abstract class FinalizeSaleUseCase {
  Future<Either<Failure, Sale>> call(FinalizeSaleParams params);
}

class FinalizeSaleUseCaseImpl implements FinalizeSaleUseCase {
  final PosRepository repository;

  FinalizeSaleUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Sale>> call(FinalizeSaleParams params) async {
    return await repository.finalizeSale(params.saleId);
  }
}

/// Cancel sale use case
class CancelSaleParams {
  final String saleId;

  CancelSaleParams({required this.saleId});
}

abstract class CancelSaleUseCase {
  Future<Either<Failure, Sale>> call(CancelSaleParams params);
}

class CancelSaleUseCaseImpl implements CancelSaleUseCase {
  final PosRepository repository;

  CancelSaleUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Sale>> call(CancelSaleParams params) async {
    return await repository.cancelSale(params.saleId);
  }
}
