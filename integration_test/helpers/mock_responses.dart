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
        'startTime': '2024-01-15T14:00:00Z',
        'endTime': '2024-01-15T16:30:00Z',
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
