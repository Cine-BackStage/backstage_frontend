import 'package:dio/dio.dart';
import '../../../../adapters/http/http_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/logger_service.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../models/sale_item_model.dart';
import '../models/payment_model.dart';
import '../../domain/entities/payment.dart';

/// POS remote datasource abstract interface
abstract class PosRemoteDataSource {
  /// Get all products (inventory items)
  Future<List<ProductModel>> getProducts();

  /// Create a new sale
  Future<SaleModel> createSale({String? buyerCpf});

  /// Get sale by ID
  Future<SaleModel> getSaleById(String saleId);

  /// Add item to sale
  Future<SaleItemModel> addItemToSale({
    required String saleId,
    String? sku,
    String? sessionId,
    String? seatId,
    required String description,
    required int quantity,
    required double unitPrice,
  });

  /// Remove item from sale
  Future<void> removeItemFromSale({
    required String saleId,
    required String itemId,
  });

  /// Validate discount code without applying
  Future<Map<String, dynamic>> validateDiscount({
    required String code,
    required double subtotal,
  });

  /// Apply discount code to sale
  Future<SaleModel> applyDiscount({
    required String saleId,
    required String code,
  });

  /// Add payment to sale
  Future<PaymentModel> addPayment({
    required String saleId,
    required PaymentMethod method,
    required double amount,
    String? authCode,
  });

  /// Remove payment from sale
  Future<void> removePayment({
    required String saleId,
    required String paymentId,
  });

  /// Finalize sale
  Future<SaleModel> finalizeSale(String saleId);

  /// Cancel sale
  Future<SaleModel> cancelSale(String saleId);
}

/// POS remote datasource implementation
class PosRemoteDataSourceImpl implements PosRemoteDataSource {
  final HttpClient client;
  final logger = LoggerService();

  PosRemoteDataSourceImpl(this.client);

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      logger.logDataSourceRequest('POSDataSource', 'getProducts', null);
      final response = await client.get(ApiConstants.inventory);

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to get products',
        );
      }

      final data = response.data['data'] as List;
      final products = data
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return products;
    } catch (e, stackTrace) {
      logger.logDataSourceError('POSDataSource', 'getProducts', e, stackTrace);
      throw AppException(message: 'Failed to get products: $e');
    }
  }

  @override
  Future<SaleModel> createSale({String? buyerCpf}) async {
    try {
      final data = {
        if (buyerCpf != null) 'buyerCpf': buyerCpf,
      };
      logger.logDataSourceRequest('POSDataSource', 'createSale', data);
      final response = await client.post(
        ApiConstants.sales,
        data: data,
      );

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to create sale',
        );
      }

      final sale = SaleModel.fromJson(response.data['data']);
      return sale;
    } catch (e, stackTrace) {
      logger.logDataSourceError('POSDataSource', 'createSale', e, stackTrace);
      throw AppException(message: 'Failed to create sale: $e');
    }
  }

  @override
  Future<SaleModel> getSaleById(String saleId) async {
    try {
      logger.logDataSourceRequest('POSDataSource', 'getSaleById', {'saleId': saleId});
      final response = await client.get(ApiConstants.saleDetails(saleId));

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to get sale',
        );
      }

      return SaleModel.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      logger.logDataSourceError('POSDataSource', 'getSaleById', e, stackTrace);
      throw AppException(message: 'Failed to get sale: $e');
    }
  }

  @override
  Future<SaleItemModel> addItemToSale({
    required String saleId,
    String? sku,
    String? sessionId,
    String? seatId,
    required String description,
    required int quantity,
    required double unitPrice,
  }) async {
    try {
      final data = {
        'saleId': saleId,
        if (sku != null) 'sku': sku,
        if (sessionId != null) 'sessionId': sessionId,
        if (seatId != null) 'seatId': seatId,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
      logger.logDataSourceRequest('POSDataSource', 'addItemToSale', data);
      final response = await client.post(
        ApiConstants.saleItems(saleId),
        data: {
          if (sku != null) 'sku': sku,
          if (sessionId != null) 'sessionId': sessionId,
          if (seatId != null) 'seatId': seatId,
          'description': description,
          'quantity': quantity,
          'unitPrice': unitPrice,
        },
      );

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to add item',
        );
      }

      try {
        return SaleItemModel.fromJson(response.data['data']);
      } catch (parseError, stackTrace) {
        logger.logDataSourceError('POSDataSource', 'addItemToSale', parseError, stackTrace);
        throw AppException(
          message: 'Failed to parse item response: $parseError',
        );
      }
    } on DioException catch (dioError, stackTrace) {
      logger.logDataSourceError('POSDataSource', 'addItemToSale', dioError, stackTrace);

      final statusCode = dioError.response?.statusCode;
      final message = dioError.response?.data?['message'] ?? 'Failed to add item';

      throw AppException(
        message: message,
        statusCode: statusCode,
      );
    } catch (e, stackTrace) {
      logger.logDataSourceError('POSDataSource', 'addItemToSale', e, stackTrace);
      throw AppException(message: 'Failed to add item: $e');
    }
  }

  @override
  Future<void> removeItemFromSale({
    required String saleId,
    required String itemId,
  }) async {
    try {
      logger.logDataSourceRequest('POSDataSource', 'removeItemFromSale', {'saleId': saleId, 'itemId': itemId});
      final response = await client.delete(
        ApiConstants.saleItemRemove(saleId, itemId),
      );

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to remove item',
        );
      }
    } catch (e, stackTrace) {
      logger.logDataSourceError('POSDataSource', 'removeItemFromSale', e, stackTrace);
      throw AppException(message: 'Failed to remove item: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> validateDiscount({
    required String code,
    required double subtotal,
  }) async {
    try {
      final data = {
        'code': code,
        'subtotal': subtotal,
      };
      logger.logDataSourceRequest('POSDataSource', 'validateDiscount', data);
      final response = await client.post(
        ApiConstants.saleDiscountValidate,
        data: data,
      );

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to validate discount',
        );
      }

      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (dioError, stackTrace) {
      logger.logDataSourceError('POSDataSource', 'validateDiscount', dioError, stackTrace);
      final message = dioError.response?.data?['message'] ?? 'Failed to validate discount';
      throw AppException(message: message);
    } catch (e, stackTrace) {
      logger.logDataSourceError('POSDataSource', 'validateDiscount', e, stackTrace);
      throw AppException(message: 'Failed to validate discount: $e');
    }
  }

  @override
  Future<SaleModel> applyDiscount({
    required String saleId,
    required String code,
  }) async {
    try {
      final data = {'saleId': saleId, 'code': code};
      logger.logDataSourceRequest('POSDataSource', 'applyDiscount', data);
      final response = await client.post(
        ApiConstants.saleDiscount(saleId),
        data: {'code': code},
      );

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to apply discount',
        );
      }

      return SaleModel.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      logger.logDataSourceError('POSDataSource', 'applyDiscount', e, stackTrace);
      throw AppException(message: 'Failed to apply discount: $e');
    }
  }

  @override
  Future<PaymentModel> addPayment({
    required String saleId,
    required PaymentMethod method,
    required double amount,
    String? authCode,
  }) async {
    try {
      final data = {
        'saleId': saleId,
        'method': method.value,
        'amount': amount,
        if (authCode != null) 'authCode': authCode,
      };
      logger.logDataSourceRequest('POSDataSource', 'addPayment', data);
      final response = await client.post(
        ApiConstants.salePayments(saleId),
        data: {
          'method': method.value,
          'amount': amount,
          if (authCode != null) 'authCode': authCode,
        },
      );

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to add payment',
        );
      }

      return PaymentModel.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      logger.logDataSourceError('POSDataSource', 'addPayment', e, stackTrace);
      throw AppException(message: 'Failed to add payment: $e');
    }
  }

  @override
  Future<void> removePayment({
    required String saleId,
    required String paymentId,
  }) async {
    try {
      logger.logDataSourceRequest('POSDataSource', 'removePayment', {'saleId': saleId, 'paymentId': paymentId});
      final response = await client.delete(
        '${ApiConstants.salePayments(saleId)}/$paymentId',
      );

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to remove payment',
        );
      }
    } catch (e, stackTrace) {
      logger.logDataSourceError('POSDataSource', 'removePayment', e, stackTrace);
      throw AppException(message: 'Failed to remove payment: $e');
    }
  }

  @override
  Future<SaleModel> finalizeSale(String saleId) async {
    try {
      logger.logDataSourceRequest('POSDataSource', 'finalizeSale', {'saleId': saleId});
      final response = await client.post(ApiConstants.saleFinalize(saleId));

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to finalize sale',
        );
      }

      return SaleModel.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      logger.logDataSourceError('POSDataSource', 'finalizeSale', e, stackTrace);
      throw AppException(message: 'Failed to finalize sale: $e');
    }
  }

  @override
  Future<SaleModel> cancelSale(String saleId) async {
    try {
      logger.logDataSourceRequest('POSDataSource', 'cancelSale', {'saleId': saleId});
      final response = await client.post(ApiConstants.saleCancel(saleId));

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to cancel sale',
        );
      }

      return SaleModel.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      logger.logDataSourceError('POSDataSource', 'cancelSale', e, stackTrace);
      throw AppException(message: 'Failed to cancel sale: $e');
    }
  }
}
