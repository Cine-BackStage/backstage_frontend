import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../pos/domain/entities/product.dart';
import '../repositories/inventory_repository.dart';

/// Get low stock products use case
abstract class GetLowStockUseCase {
  Future<Either<Failure, List<Product>>> call(NoParams params);
}

class GetLowStockUseCaseImpl implements GetLowStockUseCase {
  final InventoryRepository repository;

  GetLowStockUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) async {
    return await repository.getLowStockProducts();
  }
}
