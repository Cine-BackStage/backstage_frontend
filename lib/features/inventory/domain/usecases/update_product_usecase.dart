import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../pos/domain/entities/product.dart';
import '../repositories/inventory_repository.dart';

/// Update product use case
abstract class UpdateProductUseCase {
  Future<Either<Failure, Product>> call(UpdateProductParams params);
}

class UpdateProductUseCaseImpl implements UpdateProductUseCase {
  final InventoryRepository repository;

  UpdateProductUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Product>> call(UpdateProductParams params) async {
    return await repository.updateProduct(
      sku: params.sku,
      name: params.name,
      unitPrice: params.unitPrice,
      category: params.category,
      barcode: params.barcode,
    );
  }
}

class UpdateProductParams {
  final String sku;
  final String? name;
  final double? unitPrice;
  final String? category;
  final String? barcode;

  UpdateProductParams({
    required this.sku,
    this.name,
    this.unitPrice,
    this.category,
    this.barcode,
  });
}
