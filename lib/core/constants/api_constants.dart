/// API Constants for Backstage Cinema Backend
class ApiConstants {
  // Base URL - Use 10.0.2.2 for Android Emulator (maps to host localhost)
  // For iOS Simulator, use localhost
  // For Physical Device, use your computer's IP address (e.g., 192.168.0.221)
  static const String baseUrl = 'http://10.0.2.2:3000';

  // Authentication
  static const String login = '/api/employees/login';
  static const String getEmployee = '/api/employees';

  // Sessions
  static const String sessions = '/api/sessions';
  static String sessionDetails(String id) => '/api/sessions/$id';
  static String sessionSeats(String id) => '/api/sessions/$id/seats';

  // Tickets
  static const String tickets = '/api/tickets';
  static const String ticketsBulk = '/api/tickets/bulk';
  static String ticketDetails(String id) => '/api/tickets/$id';
  static String ticketCancel(String id) => '/api/tickets/$id/cancel';
  static String ticketValidate(String id) => '/api/tickets/$id/validate';
  static String ticketRefund(String id) => '/api/tickets/$id/refund';
  static String ticketsBySession(String sessionId) => '/api/tickets/session/$sessionId';

  // Sales
  static const String sales = '/api/sales';
  static String saleDetails(String id) => '/api/sales/$id';
  static String saleItems(String saleId) => '/api/sales/$saleId/items';
  static String saleItemRemove(String saleId, String itemId) => '/api/sales/$saleId/items/$itemId';
  static const String saleDiscountValidate = '/api/sales/discount/validate';
  static String saleDiscount(String saleId) => '/api/sales/$saleId/discount';
  static String saleFinalize(String saleId) => '/api/sales/$saleId/finalize';
  static String saleCancel(String saleId) => '/api/sales/$saleId/cancel';
  static String saleRefund(String saleId) => '/api/sales/$saleId/refund';
  static String salePayments(String saleId) => '/api/sales/$saleId/payments';

  // Inventory
  static const String inventory = '/api/inventory';
  static String inventoryDetails(String sku) => '/api/inventory/$sku';
  static const String inventoryLowStock = '/api/inventory/alerts/low-stock';
  static const String inventoryExpiring = '/api/inventory/expiring';
  static String inventoryAdjust(String sku) => '/api/inventory/$sku/adjust';
  static const String inventoryAdjustmentHistory = '/api/inventory/adjustments/history';
  static const String inventoryAuditLogs = '/api/inventory/audit/logs';
  static String inventoryActivate(String sku) => '/api/inventory/$sku/activate';
  static String inventoryDeactivate(String sku) => '/api/inventory/$sku/deactivate';

  // Movies
  static const String movies = '/api/movies';
  static String movieDetails(int id) => '/api/movies/$id';
  static const String moviesSearch = '/api/movies/search';
  static String movieStats(int id) => '/api/movies/$id/stats';
  static String movieActivate(int id) => '/api/movies/$id/activate';

  // Customers
  static const String customers = '/api/customers';
  static String customerDetails(String cpf) => '/api/customers/$cpf';
  static String customerPurchaseHistory(String cpf) => '/api/customers/$cpf/purchase-history';
  static String customerLoyaltyAdd(String cpf) => '/api/customers/$cpf/loyalty/add';
  static String customerLoyaltyRedeem(String cpf) => '/api/customers/$cpf/loyalty/redeem';

  // Discounts
  static const String discounts = '/api/discounts';
  static String discountDetails(String code) => '/api/discounts/$code';
  static String discountValidate(String code) => '/api/discounts/$code/validate';
  static String discountDeactivate(String code) => '/api/discounts/$code/deactivate';
  static const String discountAnalytics = '/api/discounts/analytics/usage';

  // Employees
  static const String employees = '/api/employees';
  static String employeeDetails(String cpf) => '/api/employees/$cpf';
  static const String employeeMe = '/api/employees/me';
  static const String employeeClockIn = '/api/employees/clock-in';
  static const String employeeClockOut = '/api/employees/clock-out';
  static const String employeeTimeEntries = '/api/employees/time-entries';
  static const String employeeActivityLogs = '/api/employees/activity-logs';
  static String employeeMetrics(String cpf) => '/api/employees/$cpf/metrics';

  // Rooms
  static const String rooms = '/api/rooms';
  static String roomDetails(String id) => '/api/rooms/$id';
  static String roomPrices(String id) => '/api/rooms/$id/prices';
  static String roomActivate(String id) => '/api/rooms/$id/activate';
  static String roomDeactivate(String id) => '/api/rooms/$id/deactivate';
  static const String seatMaps = '/api/rooms/seat-maps';
  static String seatMapDetails(String id) => '/api/rooms/seat-maps/$id';
  static String seatMapSeats(String seatMapId) => '/api/rooms/seat-maps/$seatMapId/seats';

  // Reports
  static const String salesReportDaily = '/api/sales/reports/daily';
  static const String salesReportSummary = '/api/sales/reports/summary';
  static const String ticketsReportSales = '/api/tickets/reports/sales';
  static const String customerRetentionReport = '/api/customers/reports/retention';

  // System Admin (if needed)
  static const String systemAdminCompanies = '/api/system-admin/companies';
  static String systemAdminCompanyDetails(String id) => '/api/system-admin/companies/$id';
  static const String systemAdminStatistics = '/api/system-admin/statistics';
  static const String systemAdminAuditLogs = '/api/system-admin/audit-logs';
}
