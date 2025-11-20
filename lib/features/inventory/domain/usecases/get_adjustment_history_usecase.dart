import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/stock_adjustment.dart';
import '../repositories/inventory_repository.dart';

/// Get adjustment history use case
abstract class GetAdjustmentHistoryUseCase {
  Future<Either<Failure, List<StockAdjustment>>> call(GetAdjustmentHistoryParams params);
}

class GetAdjustmentHistoryUseCaseImpl implements GetAdjustmentHistoryUseCase {
  final InventoryRepository repository;

  GetAdjustmentHistoryUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, List<StockAdjustment>>> call(GetAdjustmentHistoryParams params) async {
    return await repository.getAdjustmentHistory(
      sku: params.sku,
      limit: params.limit,
    );
  }
}

class GetAdjustmentHistoryParams {
  final String? sku;
  final int limit;

  GetAdjustmentHistoryParams({
    this.sku,
    this.limit = 50,
  });
}
