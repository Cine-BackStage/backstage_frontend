import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../pos/domain/entities/product.dart';
import '../repositories/inventory_repository.dart';

/// Create product use case
abstract class CreateProductUseCase {
  Future<Either<Failure, Product>> call(CreateProductParams params);
}

class CreateProductUseCaseImpl implements CreateProductUseCase {
  final InventoryRepository repository;

  CreateProductUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Product>> call(CreateProductParams params) async {
    return await repository.createProduct(
      sku: params.sku,
      name: params.name,
      unitPrice: params.unitPrice,
      category: params.category,
      initialStock: params.initialStock,
      barcode: params.barcode,
    );
  }
}

class CreateProductParams {
  final String sku;
  final String name;
  final double unitPrice;
  final String category;
  final int initialStock;
  final String? barcode;

  CreateProductParams({
    required this.sku,
    required this.name,
    required this.unitPrice,
    required this.category,
    required this.initialStock,
    this.barcode,
  });
}
