import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/inventory_repository.dart';

/// Adjust stock use case
abstract class AdjustStockUseCase {
  Future<Either<Failure, void>> call(AdjustStockParams params);
}

class AdjustStockUseCaseImpl implements AdjustStockUseCase {
  final InventoryRepository repository;

  AdjustStockUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(AdjustStockParams params) async {
    return await repository.adjustStock(
      sku: params.sku,
      quantity: params.quantity,
      reason: params.reason,
      notes: params.notes,
    );
  }
}

class AdjustStockParams {
  final String sku;
  final int quantity;
  final String reason;
  final String? notes;

  AdjustStockParams({
    required this.sku,
    required this.quantity,
    required this.reason,
    this.notes,
  });
}
