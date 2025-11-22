/// Mock response data structure
class MockResponse {
  final dynamic data;
  final int statusCode;
  final String? statusMessage;

  const MockResponse({
    required this.data,
    this.statusCode = 200,
    this.statusMessage,
  });
}

/// Mock responses manager for integration tests
class MockResponses {
  final Map<String, MockResponse> _responses = {};

  /// Add a mock response for a specific endpoint
  void addResponse(String method, String path, MockResponse response) {
    final key = _createKey(method, path);
    _responses[key] = response;
  }

  /// Get mock response for a specific endpoint
  MockResponse? getResponse(String method, String path) {
    final key = _createKey(method, path);
    return _responses[key];
  }

  /// Clear all mock responses
  void clear() {
    _responses.clear();
  }

  /// Create key for storing responses
  String _createKey(String method, String path) {
    return '$method:$path';
  }
}

/// Predefined mock responses for authentication flow
class AuthMockResponses {
  static const successfulLoginResponse = {
    'success': true,
    'data': {
      'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.token',
      'employee': {
        'cpf': '123.456.789-00',
        'companyId': 'company-uuid-123',
        'employeeId': 'EMP001',
        'role': 'CASHIER',
        'fullName': 'John Doe',
        'email': 'john.doe@cinema.com',
        'isActive': true
      }
    }
  };

  static const invalidCredentialsResponse = {
    'success': false,
    'message': 'Credenciais inválidas'
  };

  static const unauthorizedResponse = {
    'success': false,
    'message': 'Não autorizado'
  };

  static const serverErrorResponse = {
    'success': false,
    'message': 'Erro interno do servidor'
  };
}

/// Predefined mock responses for dashboard flow
class DashboardMockResponses {
  static const salesSummaryResponse = {
    'success': true,
    'data': {
      'todayRevenue': 15420.50,
      'todayTransactions': 127,
      'weekRevenue': 89350.75,
      'weekTransactions': 654,
      'monthRevenue': 345120.00,
      'monthTransactions': 2847,
      'lastMonthRevenue': 312450.00,
      'lastMonthTransactions': 2654,
      'growthPercentage': 10.45
    }
  };

  static const sessionsResponse = {
    'success': true,
    'data': [
      {
        'id': 'session-uuid-1',
        'movieId': 'movie-uuid-1',
        'movieTitle': 'Inception',
        'roomId': 'room-uuid-1',
        'roomName': 'Sala 1',
        'startTime': '2025-12-15T14:00:00Z',
        'endTime': '2025-12-15T16:30:00Z',
        'language': 'Português',
        'subtitles': 'Inglês',
        'format': '2D',
        'basePrice': 35.00,
        'totalSeats': 100,
        'availableSeats': 45,
        'reservedSeats': 10,
        'soldSeats': 45,
        'status': 'SCHEDULED'
      }
    ]
  };

  static const lowStockResponse = {
    'success': true,
    'data': [
      {
        'sku': 'PROD-001',
        'name': 'Pipoca Grande',
        'currentStock': 5,
        'minStock': 10,
        'category': 'FOOD'
      }
    ]
  };

  static const expiringItemsResponse = {
    'success': true,
    'data': [
      {
        'sku': 'PROD-002',
        'name': 'Refrigerante 500ml',
        'expirationDate': '2024-01-20T00:00:00Z',
        'currentStock': 15,
        'category': 'BEVERAGE'
      }
    ]
  };

  static const inventoryResponse = {
    'success': true,
    'data': []
  };

  static const customersResponse = {
    'success': true,
    'data': []
  };
}

/// Predefined mock responses for POS flow
class PosMockResponses {
  // GET /api/inventory - Load products
  static const productsResponse = {
    'success': true,
    'data': [
      {
        'sku': 'POPCORN-L',
        'name': 'Pipoca Grande',
        'description': 'Pipoca grande com manteiga',
        'category': 'FOOD',
        'unitPrice': 18.00,
        'costPrice': 5.50,
        'qtyOnHand': 50,
        'minStock': 10,
        'maxStock': 100,
        'isActive': true,
        'unit': 'UNIT',
        'imageUrl': null
      },
      {
        'sku': 'SODA-500',
        'name': 'Refrigerante 500ml',
        'description': 'Refrigerante 500ml variados',
        'category': 'BEVERAGE',
        'unitPrice': 8.00,
        'costPrice': 2.50,
        'qtyOnHand': 80,
        'minStock': 20,
        'maxStock': 150,
        'isActive': true,
        'unit': 'UNIT',
        'imageUrl': null
      }
    ]
  };

  // POST /api/sales - Create new sale
  static const createSaleResponse = {
    'success': true,
    'data': {
      'id': 'sale-uuid-123',
      'saleNumber': 'SALE-20240115-001',
      'cashierCpf': '123.456.789-00',
      'customerCpf': null,
      'status': 'OPEN',
      'type': 'CONCESSION',
      'items': [],
      'payments': [],
      'subtotal': 0.00,
      'discountAmount': 0.00,
      'grandTotal': 0.00,
      'totalPaid': 0.00,
      'changeAmount': 0.00,
      'createdAt': '2024-01-15T10:30:00Z'
    }
  };

  // POST /api/sales/{saleId}/items - Add item to cart
  static const addItemResponse = {
    'success': true,
    'data': {
      'id': 'item-uuid-1',
      'saleId': 'sale-uuid-123',
      'sku': 'POPCORN-L',
      'name': 'Pipoca Grande',
      'quantity': 2,
      'unitPrice': 18.00,
      'subtotal': 36.00,
      'discount': 0.00,
      'total': 36.00
    }
  };

  // POST /api/sales/discount/validate - Validate discount code
  static const validateDiscountSuccessResponse = {
    'success': true,
    'data': {
      'code': 'PROMO10',
      'type': 'PERCENTAGE',
      'value': 10.0,
      'isValid': true,
      'minPurchaseAmount': 20.00,
      'maxDiscountAmount': 50.00,
      'discountAmount': 1.80  // 10% of 18.00
    }
  };

  static const validateDiscountErrorResponse = {
    'success': false,
    'message': 'Código de desconto inválido ou expirado'
  };

  // POST /api/sales/{saleId}/discount - Apply discount to sale
  static const applyDiscountResponse = {
    'success': true,
    'data': {
      'id': 'sale-uuid-123',
      'saleNumber': 'SALE-20240115-001',
      'companyId': 'company-uuid-123',
      'cashierCpf': '123.456.789-00',
      'customerCpf': null,
      'status': 'OPEN',
      'type': 'CONCESSION',
      'items': [
        {
          'id': 'item-uuid-1',
          'saleId': 'sale-uuid-123',
          'sku': 'POPCORN-L',
          'description': 'Pipoca Grande',
          'quantity': 1,
          'unitPrice': 18.00,
          'totalPrice': 18.00,
          'sessionId': null,
          'seatId': null,
          'createdAt': '2024-01-15T10:31:00Z',
        }
      ],
      'payments': [],
      'subtotal': 18.00,
      'discountAmount': 1.80,
      'discountCode': 'PROMO10',
      'grandTotal': 16.20,
      'totalPaid': 0.00,
      'changeAmount': 0.00,
      'createdAt': '2024-01-15T10:30:00Z',
      'completedAt': null,
    }
  };

  // POST /api/sales/{saleId}/payments - Add payment to sale
  static const addPaymentResponse = {
    'success': true,
    'data': {
      'id': 'payment-uuid-1',
      'saleId': 'sale-uuid-123',
      'method': 'CASH',
      'amount': 40.00,
      'status': 'COMPLETED',
      'createdAt': '2024-01-15T10:35:00Z'
    }
  };

  // POST /api/sales/{saleId}/finalize - Finalize sale
  static const finalizeSaleResponse = {
    'success': true,
    'data': {
      'id': 'sale-uuid-123',
      'saleNumber': 'SALE-20240115-001',
      'companyId': 'company-uuid-123',
      'cashierCpf': '123.456.789-00',
      'customerCpf': null,
      'status': 'COMPLETED',
      'type': 'CONCESSION',
      'items': [
        {
          'id': 'item-uuid-1',
          'saleId': 'sale-uuid-123',
          'sku': 'POPCORN-L',
          'description': 'Pipoca Grande',
          'quantity': 1,
          'unitPrice': 18.00,
          'totalPrice': 18.00,
          'sessionId': null,
          'seatId': null,
          'createdAt': '2024-01-15T10:31:00Z',
        }
      ],
      'payments': [
        {
          'id': 'payment-uuid-1',
          'saleId': 'sale-uuid-123',
          'method': 'CASH',
          'amount': 40.00,
          'authCode': null,
          'status': 'COMPLETED',
          'createdAt': '2024-01-15T10:35:00Z'
        }
      ],
      'subtotal': 18.00,
      'discountAmount': 0.00,
      'discountCode': null,
      'grandTotal': 18.00,
      'totalPaid': 40.00,
      'changeAmount': 22.00,
      'createdAt': '2024-01-15T10:30:00Z',
      'completedAt': '2024-01-15T10:35:30Z'
    }
  };

  // GET /api/sessions/{sessionId}/seats - Get session seat map
  static const getSessionSeatsResponse = {
    'success': true,
    'data': {
      'session': {
        'id': 'session-uuid-1',
        'movieId': 'movie-uuid-1',
        'movieTitle': 'Inception',
        'roomId': 'room-uuid-1',
        'roomName': 'Sala 1',
        'startTime': '2025-12-15T14:00:00Z',
        'endTime': '2025-12-15T16:30:00Z',
        'language': 'Português',
        'subtitles': 'Inglês',
        'format': '2D',
        'basePrice': 35.00,
        'totalSeats': 100,
        'availableSeats': 45,
        'reservedSeats': 10,
        'soldSeats': 45,
        'status': 'SCHEDULED'
      },
      'seats': [
        {
          'id': 'seat-a1',
          'sessionId': 'session-uuid-1',
          'seatNumber': 'A1',
          'row': 'A',
          'column': 1,
          'type': 'REGULAR',
          'price': 35.00,
          'status': 'AVAILABLE',
          'isAccessible': false
        },
        {
          'id': 'seat-a2',
          'sessionId': 'session-uuid-1',
          'seatNumber': 'A2',
          'row': 'A',
          'column': 2,
          'type': 'REGULAR',
          'price': 35.00,
          'status': 'AVAILABLE',
          'isAccessible': false
        },
        {
          'id': 'seat-a3',
          'sessionId': 'session-uuid-1',
          'seatNumber': 'A3',
          'row': 'A',
          'column': 3,
          'type': 'REGULAR',
          'price': 35.00,
          'status': 'RESERVED',
          'isAccessible': false
        },
      ]
    }
  };

  // POST /api/sessions - Create new session
  static const createSessionResponse = {
    'success': true,
    'data': {
      'id': 'session-uuid-new',
      'movieId': 'movie-uuid-1',
      'movieTitle': 'Inception',
      'roomId': 'room-uuid-1',
      'roomName': 'Sala 1',
      'startTime': '2025-12-16T20:00:00Z',
      'endTime': '2025-12-16T22:28:00Z',
      'language': 'Português',
      'subtitles': 'Inglês',
      'format': '2D',
      'basePrice': 35.00,
      'totalSeats': 100,
      'availableSeats': 100,
      'status': 'SCHEDULED'
    }
  };

  // PUT /api/sessions/{sessionId} - Update session
  static const updateSessionResponse = {
    'success': true,
    'data': {
      'id': 'session-uuid-1',
      'startTime': '2025-12-15T15:00:00Z',
      'status': 'SCHEDULED'
    }
  };

  // DELETE /api/sessions/{sessionId} - Delete session
  static const deleteSessionResponse = {
    'success': true,
    'message': 'Sessão deletada com sucesso'
  };

  // GET /api/movies - Get movies list
  static const moviesResponse = {
    'success': true,
    'data': [
      {
        'id': 'movie-uuid-1',
        'title': 'Inception',
        'durationMin': 148,
        'genre': 'Sci-Fi',
        'rating': 'PG-13',
        'isActive': true
      },
      {
        'id': 'movie-uuid-2',
        'title': 'The Matrix',
        'durationMin': 136,
        'genre': 'Sci-Fi',
        'rating': 'R',
        'isActive': true
      }
    ]
  };

  // GET /api/rooms - Get rooms list
  static const roomsResponse = {
    'success': true,
    'data': [
      {
        'id': 'room-uuid-1',
        'name': 'Sala 1',
        'capacity': 100,
        'roomType': 'STANDARD',
        'isActive': true
      },
      {
        'id': 'room-uuid-2',
        'name': 'Sala 2',
        'capacity': 150,
        'roomType': 'PREMIUM',
        'isActive': true
      }
    ]
  };

  // GET /api/sales/{saleId} - Get sale details
  static getSaleResponse(String saleId, {
    List items = const [],
    List payments = const [],
    double subtotal = 0.0,
    double discountAmount = 0.0,
    String discountCode = '',
  }) {
    final grandTotal = subtotal - discountAmount;
    final totalPaid = payments.fold<double>(0.0, (sum, p) => sum + (p['amount'] as double));

    return {
      'success': true,
      'data': {
        'id': saleId,
        'saleNumber': 'SALE-20240115-001',
        'cashierCpf': '123.456.789-00',
        'customerCpf': null,
        'status': totalPaid >= grandTotal ? 'COMPLETED' : 'OPEN',
        'type': 'CONCESSION',
        'items': items,
        'payments': payments,
        'subtotal': subtotal,
        'discountAmount': discountAmount,
        'discountCode': discountCode,
        'grandTotal': grandTotal,
        'totalPaid': totalPaid,
        'changeAmount': totalPaid > grandTotal ? totalPaid - grandTotal : 0.0,
        'createdAt': '2024-01-15T10:30:00Z'
      }
    };
  }
}
