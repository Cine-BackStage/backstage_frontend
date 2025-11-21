# Integration Test Flows - Backstage Cinema Frontend

This document outlines the integration test flows for the Backstage Cinema Flutter application. Each flow includes mocked API responses, widget interactions, and expected outcomes.

## Overview

**Testing Strategy:** Integration tests with mocked HTTP responses using Dio interceptors/mocks.

**Test Framework:** `flutter_test` with `integration_test` package

**Mocking Strategy:** Mock Dio client to intercept HTTP requests and return predefined responses

---

## HTTP Client Architecture

**Location:** `lib/adapters/http/http_client.dart`

**Key Features:**
- Uses Dio for HTTP requests
- Automatic Bearer token injection from LocalStorage
- Automatic 401 handling (clears auth data)
- Base URL configuration (development vs production)
- Request/response logging

**Base URLs:**
- Development: `http://10.0.2.2:3000` (Android) / `http://localhost:3000` (iOS/Web)
- Production: `https://backstagebackend-production.up.railway.app`

---

## Flow 1: Authentication Flow

### Login and Logout Flow

**Priority:** HIGH (Blocks all other features)

**Starting Page:** `lib/features/authentication/presentation/pages/login_page.dart`

#### Steps

1. App starts at splash page
2. User navigates to login page
3. User enters employee ID in `employeeIdField` TextField
4. User enters password in `passwordField` TextField
5. User taps `loginButton` button
6. System shows loading indicator
7. On success, shows snackbar with welcome message
8. Navigates to dashboard page
9. User can logout by tapping `logoutButton` in AppBar

#### Widget Keys Needed

```dart
// LoginPage
Key('employeeIdField')
Key('passwordField')
Key('loginButton')
Key('loginLoadingIndicator')
Key('loginErrorMessage')

// DashboardPage
Key('logoutButton')
Key('profileButton')
```

#### API Endpoints

**POST /api/employees/login**

Request:
```json
{
  "employeeId": "EMP001",
  "password": "password123"
}
```

Success Response (200):
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "employee": {
      "cpf": "123.456.789-00",
      "companyId": "company-uuid",
      "employeeId": "EMP001",
      "role": "CASHIER",
      "fullName": "John Doe",
      "email": "john.doe@cinema.com",
      "isActive": true
    }
  }
}
```

Error Response (401):
```json
{
  "success": false,
  "message": "Credenciais inválidas"
}
```

#### Expected Outcomes

- ✅ Successful login: Token saved, navigate to dashboard, show welcome message
- ❌ Invalid credentials: Show error snackbar, remain on login page
- ❌ Empty fields: Show form validation errors
- ✅ Logout: Clear token, navigate to login page

---

## Flow 2: Dashboard Overview Flow

### Dashboard Data Loading and Navigation

**Priority:** HIGH

**Starting Page:** `lib/features/dashboard/presentation/pages/dashboard_page.dart`

#### Steps

1. Dashboard loads automatically after login
2. System fetches dashboard statistics from multiple endpoints
3. Display sales summary, session summary, and inventory alerts
4. User can pull to refresh data
5. User can navigate to other features via quick action cards

#### Widget Keys Needed

```dart
// DashboardPage
Key('dashboardRefreshIndicator')
Key('dashboardLoadingIndicator')
Key('salesRevenueCard')
Key('transactionsCard')
Key('sessionsCard')
Key('activeCustomersCard')
Key('lowStockAlert')
Key('expiringItemsAlert')
Key('posQuickAction')
Key('sessionsQuickAction')
Key('inventoryQuickAction')
Key('reportsQuickAction')
```

#### API Endpoints

**GET /api/sales/reports/summary**

Success Response (200):
```json
{
  "success": true,
  "data": {
    "todayRevenue": 15420.50,
    "todayTransactions": 127,
    "weekRevenue": 89350.75,
    "weekTransactions": 654,
    "monthRevenue": 345120.00,
    "monthTransactions": 2847,
    "lastMonthRevenue": 312450.00,
    "lastMonthTransactions": 2654,
    "growthPercentage": 10.45
  }
}
```

**GET /api/sessions?startDate=2024-01-15&endDate=2024-01-15**

Success Response (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "session-uuid-1",
      "movieId": "movie-uuid-1",
      "movieTitle": "Inception",
      "roomId": "room-uuid-1",
      "roomName": "Sala 1",
      "startTime": "2024-01-15T14:00:00Z",
      "endTime": "2024-01-15T16:30:00Z",
      "language": "Português",
      "subtitles": "Inglês",
      "format": "2D",
      "basePrice": 35.00,
      "totalSeats": 100,
      "availableSeats": 45,
      "reservedSeats": 10,
      "soldSeats": 45,
      "status": "SCHEDULED"
    }
  ]
}
```

**GET /api/inventory/alerts/low-stock**

Success Response (200):
```json
{
  "success": true,
  "data": [
    {
      "sku": "PROD-001",
      "name": "Pipoca Grande",
      "currentStock": 5,
      "minStock": 10,
      "category": "FOOD"
    }
  ]
}
```

**GET /api/inventory/expiring**

Success Response (200):
```json
{
  "success": true,
  "data": [
    {
      "sku": "PROD-002",
      "name": "Refrigerante 500ml",
      "expirationDate": "2024-01-20T00:00:00Z",
      "currentStock": 15,
      "category": "BEVERAGE"
    }
  ]
}
```

#### Expected Outcomes

- ✅ Display today's revenue and transaction count
- ✅ Show today's sessions count
- ✅ Display inventory alerts (low stock and expiring)
- ✅ Pull-to-refresh updates all statistics
- ✅ Quick actions navigate to respective pages

---

## Flow 3: POS Concession Sale Flow

### Point of Sale - Product Sale with Payment

**Priority:** HIGH (Core revenue feature)

**Starting Page:** `lib/features/pos/presentation/pages/pos_page.dart`

#### Steps

1. User taps `initializePosButton` to load products
2. User taps `newSaleButton` to create a new sale
3. User adds products to cart by selecting from grid
4. User can optionally apply discount code
5. User adds payment(s) (cash, card, PIX)
6. User finalizes sale when payment is complete
7. System shows sale completion dialog
8. User can start new sale

#### Widget Keys Needed

```dart
// PosPage
Key('initializePosButton')
Key('newSaleButton')
Key('cancelSaleButton')
Key('productGrid')
Key('product_${sku}') // Dynamic per product
Key('shoppingCartPanel')
Key('cartItem_${index}') // Dynamic per cart item
Key('removeCartItem_${index}')
Key('applyDiscountButton')
Key('addPaymentButton')
Key('finalizeSaleButton')
Key('totalAmountText')
Key('paidAmountText')
Key('remainingAmountText')

// Dialogs
Key('discountCodeField')
Key('validateDiscountButton')
Key('paymentMethodDropdown')
Key('paymentAmountField')
Key('addPaymentConfirmButton')
Key('saleCompleteDialog')
Key('saleReceiptNumber')
Key('newSaleFromDialogButton')
```

#### API Endpoints

**GET /api/inventory**

Success Response (200):
```json
{
  "success": true,
  "data": [
    {
      "sku": "POPCORN-L",
      "name": "Pipoca Grande",
      "description": "Pipoca grande com manteiga",
      "category": "FOOD",
      "price": 18.00,
      "costPrice": 5.50,
      "currentStock": 50,
      "minStock": 10,
      "maxStock": 100,
      "isActive": true,
      "unit": "UNIT",
      "imageUrl": null
    },
    {
      "sku": "SODA-500",
      "name": "Refrigerante 500ml",
      "description": "Refrigerante 500ml variados",
      "category": "BEVERAGE",
      "price": 8.00,
      "costPrice": 2.50,
      "currentStock": 80,
      "minStock": 20,
      "maxStock": 150,
      "isActive": true,
      "unit": "UNIT",
      "imageUrl": null
    }
  ]
}
```

**POST /api/sales**

Request:
```json
{
  "type": "CONCESSION"
}
```

Success Response (201):
```json
{
  "success": true,
  "data": {
    "id": "sale-uuid-123",
    "saleNumber": "SALE-20240115-001",
    "cashierCpf": "123.456.789-00",
    "customerCpf": null,
    "status": "OPEN",
    "type": "CONCESSION",
    "items": [],
    "payments": [],
    "subtotal": 0.00,
    "discountAmount": 0.00,
    "grandTotal": 0.00,
    "totalPaid": 0.00,
    "changeAmount": 0.00,
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

**POST /api/sales/{saleId}/items**

Request:
```json
{
  "sku": "POPCORN-L",
  "quantity": 2,
  "unitPrice": 18.00
}
```

Success Response (200):
```json
{
  "success": true,
  "data": {
    "id": "item-uuid-1",
    "saleId": "sale-uuid-123",
    "sku": "POPCORN-L",
    "name": "Pipoca Grande",
    "quantity": 2,
    "unitPrice": 18.00,
    "subtotal": 36.00,
    "discount": 0.00,
    "total": 36.00
  }
}
```

**POST /api/sales/discount/validate**

Request:
```json
{
  "discountCode": "PROMO10"
}
```

Success Response (200):
```json
{
  "success": true,
  "data": {
    "code": "PROMO10",
    "type": "PERCENTAGE",
    "value": 10.0,
    "isValid": true,
    "minPurchaseAmount": 20.00,
    "maxDiscountAmount": 50.00
  }
}
```

Error Response (404):
```json
{
  "success": false,
  "message": "Código de desconto inválido ou expirado"
}
```

**POST /api/sales/{saleId}/discount**

Request:
```json
{
  "discountCode": "PROMO10"
}
```

Success Response (200):
```json
{
  "success": true,
  "data": {
    "id": "sale-uuid-123",
    "discountCode": "PROMO10",
    "discountAmount": 3.60,
    "subtotal": 36.00,
    "grandTotal": 32.40
  }
}
```

**POST /api/sales/{saleId}/payments**

Request:
```json
{
  "method": "CASH",
  "amount": 40.00,
  "reference": null
}
```

Success Response (200):
```json
{
  "success": true,
  "data": {
    "id": "payment-uuid-1",
    "saleId": "sale-uuid-123",
    "method": "CASH",
    "amount": 40.00,
    "status": "COMPLETED",
    "createdAt": "2024-01-15T10:35:00Z"
  }
}
```

**POST /api/sales/{saleId}/finalize**

Success Response (200):
```json
{
  "success": true,
  "data": {
    "id": "sale-uuid-123",
    "saleNumber": "SALE-20240115-001",
    "status": "COMPLETED",
    "grandTotal": 32.40,
    "totalPaid": 40.00,
    "changeAmount": 7.60,
    "completedAt": "2024-01-15T10:35:30Z"
  }
}
```

#### Expected Outcomes

- ✅ Load products successfully
- ✅ Create new sale
- ✅ Add items to cart with correct calculations
- ✅ Apply valid discount codes
- ❌ Reject invalid discount codes
- ✅ Accept multiple payment methods
- ✅ Calculate change correctly
- ✅ Finalize sale when fully paid
- ✅ Show receipt with sale details

---

## Flow 4: POS Ticket Sale Flow

### Point of Sale - Movie Ticket Sale with Seat Selection

**Priority:** HIGH (Core revenue feature)

**Starting Page:** `lib/features/pos/presentation/pages/pos_page.dart`

#### Steps

1. User creates new sale in POS
2. User taps `sellTicketsButton` button
3. System shows session selection dialog
4. User selects a session from `sessionList`
5. User navigates to seat selection page
6. User selects seats on `seatMapGrid`
7. User confirms selection with `confirmSeatsButton`
8. Tickets added to POS cart
9. User completes payment
10. System reserves seats and finalizes sale

#### Widget Keys Needed

```dart
// PosPage
Key('sellTicketsButton')
Key('sessionSelectionDialog')
Key('sessionList')
Key('session_${sessionId}') // Dynamic per session

// SeatSelectionPage
Key('seatMapGrid')
Key('seat_${row}_${column}') // Dynamic per seat
Key('selectedSeatsPanel')
Key('totalPriceText')
Key('confirmSeatsButton')
Key('cancelSelectionButton')
```

#### API Endpoints

**GET /api/sessions?date=2024-01-15&status=SCHEDULED**

Success Response (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "session-uuid-1",
      "movieTitle": "Inception",
      "roomName": "Sala 1",
      "startTime": "2024-01-15T14:00:00Z",
      "basePrice": 35.00,
      "availableSeats": 45,
      "status": "SCHEDULED"
    }
  ]
}
```

**GET /api/sessions/{sessionId}/seats**

Success Response (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "seat-uuid-1",
      "seatNumber": "A1",
      "row": "A",
      "column": 1,
      "type": "STANDARD",
      "status": "AVAILABLE",
      "price": 35.00
    },
    {
      "id": "seat-uuid-2",
      "seatNumber": "A2",
      "row": "A",
      "column": 2,
      "type": "STANDARD",
      "status": "SOLD",
      "price": 35.00
    }
  ]
}
```

**POST /api/sales/{saleId}/items** (for tickets)

Request:
```json
{
  "type": "TICKET",
  "sessionId": "session-uuid-1",
  "seatId": "seat-uuid-1",
  "quantity": 1,
  "unitPrice": 35.00
}
```

Success Response (200):
```json
{
  "success": true,
  "data": {
    "id": "item-uuid-1",
    "type": "TICKET",
    "name": "Ingresso - Inception - A1",
    "quantity": 1,
    "unitPrice": 35.00,
    "total": 35.00,
    "sessionId": "session-uuid-1",
    "seatId": "seat-uuid-1"
  }
}
```

#### Expected Outcomes

- ✅ Display available sessions
- ✅ Show seat map with availability
- ✅ Reserve seats during selection
- ✅ Add tickets to cart with session details
- ✅ Complete payment and confirm reservations
- ❌ Prevent selection of sold/reserved seats

---

## Flow 5: Session Management Flow

### Create, Update, and Delete Movie Sessions

**Priority:** MEDIUM

**Starting Page:** `lib/features/sessions/presentation/pages/integrated_management_page.dart`

#### Steps

1. User navigates to sessions tab
2. User views list of sessions
3. User taps `createSessionButton`
4. User fills session form
5. User saves session
6. User can edit sessions with `editSession_${sessionId}`
7. User can delete sessions with `deleteSession_${sessionId}`

#### Widget Keys Needed

```dart
// IntegratedManagementPage
Key('sessionsTab')
Key('createSessionButton')
Key('sessionsList')
Key('session_${sessionId}') // Dynamic
Key('editSession_${sessionId}')
Key('deleteSession_${sessionId}')

// SessionFormDialog
Key('movieDropdown')
Key('roomDropdown')
Key('dateField')
Key('timeField')
Key('basePriceField')
Key('languageField')
Key('subtitlesField')
Key('formatDropdown')
Key('saveSessionButton')
Key('cancelSessionButton')
```

#### API Endpoints

**GET /api/sessions**

Success Response (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "session-uuid-1",
      "movieId": "movie-uuid-1",
      "movieTitle": "Inception",
      "roomId": "room-uuid-1",
      "roomName": "Sala 1",
      "startTime": "2024-01-15T14:00:00Z",
      "endTime": "2024-01-15T16:30:00Z",
      "language": "Português",
      "subtitles": "Inglês",
      "format": "2D",
      "basePrice": 35.00,
      "totalSeats": 100,
      "availableSeats": 45,
      "status": "SCHEDULED"
    }
  ]
}
```

**GET /api/movies**

Success Response (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "movie-uuid-1",
      "title": "Inception",
      "duration_min": 148,
      "genre": "Sci-Fi",
      "rating": "PG-13",
      "isActive": true
    }
  ]
}
```

**GET /api/rooms**

Success Response (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "room-uuid-1",
      "name": "Sala 1",
      "capacity": 100,
      "roomType": "STANDARD",
      "isActive": true
    }
  ]
}
```

**POST /api/sessions**

Request:
```json
{
  "movieId": "movie-uuid-1",
  "roomId": "room-uuid-1",
  "startTime": "2024-01-15T14:00:00Z",
  "basePrice": 35.00,
  "language": "Português",
  "subtitles": "Inglês",
  "format": "2D"
}
```

Success Response (201):
```json
{
  "success": true,
  "data": {
    "id": "session-uuid-new",
    "movieId": "movie-uuid-1",
    "roomId": "room-uuid-1",
    "startTime": "2024-01-15T14:00:00Z",
    "endTime": "2024-01-15T16:28:00Z",
    "basePrice": 35.00,
    "status": "SCHEDULED"
  }
}
```

**PUT /api/sessions/{sessionId}**

Request:
```json
{
  "basePrice": 40.00
}
```

Success Response (200):
```json
{
  "success": true,
  "data": {
    "id": "session-uuid-1",
    "basePrice": 40.00
  }
}
```

**DELETE /api/sessions/{sessionId}**

Success Response (200):
```json
{
  "success": true,
  "message": "Sessão deletada com sucesso"
}
```

#### Expected Outcomes

- ✅ Create sessions with valid data
- ❌ Validate future dates and room availability
- ✅ Update session information
- ✅ Delete sessions and refresh list
- ❌ Prevent overlapping sessions in same room

---

## Flow 6: Inventory Management Flow

### Product Management and Stock Adjustment

**Priority:** MEDIUM

**Starting Page:** `lib/features/inventory/presentation/pages/inventory_page.dart`

#### Steps

1. User views inventory list
2. User searches products with `inventorySearchField`
3. User creates product with `createProductButton`
4. User adjusts stock with `adjustStockButton_${sku}`
5. User views adjustment history

#### Widget Keys Needed

```dart
// InventoryPage
Key('inventorySearchField')
Key('createProductButton')
Key('productList')
Key('product_${sku}') // Dynamic
Key('adjustStockButton_${sku}')
Key('viewHistoryButton_${sku}')
Key('activateProduct_${sku}')
Key('deactivateProduct_${sku}')

// Stock Adjustment Dialog
Key('stockDeltaField')
Key('reasonDropdown')
Key('notesField')
Key('confirmAdjustmentButton')
```

#### API Endpoints

**GET /api/inventory**

Success Response (200):
```json
{
  "success": true,
  "data": [
    {
      "sku": "POPCORN-L",
      "name": "Pipoca Grande",
      "category": "FOOD",
      "price": 18.00,
      "currentStock": 50,
      "minStock": 10,
      "isActive": true
    }
  ]
}
```

**GET /api/inventory?search=pipoca**

Success Response (200):
```json
{
  "success": true,
  "data": [
    {
      "sku": "POPCORN-L",
      "name": "Pipoca Grande",
      "currentStock": 50
    }
  ]
}
```

**POST /api/inventory**

Request:
```json
{
  "sku": "CANDY-M",
  "name": "Chocolate M&M",
  "category": "CANDY",
  "price": 12.00,
  "costPrice": 4.50,
  "minStock": 15,
  "maxStock": 80,
  "unit": "UNIT"
}
```

Success Response (201):
```json
{
  "success": true,
  "data": {
    "sku": "CANDY-M",
    "name": "Chocolate M&M",
    "currentStock": 0,
    "isActive": true
  }
}
```

**POST /api/inventory/{sku}/adjust**

Request:
```json
{
  "delta": 20,
  "reason": "RESTOCK",
  "notes": "Reposição semanal"
}
```

Success Response (200):
```json
{
  "success": true,
  "data": {
    "id": "adjustment-uuid-1",
    "sku": "POPCORN-L",
    "delta": 20,
    "previousStock": 50,
    "newStock": 70,
    "reason": "RESTOCK",
    "performedBy": "123.456.789-00",
    "createdAt": "2024-01-15T11:00:00Z"
  }
}
```

#### Expected Outcomes

- ✅ Display all active products
- ✅ Search filters correctly
- ✅ Create products with valid SKU
- ✅ Adjust stock with proper reasons
- ✅ Track all adjustments in history
- ✅ Alert on low stock items

---

## Flow 7: Reports Generation Flow

### View Sales and Business Analytics Reports

**Priority:** LOW

**Starting Page:** `lib/features/reports/presentation/pages/reports_page.dart`

#### Steps

1. User views sales summary on reports page
2. User selects report type (detailed sales, ticket sales, employee performance)
3. User sets date range with `startDatePicker` and `endDatePicker`
4. User applies filters with `applyFiltersButton`
5. System generates and displays report

#### Widget Keys Needed

```dart
// ReportsDashboardPage
Key('salesSummaryCard')
Key('todayRevenueText')
Key('todayTransactionsText')
Key('weekRevenueText')
Key('monthRevenueText')
Key('growthPercentageText')
Key('detailedSalesReportButton')
Key('ticketSalesReportButton')
Key('employeeReportButton')

// Report Pages
Key('startDatePicker')
Key('endDatePicker')
Key('groupByDropdown')
Key('applyFiltersButton')
Key('reportDataTable')
Key('exportReportButton')
```

#### API Endpoints

**GET /api/sales/reports/summary**

Success Response (200):
```json
{
  "success": true,
  "data": {
    "todayRevenue": 15420.50,
    "todayTransactions": 127,
    "weekRevenue": 89350.75,
    "monthRevenue": 345120.00,
    "growthPercentage": 10.45
  }
}
```

**GET /api/sales/reports/detailed?startDate=2024-01-01&endDate=2024-01-31&groupBy=day**

Success Response (200):
```json
{
  "success": true,
  "data": {
    "period": {
      "startDate": "2024-01-01T00:00:00Z",
      "endDate": "2024-01-31T23:59:59Z",
      "groupBy": "day"
    },
    "summary": {
      "totalSales": 450,
      "totalRevenue": 345120.00,
      "totalDiscount": 12450.50,
      "averageSaleValue": 767.15
    },
    "groupedData": [
      {
        "date": "2024-01-01",
        "salesCount": 15,
        "revenue": 12450.00
      }
    ]
  }
}
```

**GET /api/tickets/reports/sales?startDate=2024-01-01&endDate=2024-01-31&groupBy=movie**

Success Response (200):
```json
{
  "success": true,
  "data": {
    "period": {
      "startDate": "2024-01-01T00:00:00Z",
      "endDate": "2024-01-31T23:59:59Z",
      "groupBy": "movie"
    },
    "summary": {
      "totalTickets": 2847,
      "totalRevenue": 99645.00,
      "averageTicketPrice": 35.00,
      "cancelledTickets": 42
    },
    "groupedData": [
      {
        "movieTitle": "Inception",
        "ticketCount": 450,
        "revenue": 15750.00
      }
    ]
  }
}
```

#### Expected Outcomes

- ✅ Display current sales metrics
- ✅ Generate reports for date ranges
- ✅ Filter by criteria
- ✅ Show charts and trends
- ✅ Export report data

---

## Testing Implementation Guide

### Setup

1. **Install dependencies:**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mocktail: ^1.0.0
  http_mock_adapter: ^0.6.0
```

2. **Create test directory structure:**
```
integration_test/
├── flows/
│   ├── authentication_flow_test.dart
│   ├── pos_concession_flow_test.dart
│   ├── pos_ticket_flow_test.dart
│   ├── session_management_flow_test.dart
│   ├── inventory_flow_test.dart
│   └── reports_flow_test.dart
├── mocks/
│   ├── dio_mock.dart
│   └── mock_responses.dart
└── helpers/
    ├── test_helpers.dart
    └── widget_keys.dart
```

### Mock Dio Client

```dart
class MockDio extends Mock implements Dio {
  final Map<String, dynamic> mockResponses = {};

  void addMockResponse(String path, String method, dynamic response, {int statusCode = 200}) {
    final key = '$method:$path';
    mockResponses[key] = {
      'data': response,
      'statusCode': statusCode,
    };
  }

  @override
  Future<Response<T>> request<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    // ... other parameters
  }) async {
    final method = options?.method ?? 'GET';
    final key = '$method:$path';

    if (mockResponses.containsKey(key)) {
      final mock = mockResponses[key];
      return Response(
        data: mock['data'] as T,
        statusCode: mock['statusCode'],
        requestOptions: RequestOptions(path: path),
      );
    }

    throw DioException(
      requestOptions: RequestOptions(path: path),
      error: 'No mock response for $key',
    );
  }
}
```

### Test Example

```dart
void main() {
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    // Inject mock into dependency injection
  });

  testWidgets('Authentication Flow - Successful Login', (tester) async {
    // Setup mock responses
    mockDio.addMockResponse(
      '/api/employees/login',
      'POST',
      {
        'success': true,
        'data': {
          'token': 'mock-token',
          'employee': {
            'fullName': 'John Doe',
            'role': 'CASHIER',
          }
        }
      },
    );

    // Start app
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Navigate to login
    expect(find.byKey(Key('loginPage')), findsOneWidget);

    // Enter credentials
    await tester.enterText(find.byKey(Key('employeeIdField')), 'EMP001');
    await tester.enterText(find.byKey(Key('passwordField')), 'password123');

    // Tap login
    await tester.tap(find.byKey(Key('loginButton')));
    await tester.pumpAndSettle();

    // Verify navigation to dashboard
    expect(find.byKey(Key('dashboardPage')), findsOneWidget);
    expect(find.text('Bem-vindo, John Doe'), findsOneWidget);
  });
}
```

---

## Next Steps

1. ✅ Add widget keys to all pages and widgets listed above
2. ✅ Create mock Dio client implementation
3. ✅ Create mock response files for each flow
4. ✅ Implement integration tests for each flow
5. ✅ Set up CI/CD pipeline to run integration tests
6. ✅ Document test coverage metrics

---

## Priority Order

1. **Authentication Flow** (Blocks everything else)
2. **POS Ticket Sale Flow** (Core revenue)
3. **POS Concession Sale Flow** (Secondary revenue)
4. **Session Management Flow** (Required for tickets)
5. **Dashboard Flow** (User entry point)
6. **Inventory Management Flow** (Stock control)
7. **Reports Generation Flow** (Analytics)
