# Backstage Cinema - Flutter Frontend Implementation Plan

**Generated:** November 12, 2025
**Focus:** Flutter Mobile App + Backend Integration
**Architecture:** Clean Architecture + BLoC Pattern
**Backend:** Single API on port 3000 (centralized authentication)

---

## 📊 Current State Analysis

### ✅ Backend Status (Ready to Use)

**Backend URL:** http://localhost:3000

**Available APIs:**
- ✅ **Authentication** - POST /api/employees/login
- ✅ **Movies** - Full CRUD, search, statistics
- ✅ **Customers** - CRUD, purchase history, loyalty
- ✅ **Discounts** - CRUD, validation, analytics
- ✅ **Employees** - CRUD, login, clock-in/out, metrics
- ✅ **Inventory** - CRUD, stock adjustments, alerts
- ✅ **Rooms** - CRUD, seat maps, pricing
- ✅ **Sessions** - CRUD, seat availability
- ✅ **Sales** - Full flow (create, items, discount, payment, finalize)
- ✅ **Tickets** - Bulk creation, cancellation, validation
- ✅ **System Admin** - Companies, subscriptions

### 🎨 Flutter Status (Design System Complete, Features Missing)

**What We Have:**
- ✅ Complete design system (14 UI components)
- ✅ Navigation infrastructure
- ✅ Dependency injection setup
- ✅ HttpClient configured (Dio)
- ✅ LocalStorage wrapper
- ✅ Localization (PT-BR, PT, EN)
- ✅ Module system

**What We Need:**
- ❌ All business features (Auth, Dashboard, POS, Sessions, Inventory, etc.)
- ❌ Data models for API responses
- ❌ Repository implementations
- ❌ Use cases / business logic
- ❌ BLoC state management
- ❌ API integration
- ❌ Utilities (validators, formatters, extensions)

---

## 🎯 Implementation Plan - Flutter Frontend Only

### Phase 0: Project Setup & Configuration (Day 1-2)

**Objective:** Prepare Flutter project for development

#### Tasks:

1. **Update Dependency Injection**
   - File: `lib/adapters/dependency_injection/injection_container.dart`
   - Uncomment HttpClient, ConnectivityChecker, AnalyticsTracker
   - Update HttpClient base URL to `http://localhost:3000`

2. **Create API Constants**
   ```dart
   lib/core/constants/
   ├── api_constants.dart           # Base URL, all endpoints
   ├── app_constants.dart           # App-wide constants
   └── storage_keys.dart            # LocalStorage keys
   ```

3. **Create Base Error Classes (ONLY BASE CLASSES)**
   ```dart
   lib/core/errors/
   ├── failures.dart                # Base Failure class only
   └── exceptions.dart              # Base Exception class only
   ```

   **failures.dart:**
   ```dart
   import 'package:equatable/equatable.dart';

   abstract class Failure extends Equatable {
     final String message;
     final int? statusCode;

     const Failure({
       required this.message,
       this.statusCode,
     });

     @override
     List<Object?> get props => [message, statusCode];
   }
   ```

   **exceptions.dart:**
   ```dart
   class AppException implements Exception {
     final String message;
     final int? statusCode;

     AppException({
       required this.message,
       this.statusCode,
     });

     @override
     String toString() => message;
   }
   ```

4. **Create Base UseCase Class**
   ```dart
   lib/core/usecases/
   └── usecase.dart
   ```

   **usecase.dart:**
   ```dart
   import 'package:dartz/dartz.dart';
   import '../errors/failures.dart';

   abstract class UseCase<Type, Params> {
     Future<Either<Failure, Type>> call(Params params);
   }

   class NoParams {}
   ```

5. **Implement Utilities**
   ```dart
   lib/shared/utils/
   ├── validators/
   │   ├── cpf_validator.dart       # Validate CPF (11 digits)
   │   ├── email_validator.dart     # Validate email
   │   └── field_validator.dart     # Generic validators
   ├── formatters/
   │   ├── cpf_formatter.dart       # Format CPF (XXX.XXX.XXX-XX)
   │   ├── currency_formatter.dart  # Format BRL currency (R$ X.XXX,XX)
   │   ├── date_formatter.dart      # Format dates
   │   └── phone_formatter.dart     # Format phone
   └── extensions/
       ├── string_extensions.dart   # String helpers
       ├── datetime_extensions.dart # Date helpers
       ├── context_extensions.dart  # BuildContext helpers
       └── num_extensions.dart      # Number helpers
   ```

6. **Update HttpClient with Auth Interceptor**
   - File: `lib/adapters/http/http_client.dart`
   - Add request interceptor to inject token from LocalStorage
   - Add response interceptor for 401 handling
   - Handle token expiration (re-login required)

**Deliverables:**
- ✅ Project configured for development
- ✅ Base Failure and Exception classes created
- ✅ Base UseCase interface created
- ✅ All utilities implemented and tested
- ✅ HttpClient ready for authenticated requests
- ✅ Constants defined

---

### Phase 1: Authentication Feature (Week 1) ✅ COMPLETED

**Objective:** Complete login/logout flow with backend integration

#### 1.1 Data Layer

**Create:**
```dart
lib/features/authentication/data/
├── models/
│   ├── employee_model.dart          # Maps to backend Employee response
│   ├── company_model.dart           # Maps to backend Company
│   ├── login_request.dart           # POST /api/employees/login request
│   └── login_response.dart          # Login response DTO
├── datasources/
│   ├── auth_remote_datasource.dart  # API calls to backend
│   └── auth_local_datasource.dart   # Token & employee caching
└── repositories/
    └── auth_repository_impl.dart    # Implementation
```

**API Endpoint:**
- `POST /api/employees/login`

**Request/Response:**
```dart
// Request
{
  "cpf": "12345678901",
  "password": "employee-password"
}

// Response
{
  "success": true,
  "data": {
    "token": "jwt-token-here",
    "employee": {
      "cpf": "12345678901",
      "companyId": "uuid",
      "employeeId": "EMP001",
      "role": "CASHIER",
      "fullName": "John Doe",
      "email": "john@example.com",
      "isActive": true
    }
  }
}
```

#### 1.2 Domain Layer

**Create:**
```dart
lib/features/authentication/domain/
├── entities/
│   ├── employee.dart                # Immutable domain entity
│   └── company.dart                 # Immutable domain entity
├── repositories/
│   └── auth_repository.dart         # Interface
└── usecases/
    ├── login_usecase.dart           # Separate class
    ├── logout_usecase.dart          # Separate class
    ├── get_current_employee_usecase.dart # Separate class
    └── check_auth_status_usecase.dart    # Separate class
```

**Each UseCase has its own abstract interface and implementation:**
```dart
// login_usecase.dart
abstract class LoginUseCase {
  Future<Either<Failure, Employee>> call(LoginParams params);
}

class LoginUseCaseImpl implements LoginUseCase {
  final AuthRepository repository;

  LoginUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Employee>> call(LoginParams params) async {
    return await repository.login(params.cpf, params.password);
  }
}

class LoginParams {
  final String cpf;
  final String password;

  LoginParams({required this.cpf, required this.password});
}

// logout_usecase.dart
abstract class LogoutUseCase {
  Future<Either<Failure, void>> call(NoParams params);
}

class LogoutUseCaseImpl implements LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}

// check_auth_status_usecase.dart
abstract class CheckAuthStatusUseCase {
  Future<Either<Failure, bool>> call(NoParams params);
}

class CheckAuthStatusUseCaseImpl implements CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isAuthenticated();
  }
}

// get_current_employee_usecase.dart
abstract class GetCurrentEmployeeUseCase {
  Future<Either<Failure, Employee>> call(NoParams params);
}

class GetCurrentEmployeeUseCaseImpl implements GetCurrentEmployeeUseCase {
  final AuthRepository repository;

  GetCurrentEmployeeUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Employee>> call(NoParams params) async {
    return await repository.getCurrentEmployee();
  }
}
```

#### 1.3 Presentation Layer - BLoC with Pattern Matching

**Create:**
```dart
lib/features/authentication/presentation/
├── bloc/
│   ├── auth_bloc.dart               # Main authentication BLoC
│   ├── auth_event.dart              # Events
│   └── auth_state.dart              # States with pattern matching
├── pages/
│   ├── splash_page.dart             # Check auth status
│   └── login_page.dart              # Login form
└── widgets/
    ├── login_form.dart              # Form with validation
    ├── cpf_field.dart               # CPF input with mask
    └── password_field.dart          # Password input
```

**auth_state.dart - States with Pattern Matching:**
```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/employee.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];

  // Pattern matching methods
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(Employee employee) authenticated,
    required T Function() unauthenticated,
    required T Function(String message) error,
  }) {
    if (this is AuthInitial) {
      return initial();
    } else if (this is AuthLoading) {
      return loading();
    } else if (this is AuthAuthenticated) {
      return authenticated((this as AuthAuthenticated).employee);
    } else if (this is AuthUnauthenticated) {
      return unauthenticated();
    } else if (this is AuthError) {
      return error((this as AuthError).message);
    }
    throw Exception('Invalid state');
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(Employee employee)? authenticated,
    T Function()? unauthenticated,
    T Function(String message)? error,
  }) {
    if (this is AuthInitial && initial != null) {
      return initial();
    } else if (this is AuthLoading && loading != null) {
      return loading();
    } else if (this is AuthAuthenticated && authenticated != null) {
      return authenticated((this as AuthAuthenticated).employee);
    } else if (this is AuthUnauthenticated && unauthenticated != null) {
      return unauthenticated();
    } else if (this is AuthError && error != null) {
      return error((this as AuthError).message);
    }
    return null;
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(Employee employee)? authenticated,
    T Function()? unauthenticated,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    return whenOrNull(
      initial: initial,
      loading: loading,
      authenticated: authenticated,
      unauthenticated: unauthenticated,
      error: error,
    ) ?? orElse();
  }
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final Employee employee;

  const AuthAuthenticated({required this.employee});

  @override
  List<Object?> get props => [employee];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

**Usage in UI:**
```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    return state.when(
      initial: () => const SplashScreen(),
      loading: () => const LoadingSpinner(),
      authenticated: (employee) => DashboardPage(employee: employee),
      unauthenticated: () => const LoginPage(),
      error: (message) => ErrorWidget(message: message),
    );
  },
);

// Or using maybeWhen
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    return state.maybeWhen(
      authenticated: (employee) => DashboardPage(employee: employee),
      orElse: () => const LoginPage(),
    );
  },
);
```

**auth_event.dart:**
```dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class LoginRequested extends AuthEvent {
  final String cpf;
  final String password;

  const LoginRequested({
    required this.cpf,
    required this.password,
  });

  @override
  List<Object?> get props => [cpf, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
```

**auth_bloc.dart:**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_current_employee_usecase.dart';
import '../../../core/usecases/usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final GetCurrentEmployeeUseCase getCurrentEmployeeUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.getCurrentEmployeeUseCase,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await checkAuthStatusUseCase(NoParams());

    await result.fold(
      (failure) async {
        emit(const AuthUnauthenticated());
      },
      (isAuthenticated) async {
        if (isAuthenticated) {
          final employeeResult = await getCurrentEmployeeUseCase(NoParams());
          employeeResult.fold(
            (failure) => emit(const AuthUnauthenticated()),
            (employee) => emit(AuthAuthenticated(employee: employee)),
          );
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      LoginParams(cpf: event.cpf, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (employee) => emit(AuthAuthenticated(employee: employee)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await logoutUseCase(NoParams());
    emit(const AuthUnauthenticated());
  }
}
```

#### 1.4 Testing

**Create:**
```dart
test/features/authentication/
├── data/
│   ├── models/employee_model_test.dart
│   ├── datasources/auth_remote_datasource_test.dart
│   └── repositories/auth_repository_impl_test.dart
├── domain/
│   ├── usecases/login_usecase_test.dart
│   ├── usecases/logout_usecase_test.dart
│   └── usecases/check_auth_status_usecase_test.dart
└── presentation/
    ├── bloc/auth_bloc_test.dart
    └── pages/login_page_test.dart
```

**Deliverables:**
- ✅ User can login with employee CPF and password
- ✅ Token stored in LocalStorage
- ✅ Employee info cached locally
- ✅ Logout clears token and employee data
- ✅ Route guards protect authenticated routes
- ✅ Pattern matching works in UI (when, whenOrNull, maybeWhen)
- ✅ All tests passing

---

### Phase 2: Dashboard Feature (Week 2) ✅ COMPLETED

**Objective:** Display metrics and quick actions

**Status:** Complete with enhancements
- ✅ Dashboard data layer implemented
- ✅ Dashboard domain layer with usecases
- ✅ BLoC with pattern matching (when/whenOrNull/maybeWhen)
- ✅ Dashboard page with real-time stats
- ✅ Quick actions with navigation
- ✅ Dedicated alerts page with bell icon badge
- ✅ Pull-to-refresh functionality
- ✅ Placeholder screens for all navigation targets
- ✅ App routing structure established

#### 2.1 Data Layer

**Create:**
```dart
lib/features/dashboard/data/
├── models/
│   ├── dashboard_stats_model.dart
│   ├── session_summary_model.dart
│   └── stock_alert_model.dart
├── datasources/
│   └── dashboard_remote_datasource.dart
└── repositories/
    └── dashboard_repository_impl.dart
```

#### 2.2 Domain Layer - Each UseCase is a Separate Class

**Create:**
```dart
lib/features/dashboard/domain/
├── entities/
│   ├── dashboard_stats.dart
│   ├── session_summary.dart
│   └── stock_alert.dart
├── repositories/
│   └── dashboard_repository.dart
└── usecases/
    ├── get_dashboard_stats_usecase.dart      # Separate class
    ├── get_today_sessions_usecase.dart       # Separate class
    ├── get_stock_alerts_usecase.dart         # Separate class
    └── refresh_dashboard_usecase.dart        # Separate class
```

**Example UseCase:**
```dart
// get_dashboard_stats_usecase.dart
abstract class GetDashboardStatsUseCase {
  Future<Either<Failure, DashboardStats>> call(NoParams params);
}

class GetDashboardStatsUseCaseImpl implements GetDashboardStatsUseCase {
  final DashboardRepository repository;

  GetDashboardStatsUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) async {
    return await repository.getDashboardStats();
  }
}
```

#### 2.3 Presentation Layer - States with Pattern Matching

**Create:**
```dart
lib/features/dashboard/presentation/
├── bloc/
│   ├── dashboard_bloc.dart
│   ├── dashboard_event.dart
│   └── dashboard_state.dart       # With when/whenOrNull/maybeWhen
├── pages/
│   └── dashboard_page.dart
└── widgets/
    ├── stats_overview.dart
    ├── today_sessions_list.dart
    ├── quick_actions_section.dart
    └── alerts_section.dart
```

**dashboard_state.dart with Pattern Matching:**
```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/session_summary.dart';
import '../../domain/entities/stock_alert.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(
      DashboardStats stats,
      List<SessionSummary> sessions,
      List<StockAlert> alerts,
    ) loaded,
    required T Function(String message) error,
  }) {
    if (this is DashboardInitial) {
      return initial();
    } else if (this is DashboardLoading) {
      return loading();
    } else if (this is DashboardLoaded) {
      final state = this as DashboardLoaded;
      return loaded(state.stats, state.sessions, state.alerts);
    } else if (this is DashboardError) {
      return error((this as DashboardError).message);
    }
    throw Exception('Invalid state');
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(
      DashboardStats stats,
      List<SessionSummary> sessions,
      List<StockAlert> alerts,
    )? loaded,
    T Function(String message)? error,
  }) {
    if (this is DashboardInitial && initial != null) {
      return initial();
    } else if (this is DashboardLoading && loading != null) {
      return loading();
    } else if (this is DashboardLoaded && loaded != null) {
      final state = this as DashboardLoaded;
      return loaded(state.stats, state.sessions, state.alerts);
    } else if (this is DashboardError && error != null) {
      return error((this as DashboardError).message);
    }
    return null;
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(
      DashboardStats stats,
      List<SessionSummary> sessions,
      List<StockAlert> alerts,
    )? loaded,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    return whenOrNull(
      initial: initial,
      loading: loading,
      loaded: loaded,
      error: error,
    ) ?? orElse();
  }
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<SessionSummary> sessions;
  final List<StockAlert> alerts;

  const DashboardLoaded({
    required this.stats,
    required this.sessions,
    required this.alerts,
  });

  @override
  List<Object?> get props => [stats, sessions, alerts];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

**Deliverables:**
- ✅ Dashboard shows live data from backend
- ✅ Quick actions navigate correctly to feature pages
- ✅ Pattern matching works in UI (when/whenOrNull/maybeWhen)
- ✅ Pull-to-refresh working
- ✅ Dedicated alerts page with severity indicators
- ✅ Bell icon with badge counter in app bar
- ✅ All routes registered and functional
- ✅ Placeholder screens for upcoming features
- ✅ App bar maintains theme color on scroll

---

### General Pattern for All Features

**Every feature should follow this structure:**

#### Domain Layer - UseCases
```dart
// Each UseCase defines its own abstract interface and implementation
abstract class SomeUseCase {
  Future<Either<Failure, ReturnType>> call(SomeParams params);
}

class SomeUseCaseImpl implements SomeUseCase {
  final SomeRepository repository;

  SomeUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, ReturnType>> call(SomeParams params) async {
    return await repository.someMethod(params.field1, params.field2);
  }
}

class SomeParams {
  final String field1;
  final int field2;

  SomeParams({required this.field1, required this.field2});
}
```

#### Presentation Layer - States
```dart
// Every State class must:
// 1. Extend Equatable
// 2. Have when<T>() method
// 3. Have whenOrNull<T>() method
// 4. Have maybeWhen<T>() method

abstract class SomeState extends Equatable {
  const SomeState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() state1,
    required T Function(Data data) state2,
    required T Function(String error) state3,
    // ... all possible states
  }) {
    // Implementation
  }

  T? whenOrNull<T>({
    T Function()? state1,
    T Function(Data data)? state2,
    T Function(String error)? state3,
    // ... all possible states
  }) {
    // Implementation
  }

  T maybeWhen<T>({
    T Function()? state1,
    T Function(Data data)? state2,
    T Function(String error)? state3,
    required T Function() orElse,
  }) {
    return whenOrNull(/* ... */) ?? orElse();
  }
}

class State1 extends SomeState {
  const State1();
}

class State2 extends SomeState {
  final Data data;

  const State2({required this.data});

  @override
  List<Object?> get props => [data];
}

class State3 extends SomeState {
  final String error;

  const State3({required this.error});

  @override
  List<Object?> get props => [error];
}
```

---

### Phase 3: POS Feature (Week 3-4)

Following the same pattern:

**UseCases (each a separate class):**
```dart
lib/features/pos/domain/usecases/
├── get_products_usecase.dart
├── create_sale_usecase.dart
├── add_item_to_sale_usecase.dart
├── remove_item_from_sale_usecase.dart
├── update_item_quantity_usecase.dart
├── apply_discount_usecase.dart
├── calculate_total_usecase.dart
├── finalize_sale_usecase.dart
└── cancel_sale_usecase.dart
```

**States with Pattern Matching:**
```dart
// pos_state.dart
abstract class PosState extends Equatable {
  const PosState();

  T when<T>({
    required T Function() initial,
    required T Function() loadingProducts,
    required T Function(List<Product> products) productsLoaded,
    required T Function(Sale sale) saleInProgress,
    required T Function() processingPayment,
    required T Function(Sale sale) saleCompleted,
    required T Function(String message) error,
  });

  T? whenOrNull<T>({...});
  T maybeWhen<T>({..., required T Function() orElse});
}
```

---

### Phase 4: Sessions & Tickets Feature (Week 5-6)

**UseCases (each a separate class):**
```dart
lib/features/sessions/domain/usecases/
├── get_sessions_usecase.dart
├── get_session_details_usecase.dart
├── get_available_seats_usecase.dart
├── select_seat_usecase.dart
├── deselect_seat_usecase.dart
├── calculate_ticket_price_usecase.dart
├── purchase_tickets_usecase.dart
├── cancel_ticket_usecase.dart
└── validate_ticket_usecase.dart
```

**States with Pattern Matching:**
```dart
// seat_selection_state.dart
abstract class SeatSelectionState extends Equatable {
  const SeatSelectionState();

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(
      List<Seat> seats,
      List<String> selectedSeatIds,
      double totalPrice,
    ) loaded,
    required T Function() purchasing,
    required T Function(List<Ticket> tickets) purchaseSuccess,
    required T Function(String message) error,
  });

  T? whenOrNull<T>({...});
  T maybeWhen<T>({..., required T Function() orElse});
}
```

---

### Phase 5: Inventory Feature (Week 7)

**UseCases (each a separate class):**
```dart
lib/features/inventory/domain/usecases/
├── get_inventory_usecase.dart
├── get_product_details_usecase.dart
├── search_products_usecase.dart
├── filter_products_usecase.dart
├── get_low_stock_usecase.dart
├── adjust_stock_usecase.dart
├── get_adjustment_history_usecase.dart
├── create_product_usecase.dart
└── update_product_usecase.dart
```

---

### Phase 6: Reports Feature (Week 8)

**UseCases (each a separate class):**
```dart
lib/features/reports/domain/usecases/
├── get_sales_report_usecase.dart
├── get_ticket_report_usecase.dart
├── get_employee_report_usecase.dart
├── get_product_report_usecase.dart
├── filter_report_usecase.dart
└── export_report_usecase.dart
```

---

### Phase 7: Profile & Settings (Week 9)

**UseCases (each a separate class):**
```dart
lib/features/profile/domain/usecases/
├── get_employee_profile_usecase.dart
├── update_profile_usecase.dart
├── change_password_usecase.dart
├── clock_in_usecase.dart
├── clock_out_usecase.dart
├── get_time_entries_usecase.dart
├── change_language_usecase.dart
└── change_theme_usecase.dart
```

---

## 📝 Key Architecture Rules

### 1. Error Handling
- **Only base Failure and Exception classes** in `lib/core/errors/`
- All errors use the base `Failure` class with message
- No specific failure types (NetworkFailure, ServerFailure, etc.)
- Just one generic `Failure` with message and optional statusCode

### 2. UseCases
- **Every UseCase has an abstract interface and implementation in the same file**
- Abstract class defines the contract: `Future<Either<Failure, Type>> call(Params)`
- Implementation class (with `Impl` suffix) implements the abstract class
- Each UseCase has its own file
- Create params classes when needed (e.g., `LoginParams`, `CreateSaleParams`)
- Use `NoParams` when no parameters needed

### 3. BLoC States
- **All states extend Equatable**
- **Every state class must have:**
  - `when<T>()` - Required for all cases
  - `whenOrNull<T>()` - Optional for all cases
  - `maybeWhen<T>()` - Optional with required orElse
- Use pattern matching in UI for cleaner code
- Each concrete state class overrides `props` getter

### 4. State Pattern Matching Template
```dart
abstract class FeatureState extends Equatable {
  const FeatureState();

  @override
  List<Object?> get props => [];

  // Required: handle all states
  T when<T>({
    required T Function() state1Name,
    required T Function(Data data) state2Name,
    required T Function(String error) state3Name,
  }) {
    if (this is State1) {
      return state1Name();
    } else if (this is State2) {
      return state2Name((this as State2).data);
    } else if (this is State3) {
      return state3Name((this as State3).error);
    }
    throw Exception('Unhandled state: $runtimeType');
  }

  // Optional: return null if not matched
  T? whenOrNull<T>({
    T Function()? state1Name,
    T Function(Data data)? state2Name,
    T Function(String error)? state3Name,
  }) {
    if (this is State1 && state1Name != null) {
      return state1Name();
    } else if (this is State2 && state2Name != null) {
      return state2Name((this as State2).data);
    } else if (this is State3 && state3Name != null) {
      return state3Name((this as State3).error);
    }
    return null;
  }

  // Maybe: with fallback
  T maybeWhen<T>({
    T Function()? state1Name,
    T Function(Data data)? state2Name,
    T Function(String error)? state3Name,
    required T Function() orElse,
  }) {
    return whenOrNull(
      state1Name: state1Name,
      state2Name: state2Name,
      state3Name: state3Name,
    ) ?? orElse();
  }
}
```

---

## 🚀 Getting Started

### Today: Backend Setup

```bash
cd backstage_backend
make dev

# Test endpoints
curl http://localhost:3000/health
curl http://localhost:3000/api/sessions
curl -X POST http://localhost:3000/api/employees/login \
  -H "Content-Type: application/json" \
  -d '{"cpf": "12345678901", "password": "password123"}'
```

### Tomorrow: Flutter Setup

```bash
cd backstage_frontend
flutter pub get
flutter pub run build_runner build

# Update lib/adapters/http/http_client.dart
# Change baseUrl to http://localhost:3000

# Uncomment adapters in injection_container.dart

flutter run
```

---

## 📊 Timeline

| Phase | Feature | Duration |
|-------|---------|----------|
| 0 | Setup & Config | 2 days |
| 1 | Authentication | 1 week |
| 2 | Dashboard | 1 week |
| 3 | POS | 2 weeks |
| 4 | Sessions/Tickets | 2 weeks |
| 5 | Inventory | 1 week |
| 6 | Reports | 1 week |
| 7 | Profile & Settings | 1 week |
| 8 | Advanced & Polish | 2 weeks |

**Total:** ~12 weeks for production-ready app

---

**Let's build this! 🚀**
