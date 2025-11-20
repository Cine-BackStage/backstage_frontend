import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../pos/domain/entities/product.dart';
import '../repositories/inventory_repository.dart';

/// Get product details use case
abstract class GetProductDetailsUseCase {
  Future<Either<Failure, Product>> call(GetProductDetailsParams params);
}

class GetProductDetailsUseCaseImpl implements GetProductDetailsUseCase {
  final InventoryRepository repository;

  GetProductDetailsUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Product>> call(GetProductDetailsParams params) async {
    return await repository.getProductDetails(params.sku);
  }
}

class GetProductDetailsParams {
  final String sku;

  GetProductDetailsParams({required this.sku});
}
