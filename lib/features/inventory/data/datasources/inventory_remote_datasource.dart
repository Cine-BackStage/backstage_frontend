import 'package:dio/dio.dart';
import '../../../../adapters/http/http_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/logger_service.dart';
import '../../../pos/data/models/product_model.dart';
import '../models/stock_adjustment_model.dart';

/// Inventory remote data source interface
abstract class InventoryRemoteDataSource {
  Future<List<ProductModel>> getInventory();
  Future<ProductModel> getProductDetails(String sku);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<ProductModel>> getLowStockProducts();
  Future<void> adjustStock({
    required String sku,
    required int quantity,
    required String reason,
    String? notes,
  });
  Future<List<StockAdjustmentModel>> getAdjustmentHistory({
    String? sku,
    int limit = 50,
  });
  Future<ProductModel> createProduct({
    required String sku,
    required String name,
    required double unitPrice,
    required String category,
    required int initialStock,
    String? barcode,
  });
  Future<ProductModel> updateProduct({
    required String sku,
    String? name,
    double? unitPrice,
    String? category,
    String? barcode,
  });
  Future<void> toggleProductStatus(String sku, bool isActive);
}

/// Inventory remote data source implementation
class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final HttpClient client;
  final logger = LoggerService();

  InventoryRemoteDataSourceImpl(this.client);

  /// Map frontend reason to backend enum
  String _mapReasonToBackend(String reason) {
    switch (reason) {
      case 'Reestoque':
        return 'RESTOCK';
      case 'Dano':
        return 'DAMAGE';
      case 'Roubo':
        return 'THEFT';
      case 'Vencimento':
        return 'EXPIRY';
      case 'Devolução':
        return 'RETURN';
      case 'Correção de Contagem':
        return 'COUNT_CORRECTION';
      case 'Ajuste de estoque':
        return 'COUNT_CORRECTION';
      case 'Outro':
        return 'OTHER';
      default:
        return 'OTHER';
    }
  }

  @override
  Future<List<ProductModel>> getInventory() async {
    try {
      final response = await client.get(
        ApiConstants.inventory,
        queryParameters: {'isActive': true},
      );

      if (response.data['success'] == true) {
        final products = (response.data['data'] as List)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return products;
      } else {
        throw AppException(
          message: response.data['message'] ?? 'Failed to fetch inventory',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      logger.logDataSourceError('InventoryDataSource', 'getInventory', e, stackTrace);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<ProductModel> getProductDetails(String sku) async {
    try {
      final response = await client.get(ApiConstants.inventoryDetails(sku));

      if (response.data['success'] == true) {
        return ProductModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw AppException(
          message: response.data['message'] ?? 'Failed to fetch product details',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      logger.logDataSourceError('InventoryDataSource', 'getProductDetails', e, stackTrace);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await client.get(
        ApiConstants.inventory,
        queryParameters: {
          'search': query,
          'isActive': true,
        },
      );

      if (response.data['success'] == true) {
        final products = (response.data['data'] as List)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return products;
      } else {
        throw AppException(
          message: response.data['message'] ?? 'Failed to search products',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      logger.logDataSourceError('InventoryDataSource', 'searchProducts', e, stackTrace);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      final response = await client.get(ApiConstants.inventoryLowStock);

      if (response.data['success'] == true) {
        final products = (response.data['data'] as List)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Filter to only show products with quantity <= reorderLevel
        final lowStockProducts = products.where((p) => p.qtyOnHand <= p.reorderLevel).toList();
        return lowStockProducts;
      } else {
        throw AppException(
          message: response.data['message'] ?? 'Failed to fetch low stock products',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      logger.logDataSourceError('InventoryDataSource', 'getLowStockProducts', e, stackTrace);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<void> adjustStock({
    required String sku,
    required int quantity,
    required String reason,
    String? notes,
  }) async {
    try {
      final endpoint = ApiConstants.inventoryAdjust(sku);
      final requestData = {
        'delta': quantity,
        'reason': _mapReasonToBackend(reason),
        if (notes != null) 'notes': notes,
      };

      logger.logDataSourceRequest('InventoryDataSource', 'adjustStock', requestData);

      final response = await client.post(endpoint, data: requestData);

      if (response.data['success'] != true) {
        final errorMessage = response.data['message'] ?? 'Failed to adjust stock';
        throw AppException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e, stackTrace) {
      logger.logDataSourceError('InventoryDataSource', 'adjustStock', e, stackTrace);

      final errorMessage = e.response?.data?['message'] ??
                          e.response?.data?['error'] ??
                          'Failed to adjust stock';

      throw AppException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      logger.logDataSourceError('InventoryDataSource', 'adjustStock', e, stackTrace);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<List<StockAdjustmentModel>> getAdjustmentHistory({
    String? sku,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        if (sku != null) 'sku': sku,
      };

      final response = await client.get(
        ApiConstants.inventoryAdjustmentHistory,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final adjustments = (response.data['data'] as List)
            .map((json) => StockAdjustmentModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return adjustments;
      } else {
        throw AppException(
          message: response.data['message'] ?? 'Failed to fetch adjustment history',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      logger.logDataSourceError('InventoryDataSource', 'getAdjustmentHistory', e, stackTrace);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<ProductModel> createProduct({
    required String sku,
    required String name,
    required double unitPrice,
    required String category,
    required int initialStock,
    String? barcode,
  }) async {
    try {
      // Determine item type based on category
      String itemType = 'general';
      if (category.toLowerCase() == 'snacks' ||
          category.toLowerCase() == 'bebidas' ||
          category.toLowerCase() == 'alimentos') {
        itemType = 'food';
      } else if (category.toLowerCase() == 'colecionáveis' ||
                 category.toLowerCase() == 'brinquedos') {
        itemType = 'collectable';
      }

      final requestData = {
        'sku': sku,
        'name': name,
        'unitPrice': unitPrice,
        'qtyOnHand': initialStock,
        'reorderLevel': 10, // Default reorder level
        'itemType': itemType,
        // Add category based on item type
        if (itemType == 'food') 'foodCategory': category,
        if (itemType == 'collectable') 'collectableCategory': category,
        if (barcode != null && barcode.isNotEmpty) 'barcode': barcode,
      };

      logger.logDataSourceRequest('InventoryDataSource', 'createProduct', requestData);

      final response = await client.post(
        ApiConstants.inventory,
        data: requestData,
      );

      if (response.data['success'] == true) {
        return ProductModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw AppException(
          message: response.data['message'] ?? 'Failed to create product',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      logger.logDataSourceError('InventoryDataSource', 'createProduct', e, stackTrace);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<ProductModel> updateProduct({
    required String sku,
    String? name,
    double? unitPrice,
    String? category,
    String? barcode,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (unitPrice != null) data['unitPrice'] = unitPrice;
      if (category != null) data['category'] = category;
      if (barcode != null) data['barcode'] = barcode;

      logger.logDataSourceRequest('InventoryDataSource', 'updateProduct', data);

      final response = await client.put(
        ApiConstants.inventoryDetails(sku),
        data: data,
      );

      if (response.data['success'] == true) {
        return ProductModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw AppException(
          message: response.data['message'] ?? 'Failed to update product',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      logger.logDataSourceError('InventoryDataSource', 'updateProduct', e, stackTrace);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<void> toggleProductStatus(String sku, bool isActive) async {
    try {
      final endpoint = isActive
          ? ApiConstants.inventoryActivate(sku)
          : ApiConstants.inventoryDeactivate(sku);

      logger.logDataSourceRequest('InventoryDataSource', 'toggleProductStatus', {
        'sku': sku,
        'isActive': isActive,
      });

      final response = await client.patch(endpoint);

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to toggle product status',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e, stackTrace) {
      logger.logDataSourceError('InventoryDataSource', 'toggleProductStatus', e, stackTrace);

      final errorMessage = e.response?.data?['message'] ??
                          e.response?.data?['error'] ??
                          'Failed to toggle product status';

      throw AppException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      logger.logDataSourceError('InventoryDataSource', 'toggleProductStatus', e, stackTrace);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(message: e.toString());
    }
  }
}
