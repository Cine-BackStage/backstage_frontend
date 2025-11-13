import 'package:dio/dio.dart';
import '../../../../adapters/http/http_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
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

  PosRemoteDataSourceImpl(this.client);

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      print('[POS Remote] Getting products');
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

      print('[POS Remote] Got ${products.length} products');
      return products;
    } catch (e) {
      print('[POS Remote] Get products error: $e');
      throw AppException(message: 'Failed to get products: $e');
    }
  }

  @override
  Future<SaleModel> createSale({String? buyerCpf}) async {
    try {
      print('[POS Remote] Creating sale');
      final response = await client.post(
        ApiConstants.sales,
        data: {
          if (buyerCpf != null) 'buyerCpf': buyerCpf,
        },
      );

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to create sale',
        );
      }

      final sale = SaleModel.fromJson(response.data['data']);
      print('[POS Remote] Sale created: ${sale.id}');
      return sale;
    } catch (e) {
      print('[POS Remote] Create sale error: $e');
      throw AppException(message: 'Failed to create sale: $e');
    }
  }

  @override
  Future<SaleModel> getSaleById(String saleId) async {
    try {
      print('[POS Remote] Getting sale: $saleId');
      final response = await client.get(ApiConstants.saleDetails(saleId));

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to get sale',
        );
      }

      print('[POS Remote] Sale response: ${response.data['data']}');
      if (response.data['data']['items'] != null) {
        print('[POS Remote] Sale items: ${response.data['data']['items']}');
      }

      return SaleModel.fromJson(response.data['data']);
    } catch (e) {
      print('[POS Remote] Get sale error: $e');
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
      print('[POS Remote] Adding item to sale: $saleId');
      print('[POS Remote] Request data: sku=$sku, sessionId=$sessionId, seatId=$seatId');
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

      print('[POS Remote] Add item response: ${response.data}');

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to add item',
        );
      }

      try {
        print('[POS Remote] Parsing item data: ${response.data['data']}');
        return SaleItemModel.fromJson(response.data['data']);
      } catch (parseError) {
        print('[POS Remote] Parse error: $parseError');
        print('[POS Remote] Raw data: ${response.data['data']}');
        throw AppException(
          message: 'Failed to parse item response: $parseError',
        );
      }
    } on DioException catch (dioError) {
      print('[POS Remote] Add item Dio error: ${dioError.message}');
      print('[POS Remote] Status code: ${dioError.response?.statusCode}');

      final statusCode = dioError.response?.statusCode;
      final message = dioError.response?.data?['message'] ?? 'Failed to add item';

      throw AppException(
        message: message,
        statusCode: statusCode,
      );
    } catch (e) {
      print('[POS Remote] Add item error: $e');
      throw AppException(message: 'Failed to add item: $e');
    }
  }

  @override
  Future<void> removeItemFromSale({
    required String saleId,
    required String itemId,
  }) async {
    try {
      print('[POS Remote] Removing item from sale: $itemId');
      final response = await client.delete(
        ApiConstants.saleItemRemove(saleId, itemId),
      );

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to remove item',
        );
      }
    } catch (e) {
      print('[POS Remote] Remove item error: $e');
      throw AppException(message: 'Failed to remove item: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> validateDiscount({
    required String code,
    required double subtotal,
  }) async {
    try {
      print('[POS Remote] Validating discount: $code');
      final response = await client.post(
        ApiConstants.saleDiscountValidate,
        data: {
          'code': code,
          'subtotal': subtotal,
        },
      );

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to validate discount',
        );
      }

      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (dioError) {
      print('[POS Remote] Validate discount Dio error: ${dioError.message}');
      final message = dioError.response?.data?['message'] ?? 'Failed to validate discount';
      throw AppException(message: message);
    } catch (e) {
      print('[POS Remote] Validate discount error: $e');
      throw AppException(message: 'Failed to validate discount: $e');
    }
  }

  @override
  Future<SaleModel> applyDiscount({
    required String saleId,
    required String code,
  }) async {
    try {
      print('[POS Remote] Applying discount: $code');
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
    } catch (e) {
      print('[POS Remote] Apply discount error: $e');
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
      print('[POS Remote] Adding payment: ${method.value}');
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
    } catch (e) {
      print('[POS Remote] Add payment error: $e');
      throw AppException(message: 'Failed to add payment: $e');
    }
  }

  @override
  Future<void> removePayment({
    required String saleId,
    required String paymentId,
  }) async {
    try {
      print('[POS Remote] Removing payment: $paymentId from sale: $saleId');
      final response = await client.delete(
        '${ApiConstants.salePayments(saleId)}/$paymentId',
      );

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to remove payment',
        );
      }
    } catch (e) {
      print('[POS Remote] Remove payment error: $e');
      throw AppException(message: 'Failed to remove payment: $e');
    }
  }

  @override
  Future<SaleModel> finalizeSale(String saleId) async {
    try {
      print('[POS Remote] Finalizing sale: $saleId');
      final response = await client.post(ApiConstants.saleFinalize(saleId));

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to finalize sale',
        );
      }

      return SaleModel.fromJson(response.data['data']);
    } catch (e) {
      print('[POS Remote] Finalize sale error: $e');
      throw AppException(message: 'Failed to finalize sale: $e');
    }
  }

  @override
  Future<SaleModel> cancelSale(String saleId) async {
    try {
      print('[POS Remote] Canceling sale: $saleId');
      final response = await client.post(ApiConstants.saleCancel(saleId));

      if (response.data['success'] != true) {
        throw AppException(
          message: response.data['message'] ?? 'Failed to cancel sale',
        );
      }

      return SaleModel.fromJson(response.data['data']);
    } catch (e) {
      print('[POS Remote] Cancel sale error: $e');
      throw AppException(message: 'Failed to cancel sale: $e');
    }
  }
}
