import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../pos/domain/entities/product.dart';
import '../repositories/inventory_repository.dart';

/// Search products use case
abstract class SearchProductsUseCase {
  Future<Either<Failure, List<Product>>> call(SearchProductsParams params);
}

class SearchProductsUseCaseImpl implements SearchProductsUseCase {
  final InventoryRepository repository;

  SearchProductsUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(SearchProductsParams params) async {
    return await repository.searchProducts(params.query);
  }
}

class SearchProductsParams {
  final String query;

  SearchProductsParams({required this.query});
}
