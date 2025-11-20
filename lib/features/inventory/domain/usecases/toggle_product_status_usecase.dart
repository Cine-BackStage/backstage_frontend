import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/inventory_repository.dart';

/// Toggle product status use case
abstract class ToggleProductStatusUseCase {
  Future<Either<Failure, void>> call(ToggleProductStatusParams params);
}

class ToggleProductStatusUseCaseImpl implements ToggleProductStatusUseCase {
  final InventoryRepository repository;

  ToggleProductStatusUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleProductStatusParams params) async {
    return await repository.toggleProductStatus(params.sku, params.isActive);
  }
}

class ToggleProductStatusParams {
  final String sku;
  final bool isActive;

  ToggleProductStatusParams({
    required this.sku,
    required this.isActive,
  });
}
