import 'package:dartz/dartz.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../pos/domain/entities/product.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';

/// Inventory repository implementation
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Product>>> getInventory() async {
    try {
      final products = await remoteDataSource.getInventory();
      return Right(products);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductDetails(String sku) async {
    try {
      final product = await remoteDataSource.getProductDetails(sku);
      return Right(product);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      final products = await remoteDataSource.searchProducts(query);
      return Right(products);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getLowStockProducts() async {
    try {
      final products = await remoteDataSource.getLowStockProducts();
      return Right(products);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> adjustStock({
    required String sku,
    required int quantity,
    required String reason,
    String? notes,
  }) async {
    try {
      print('[Inventory Repository] Adjusting stock - SKU: $sku, Quantity: $quantity, Reason: $reason, Notes: $notes');
      await remoteDataSource.adjustStock(
        sku: sku,
        quantity: quantity,
        reason: reason,
        notes: notes,
      );
      print('[Inventory Repository] Stock adjustment successful');
      return const Right(null);
    } catch (e) {
      print('[Inventory Repository Error] Stock adjustment failed: ${e.toString()}');
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<StockAdjustment>>> getAdjustmentHistory({
    String? sku,
    int limit = 50,
  }) async {
    try {
      final adjustments = await remoteDataSource.getAdjustmentHistory(
        sku: sku,
        limit: limit,
      );
      return Right(adjustments);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct({
    required String sku,
    required String name,
    required double unitPrice,
    required String category,
    required int initialStock,
    String? barcode,
  }) async {
    try {
      final product = await remoteDataSource.createProduct(
        sku: sku,
        name: name,
        unitPrice: unitPrice,
        category: category,
        initialStock: initialStock,
        barcode: barcode,
      );
      return Right(product);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct({
    required String sku,
    String? name,
    double? unitPrice,
    String? category,
    String? barcode,
  }) async {
    try {
      final product = await remoteDataSource.updateProduct(
        sku: sku,
        name: name,
        unitPrice: unitPrice,
        category: category,
        barcode: barcode,
      );
      return Right(product);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> toggleProductStatus(
    String sku,
    bool isActive,
  ) async {
    try {
      await remoteDataSource.toggleProductStatus(sku, isActive);
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }
}
