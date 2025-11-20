import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../pos/domain/entities/product.dart';
import '../repositories/inventory_repository.dart';

/// Get all inventory items use case
abstract class GetInventoryUseCase {
  Future<Either<Failure, List<Product>>> call(NoParams params);
}

class GetInventoryUseCaseImpl implements GetInventoryUseCase {
  final InventoryRepository repository;

  GetInventoryUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) async {
    return await repository.getInventory();
  }
}
