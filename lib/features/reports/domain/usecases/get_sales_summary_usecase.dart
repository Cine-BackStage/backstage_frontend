import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sales_summary.dart';
import '../repositories/reports_repository.dart';

/// Get sales summary use case interface
abstract class GetSalesSummaryUseCase {
  Future<Either<Failure, SalesSummary>> call(NoParams params);
}

/// Get sales summary use case implementation
class GetSalesSummaryUseCaseImpl implements GetSalesSummaryUseCase {
  final ReportsRepository repository;

  GetSalesSummaryUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, SalesSummary>> call(NoParams params) async {
    return await repository.getSalesSummary();
  }
}
