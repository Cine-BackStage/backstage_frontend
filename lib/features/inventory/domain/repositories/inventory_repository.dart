import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../pos/domain/entities/product.dart';
import '../entities/stock_adjustment.dart';

/// Inventory repository interface
abstract class InventoryRepository {
  /// Get all inventory items
  Future<Either<Failure, List<Product>>> getInventory();

  /// Get product details by SKU
  Future<Either<Failure, Product>> getProductDetails(String sku);

  /// Search products by query
  Future<Either<Failure, List<Product>>> searchProducts(String query);

  /// Get low stock products
  Future<Either<Failure, List<Product>>> getLowStockProducts();

  /// Adjust stock for a product
  Future<Either<Failure, void>> adjustStock({
    required String sku,
    required int quantity,
    required String reason,
    String? notes,
  });

  /// Get stock adjustment history
  Future<Either<Failure, List<StockAdjustment>>> getAdjustmentHistory({
    String? sku,
    int limit = 50,
  });

  /// Create new product
  Future<Either<Failure, Product>> createProduct({
    required String sku,
    required String name,
    required double unitPrice,
    required String category,
    required int initialStock,
    String? barcode,
  });

  /// Update product
  Future<Either<Failure, Product>> updateProduct({
    required String sku,
    String? name,
    double? unitPrice,
    String? category,
    String? barcode,
  });

  /// Activate/Deactivate product
  Future<Either<Failure, void>> toggleProductStatus(String sku, bool isActive);
}
