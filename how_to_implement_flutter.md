# CineApp - Flutter Architecture Template

A comprehensive Flutter template project implementing enterprise-grade architectural patterns based on InfinitePay Dashboard, featuring internet access management, camera functionality, HTTP requests, sophisticated named routing, modular architecture, and robot testing framework.

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles with **Feature-Module Architecture**, using a **multi-package monorepo** structure managed by **Melos**. Each feature is completely self-contained with its own domain, data, and presentation layers, communicating through well-defined contracts and dependency injection.

### 🎯 Core Architectural Principles

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Dependency Inversion**: High-level modules don't depend on low-level modules
3. **Interface Segregation**: Clients depend only on interfaces they use
4. **Single Responsibility**: Each class has one reason to change
5. **Open/Closed**: Open for extension, closed for modification

## 📁 Project Structure

```
cine_app/
├── app/                          # Main Flutter application
│   ├── lib/
│   │   ├── main.dart            # Application entry point
│   │   ├── core/                # Core application logic
│   │   │   ├── app_routes.dart  # Named routing configuration
│   │   │   ├── dependency_injection.dart  # DI setup
│   │   │   └── navigation/      # Navigation management
│   │   └── features/            # App-specific features
│   ├── assets/                  # Static assets
│   └── pubspec.yaml            # App dependencies
├── packages/                    # Shared packages ecosystem
│   ├── adapters/               # External library abstractions
│   │   ├── http_client/        # HTTP client adapter (Dio abstraction)
│   │   ├── media_picker/       # Camera/gallery adapter
│   │   └── connectivity/       # Network state adapter
│   ├── features/               # Business feature packages
│   │   ├── movies/             # Movie management feature
│   │   │   ├── lib/
│   │   │   │   ├── domain/     # Business logic & entities
│   │   │   │   ├── data/       # Data sources & repositories
│   │   │   │   └── presentation/ # UI & state management
│   │   │   └── test/           # Feature-specific tests
│   │   └── favorites/          # Favorites feature
│   ├── shared/                 # Shared utilities & contracts
│   │   ├── routing/            # Navigation system
│   │   └── core/               # Core utilities & base classes
│   └── design_system/          # UI components & theme
└── melos.yaml                  # Monorepo configuration
```

## 🚀 Getting Started

### Prerequisites

- **Flutter 3.27.4+** (exact version for consistency)
- **Dart 3.6.0+**
- **Melos CLI** (for monorepo management)
- **VS Code** or **Android Studio** with Flutter plugins

### Setup Instructions

1. **Install Melos globally:**
   ```bash
   dart pub global activate melos ^6.1.0
   ```

2. **Clone and setup:**
   ```bash
   git clone <repository>
   cd cine_app
   melos bootstrap
   ```

3. **Run the application:**
   ```bash
   cd app
   flutter run --flavor dev
   ```

## 🛠️ Development Commands & Melos Deep Setup

### Complete Melos Setup Requirements

Melos is the backbone of this monorepo architecture. Here's the comprehensive setup:

#### **1. Global Melos Installation**
```bash
# Install latest stable version
dart pub global activate melos ^6.1.0

# Verify installation
melos --version

# Update PATH if needed (add to ~/.bashrc, ~/.zshrc, etc.)
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

#### **2. Repository Structure Requirements**
```yaml
# melos.yaml - Complete configuration
name: cine_app
repository: https://github.com/your-org/cine_app

packages:
  - app
  - packages/**
  - plugins/**

ide:
  intellij:
    enabled: true
    moduleGenerators:
      - script: |
          dart pub run build_runner build --delete-conflicting-outputs
        description: "Generate code for all packages"

command:
  version:
    # Versioning strategy for packages
    releaseUrl: false
    workspaceChangelog: true
    hooks:
      preCommit: |
        melos analyze --fatal-infos
        melos test --coverage
      
  bootstrap:
    # Bootstrap configuration
    environment:
      sdk: ">=3.6.0 <4.0.0"
      flutter: ">=3.27.4"
    hooks:
      post: |
        echo "Bootstrap completed successfully!"
        echo "Run 'melos list' to see all packages"
    
    # Custom bootstrapping for specific packages
    runPubGetInParallel: true
    enforceLockfile: true

  clean:
    hooks:
      post: |
        echo "Cleaning complete. Run 'melos bootstrap' to reinstall dependencies."

scripts:
  # Enhanced script definitions with error handling
  bootstrap:
    name: "Bootstrap"
    description: "Install all dependencies and link packages"
    run: |
      echo "🚀 Bootstrapping CineApp monorepo..."
      melos clean --yes
      melos bootstrap --verbose
    
  analyze:
    name: "Analyze"
    description: "Run Dart analysis on all packages"
    run: |
      echo "🔍 Analyzing all packages..."
      dart analyze --fatal-infos
    exec:
      concurrency: 5
      failFast: true
      orderDependents: true
  
  test:
    name: "Test All"
    description: "Run all tests with coverage"
    run: |
      echo "🧪 Running all tests..."
      flutter test --coverage --reporter expanded
    exec:
      concurrency: 3
      failFast: false
      dir: test

  test:unit:
    name: "Unit Tests"
    description: "Run only unit tests"
    run: flutter test test/unit --coverage
    exec:
      concurrency: 5
      
  test:widget:
    name: "Widget Tests"
    description: "Run only widget tests with Robot pattern"
    run: flutter test test/widget --coverage
    exec:
      concurrency: 3
      
  test:robot:
    name: "Robot Tests"
    description: "Run Robot pattern tests"
    run: flutter test test/robot --coverage
    exec:
      concurrency: 1

  test:integration:
    name: "Integration Tests"  
    description: "Run integration tests"
    run: flutter test integration_test
    packageFilters:
      scope: "app"

  coverage:
    name: "Coverage Report"
    description: "Generate and merge coverage reports"
    run: |
      echo "📊 Generating coverage reports..."
      # Install lcov if not present
      which lcov > /dev/null || (echo "Installing lcov..." && brew install lcov)
      
      # Merge coverage files
      lcov --capture --directory . --output-file coverage.lcov
      genhtml coverage.lcov --output-directory coverage/html
      
      echo "Coverage report generated at coverage/html/index.html"

  generate:
    name: "Code Generation"
    description: "Run code generation for all packages"
    run: |
      echo "⚡ Running code generation..."
      flutter pub get
      dart run build_runner build --delete-conflicting-outputs
    exec:
      concurrency: 1
      orderDependents: true
      
  generate:watch:
    name: "Code Generation (Watch)"
    description: "Run code generation in watch mode"
    run: dart run build_runner watch --delete-conflicting-outputs
    packageFilters:
      dependsOn: "build_runner"

  l10n:
    name: "Localization"
    description: "Generate localization files"
    run: flutter gen-l10n
    packageFilters:
      dirExists: "lib/l10n"

  format:
    name: "Format Code"
    description: "Format all Dart code"
    run: dart format . --line-length=100 --set-exit-if-changed
    exec:
      concurrency: 10

  fix:
    name: "Fix Code"
    description: "Apply Dart fixes"
    run: dart fix --apply
    exec:
      concurrency: 5

  deps:
    name: "Dependency Check"
    description: "Check for dependency issues"
    run: |
      echo "🔍 Checking dependencies..."
      flutter pub deps
      dart pub outdated

  build:android:
    name: "Build Android"
    description: "Build Android APK"
    run: |
      echo "🏗️ Building Android APK..."
      flutter build apk --release --obfuscate --split-debug-info=build/debug-symbols/
    packageFilters:
      scope: "app"

  build:ios:
    name: "Build iOS"
    description: "Build iOS app"
    run: |
      echo "🏗️ Building iOS app..."
      flutter build ios --release --obfuscate --split-debug-info=build/debug-symbols/
    packageFilters:
      scope: "app"

  version:check:
    name: "Version Check"
    description: "Check version consistency across packages"
    run: melos version --dry-run

  exec:
    name: "Execute Command"
    description: "Execute command in specific package"
    run: |
      echo "Executing in package: $MELOS_PACKAGE_NAME"
      echo "Command: $@"

# Development environment configurations
environment:
  sdk: ">=3.6.0 <4.0.0"
  flutter: ">=3.27.4"

# Package filtering for different environments
packageFilters:
  flutter:
    - "app/**"
    - "packages/**"
  
  dart:
    - "tools/**"
```

#### **3. Essential Melos Commands**

##### **Basic Commands**
```bash
# Project Setup
melos bootstrap              # Install all dependencies
melos clean && melos bootstrap  # Clean rebuild
melos list                   # List all packages
melos list --graph          # Show dependency graph

# Development
melos generate              # Run code generation
melos generate:watch        # Code generation in watch mode
melos analyze              # Static analysis
melos format               # Code formatting
melos fix                  # Apply automatic fixes
melos l10n                 # Generate localization

# Testing
melos test                 # Run all tests
melos test:unit            # Unit tests only
melos test:widget          # Widget tests only  
melos test:robot           # Robot pattern tests
melos test:integration     # Integration tests
melos coverage             # Generate coverage reports

# Building
melos build:android        # Build Android APK
melos build:ios           # Build iOS app

# Maintenance
melos deps                # Check dependencies
melos version:check       # Check version consistency
```

##### **Advanced Package Operations**
```bash
# Work on specific package
melos exec --scope=movies -- flutter test
melos exec --scope=http_client -- dart analyze
melos exec --dir-exists=lib/domain -- flutter test
melos exec --depends-on=bloc -- flutter analyze

# Filter by package properties
melos test --scope=*_test    # Run tests only in test packages
melos analyze --ignore=app  # Analyze all except app
melos generate --private    # Only private packages

# Dependency management
melos exec -- flutter pub get                    # Get dependencies for all
melos exec --scope=app -- flutter pub upgrade    # Upgrade app dependencies
melos exec -- dart pub outdated                  # Check outdated dependencies

# Version management
melos version --graduate     # Graduate prerelease versions
melos version --prerelease   # Create prerelease versions
melos version patch          # Bump patch version
melos version minor          # Bump minor version
melos version major          # Bump major version
```

##### **Custom Scripts and Hooks**
```bash
# Custom development workflows
melos run build:clean       # Clean build artifacts
melos run test:changed      # Test only changed packages
melos run deploy:staging    # Deploy to staging environment

# Pre-commit hooks integration
melos run pre-commit        # Run all pre-commit checks
melos run lint:fix          # Fix linting issues automatically
```

#### **4. IDE Integration Setup**

##### **VS Code Configuration**
```json
// .vscode/settings.json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 100,
  "dart.runPubGetOnPubspecChanges": false,
  "dart.enableSdkFormatter": true,
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/node_modules/**": true,
    "**/build/**": true,
    "**/.dart_tool/**": true
  },
  "search.exclude": {
    "**/.dart_tool": true,
    "**/build": true,
    "**/*.g.dart": true,
    "**/*.freezed.dart": true
  }
}

// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "CineApp (Debug)",
      "request": "launch",
      "type": "dart",
      "program": "app/lib/main.dart",
      "cwd": "${workspaceFolder}"
    },
    {
      "name": "CineApp (Release)",
      "request": "launch", 
      "type": "dart",
      "program": "app/lib/main.dart",
      "cwd": "${workspaceFolder}",
      "flutterMode": "release"
    }
  ]
}

// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Melos Bootstrap",
      "type": "shell",
      "command": "melos bootstrap",
      "group": "build",
      "presentation": {"echo": true, "reveal": "always"}
    },
    {
      "label": "Melos Test All",
      "type": "shell", 
      "command": "melos test",
      "group": "test"
    }
  ]
}
```

#### **5. Environment Configuration**
```bash
# .env.example - Environment template
FLUTTER_VERSION=3.27.4
DART_VERSION=3.6.0
MELOS_VERSION=6.1.0

# API Configuration
API_BASE_URL_DEV=https://api-dev.example.com
API_BASE_URL_PROD=https://api.example.com

# Feature Flags
ENABLE_DEBUG_LOGGING=true
ENABLE_ANALYTICS=false
ENABLE_CRASH_REPORTING=true
```

#### **6. Continuous Integration Setup**
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze_and_test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.4'
          channel: 'stable'
          
      - name: Install Melos
        run: dart pub global activate melos ^6.1.0
        
      - name: Bootstrap
        run: melos bootstrap
        
      - name: Analyze
        run: melos analyze --fatal-infos
        
      - name: Test
        run: melos test --coverage
        
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
          
  build_android:
    needs: analyze_and_test
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: dart pub global activate melos
      - run: melos bootstrap
      - run: melos build:android
        
  build_ios:
    needs: analyze_and_test
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: dart pub global activate melos
      - run: melos bootstrap  
      - run: melos build:ios
```

## 🏛️ Architecture Deep Dive

### 1. 🌐 Internet Access Implementation

The project implements a robust network management system through multiple layers:

#### **Connectivity Adapter Pattern**
```dart
// packages/adapters/connectivity/
abstract class ConnectivityClient {
  Stream<ConnectivityStatus> get connectivityStream;
  Future<bool> hasInternetAccess();
  Future<ConnectivityStatus> checkConnectivity();
}

class ConnectivityClientImpl implements ConnectivityClient {
  // Implementation using connectivity_plus
  // Abstracts external dependency
}
```

#### **Network-Aware HTTP Client**
```dart
// packages/adapters/http_client/
class HttpClientImpl implements HttpClient {
  final ConnectivityClient _connectivity;
  
  @override
  Future<Either<HttpException, HttpResponse>> get(String path) async {
    // Check connectivity before request
    if (!await _connectivity.hasInternetAccess()) {
      return Left(NoInternetException());
    }
    // Proceed with request
  }
}
```

#### **State Management**
```dart
// App-level connectivity BLoC
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityClient _connectivity;
  
  ConnectivityBloc(this._connectivity) {
    on<ConnectivityStarted>(_onStarted);
    on<ConnectivityChanged>(_onChanged);
  }
  
  Future<void> _onStarted(event, emit) async {
    await emit.onEach(
      _connectivity.connectivityStream,
      onData: (status) => add(ConnectivityChanged(status)),
    );
  }
}
```

### 2. 📷 Camera Access Implementation

Camera functionality is implemented through a permission-aware adapter pattern:

#### **Media Picker Contract**
```dart
// packages/adapters/media_picker/
enum MediaSource { camera, gallery }

abstract class MediaPickerClient {
  Future<Either<MediaPickerException, File?>> pickImage({
    required MediaSource source,
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
  });
  
  Future<Either<MediaPickerException, File?>> pickVideo({
    required MediaSource source,
    Duration? maxDuration,
  });
}
```

#### **Permission Management**
```dart
class MediaPickerClientImpl implements MediaPickerClient {
  final PermissionHandler _permissions;
  final ImagePicker _imagePicker;
  
  @override
  Future<Either<MediaPickerException, File?>> pickImage({
    required MediaSource source,
  }) async {
    // 1. Check permissions
    final hasPermission = await _checkPermissions(source);
    if (!hasPermission) {
      return Left(PermissionDeniedException(source));
    }
    
    // 2. Pick image with error handling
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source == MediaSource.camera 
          ? ImageSource.camera 
          : ImageSource.gallery,
      );
      
      return image != null 
        ? Right(File(image.path)) 
        : Right(null);
    } catch (e) {
      return Left(MediaPickerException(e.toString()));
    }
  }
  
  Future<bool> _checkPermissions(MediaSource source) async {
    final permission = source == MediaSource.camera 
      ? Permission.camera 
      : Permission.photos;
      
    if (await permission.isGranted) return true;
    
    final result = await permission.request();
    return result.isGranted;
  }
}
```

### 3. 🌐 HTTP Request Patterns

The HTTP layer implements sophisticated error handling and interceptors:

#### **HTTP Client Architecture**
```dart
// packages/adapters/http_client/
abstract class HttpClient {
  String get baseUrl;
  
  Future<Either<HttpException, HttpResponse>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  });
  
  Future<Either<HttpException, HttpResponse>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
}
```

#### **Dio Implementation with Interceptors**
```dart
class HttpClientImpl implements HttpClient {
  final Dio _dio;
  final List<Interceptor> _interceptors;
  
  HttpClientImpl({
    required String baseUrl,
    List<Interceptor>? interceptors,
  }) : _interceptors = interceptors ?? [] {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
    ));
    
    // Add interceptors
    _dio.interceptors.addAll([
      LoggerInterceptor(), // Request/response logging
      AuthInterceptor(),   // Authentication headers
      RetryInterceptor(),  // Automatic retry logic
      ..._interceptors,
    ]);
  }
  
  @override
  Future<Either<HttpException, HttpResponse>> get(String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );
      
      return Right(HttpResponse.fromDioResponse(response));
    } on DioException catch (e) {
      return Left(HttpException.fromDioException(e));
    }
  }
}
```

#### **Error Handling Strategy**
```dart
enum HttpErrorType {
  network,
  timeout,
  authentication,
  authorization,
  serverError,
  clientError,
  unknown,
  noInternet,
  cancelled,
}

class HttpException extends Equatable implements Exception {
  final HttpErrorType type;
  final int? statusCode;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? headers;
  final String? requestPath;
  final DateTime timestamp;
  
  const HttpException({
    required this.type,
    required this.message,
    this.statusCode,
    this.data,
    this.headers,
    this.requestPath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  static HttpException fromDioException(DioException dioException) {
    final response = dioException.response;
    
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return HttpException(
          type: HttpErrorType.timeout,
          message: 'Request timeout: ${dioException.message}',
          requestPath: dioException.requestOptions.path,
        );
        
      case DioExceptionType.connectionError:
        return HttpException(
          type: HttpErrorType.network,
          message: 'Network connection failed',
          requestPath: dioException.requestOptions.path,
        );
        
      case DioExceptionType.badResponse:
        final statusCode = response?.statusCode;
        if (statusCode != null) {
          if (statusCode == 401) {
            return HttpException(
              type: HttpErrorType.authentication,
              statusCode: statusCode,
              message: 'Authentication failed',
              data: response?.data,
              headers: response?.headers.map,
              requestPath: dioException.requestOptions.path,
            );
          } else if (statusCode == 403) {
            return HttpException(
              type: HttpErrorType.authorization,
              statusCode: statusCode,
              message: 'Access forbidden',
              data: response?.data,
              requestPath: dioException.requestOptions.path,
            );
          } else if (statusCode >= 500) {
            return HttpException(
              type: HttpErrorType.serverError,
              statusCode: statusCode,
              message: 'Server error: ${response?.statusMessage}',
              data: response?.data,
              requestPath: dioException.requestOptions.path,
            );
          } else if (statusCode >= 400) {
            return HttpException(
              type: HttpErrorType.clientError,
              statusCode: statusCode,
              message: 'Client error: ${response?.statusMessage}',
              data: response?.data,
              requestPath: dioException.requestOptions.path,
            );
          }
        }
        break;
        
      case DioExceptionType.cancel:
        return HttpException(
          type: HttpErrorType.cancelled,
          message: 'Request was cancelled',
          requestPath: dioException.requestOptions.path,
        );
        
      default:
        return HttpException(
          type: HttpErrorType.unknown,
          message: dioException.message ?? 'Unknown error occurred',
          requestPath: dioException.requestOptions.path,
        );
    }
    
    return HttpException(
      type: HttpErrorType.unknown,
      message: 'Unknown error occurred',
      requestPath: dioException.requestOptions.path,
    );
  }
  
  @override
  List<Object?> get props => [
    type, statusCode, message, data, headers, requestPath, timestamp
  ];
  
  @override
  String toString() {
    return 'HttpException(type: $type, statusCode: $statusCode, message: $message, path: $requestPath)';
  }
}
```

#### **Comprehensive Interceptor System**

The HTTP layer supports a sophisticated interceptor system for cross-cutting concerns:

##### **Base Interceptor Interface**
```dart
// packages/adapters/http_client/lib/src/interceptors/base_interceptor.dart
abstract class HttpInterceptor {
  const HttpInterceptor();
  
  /// Called before the request is sent
  Future<RequestOptions> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    return options;
  }
  
  /// Called when response is received successfully
  Future<Response> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    return response;
  }
  
  /// Called when an error occurs
  Future<DioException> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    return error;
  }
}
```

##### **Authentication Interceptor**
```dart
// packages/adapters/http_client/lib/src/interceptors/auth_interceptor.dart
class AuthInterceptor extends HttpInterceptor {
  final TokenRepository _tokenRepository;
  final AuthenticationRepository _authRepository;
  
  AuthInterceptor({
    required TokenRepository tokenRepository,
    required AuthenticationRepository authRepository,
  }) : _tokenRepository = tokenRepository,
       _authRepository = authRepository;
  
  @override
  Future<RequestOptions> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      return options;
    }
    
    // Add authentication header
    final token = await _tokenRepository.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add user context headers
    final userId = await _authRepository.getCurrentUserId();
    if (userId != null) {
      options.headers['X-User-ID'] = userId;
    }
    
    return options;
  }
  
  @override
  Future<DioException> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 unauthorized - refresh token
    if (error.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the original request with new token
          final retryResponse = await _retryRequest(error.requestOptions);
          return DioException(
            requestOptions: error.requestOptions,
            response: retryResponse,
          );
        }
      } catch (e) {
        // Refresh failed, redirect to login
        await _authRepository.logout();
        // Trigger app-wide navigation to login screen
      }
    }
    
    return error;
  }
  
  bool _isPublicEndpoint(String path) {
    const publicPaths = ['/auth/login', '/auth/register', '/health'];
    return publicPaths.any((publicPath) => path.startsWith(publicPath));
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenRepository.getRefreshToken();
      if (refreshToken == null) return false;
      
      final newTokens = await _authRepository.refreshTokens(refreshToken);
      await _tokenRepository.saveTokens(
        accessToken: newTokens.accessToken,
        refreshToken: newTokens.refreshToken,
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<Response> _retryRequest(RequestOptions options) async {
    final token = await _tokenRepository.getAccessToken();
    options.headers['Authorization'] = 'Bearer $token';
    
    final dio = Dio();
    return await dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: options.headers,
      ),
    );
  }
}
```

##### **Logging Interceptor**
```dart
// packages/adapters/http_client/lib/src/interceptors/logger_interceptor.dart
class LoggerInterceptor extends HttpInterceptor {
  final Logger _logger;
  final bool logRequestBody;
  final bool logResponseBody;
  final List<String> sensitiveHeaders;
  
  LoggerInterceptor({
    Logger? logger,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.sensitiveHeaders = const ['authorization', 'cookie', 'set-cookie'],
  }) : _logger = logger ?? Logger('HttpClient');
  
  @override
  Future<RequestOptions> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final startTime = DateTime.now();
    options.extra['startTime'] = startTime;
    
    _logger.info('→ ${options.method} ${options.uri}');
    _logger.info('Headers: ${_filterSensitiveHeaders(options.headers)}');
    
    if (logRequestBody && options.data != null) {
      _logger.info('Body: ${_formatData(options.data)}');
    }
    
    return options;
  }
  
  @override
  Future<Response> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final startTime = response.requestOptions.extra['startTime'] as DateTime?;
    final duration = startTime != null 
      ? DateTime.now().difference(startTime)
      : Duration.zero;
    
    _logger.info('← ${response.statusCode} ${response.requestOptions.uri} (${duration.inMilliseconds}ms)');
    _logger.info('Headers: ${_filterSensitiveHeaders(response.headers.map)}');
    
    if (logResponseBody && response.data != null) {
      _logger.info('Body: ${_formatData(response.data)}');
    }
    
    return response;
  }
  
  @override
  Future<DioException> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final startTime = error.requestOptions.extra['startTime'] as DateTime?;
    final duration = startTime != null 
      ? DateTime.now().difference(startTime)
      : Duration.zero;
    
    _logger.error('✗ ${error.requestOptions.method} ${error.requestOptions.uri} (${duration.inMilliseconds}ms)');
    _logger.error('Error: ${error.message}');
    
    if (error.response != null) {
      _logger.error('Status: ${error.response!.statusCode}');
      _logger.error('Data: ${_formatData(error.response!.data)}');
    }
    
    return error;
  }
  
  Map<String, dynamic> _filterSensitiveHeaders(Map<String, dynamic> headers) {
    final filtered = <String, dynamic>{};
    headers.forEach((key, value) {
      if (sensitiveHeaders.contains(key.toLowerCase())) {
        filtered[key] = '[FILTERED]';
      } else {
        filtered[key] = value;
      }
    });
    return filtered;
  }
  
  String _formatData(dynamic data) {
    if (data is Map || data is List) {
      try {
        return JsonEncoder.withIndent('  ').convert(data);
      } catch (e) {
        return data.toString();
      }
    }
    return data.toString();
  }
}
```

##### **Retry Interceptor**
```dart
// packages/adapters/http_client/lib/src/interceptors/retry_interceptor.dart
class RetryInterceptor extends HttpInterceptor {
  final int maxRetries;
  final Duration baseDelay;
  final List<int> retryStatusCodes;
  final bool useExponentialBackoff;
  
  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.retryStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.useExponentialBackoff = true,
  });
  
  @override
  Future<DioException> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final shouldRetry = _shouldRetry(error);
    if (!shouldRetry) return error;
    
    final retryCount = error.requestOptions.extra['retryCount'] ?? 0;
    if (retryCount >= maxRetries) return error;
    
    final delay = useExponentialBackoff
      ? Duration(milliseconds: baseDelay.inMilliseconds * (2 << retryCount))
      : baseDelay;
    
    await Future.delayed(delay);
    
    try {
      error.requestOptions.extra['retryCount'] = retryCount + 1;
      
      final dio = Dio();
      final response = await dio.request(
        error.requestOptions.path,
        data: error.requestOptions.data,
        queryParameters: error.requestOptions.queryParameters,
        options: Options(
          method: error.requestOptions.method,
          headers: error.requestOptions.headers,
        ),
      );
      
      return DioException(
        requestOptions: error.requestOptions,
        response: response,
      );
    } catch (retryError) {
      if (retryError is DioException) {
        return retryError;
      }
      return error;
    }
  }
  
  bool _shouldRetry(DioException error) {
    // Retry on network errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }
    
    // Retry on specific status codes
    final statusCode = error.response?.statusCode;
    return statusCode != null && retryStatusCodes.contains(statusCode);
  }
}
```

##### **Cache Interceptor**
```dart
// packages/adapters/http_client/lib/src/interceptors/cache_interceptor.dart
class CacheInterceptor extends HttpInterceptor {
  final CacheManager _cacheManager;
  final Duration defaultCacheDuration;
  final List<String> cacheableMethods;
  
  CacheInterceptor({
    required CacheManager cacheManager,
    this.defaultCacheDuration = const Duration(minutes: 5),
    this.cacheableMethods = const ['GET'],
  }) : _cacheManager = cacheManager;
  
  @override
  Future<RequestOptions> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Only cache GET requests by default
    if (!cacheableMethods.contains(options.method.toUpperCase())) {
      return options;
    }
    
    final cacheKey = _generateCacheKey(options);
    final cachedResponse = await _cacheManager.get(cacheKey);
    
    if (cachedResponse != null && !_isCacheExpired(cachedResponse)) {
      // Return cached response
      throw DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          data: cachedResponse.data,
          statusCode: cachedResponse.statusCode,
          headers: Headers.fromMap(cachedResponse.headers),
        ),
      );
    }
    
    return options;
  }
  
  @override
  Future<Response> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (cacheableMethods.contains(response.requestOptions.method.toUpperCase()) &&
        response.statusCode == 200) {
      final cacheKey = _generateCacheKey(response.requestOptions);
      final cacheData = CacheData(
        data: response.data,
        statusCode: response.statusCode!,
        headers: response.headers.map,
        timestamp: DateTime.now(),
      );
      
      await _cacheManager.put(cacheKey, cacheData);
    }
    
    return response;
  }
  
  String _generateCacheKey(RequestOptions options) {
    final uri = options.uri.toString();
    final headers = options.headers.toString();
    return '${options.method}_${uri}_${headers.hashCode}';
  }
  
  bool _isCacheExpired(CacheData cacheData) {
    return DateTime.now().difference(cacheData.timestamp) > defaultCacheDuration;
  }
}
```

##### **Interceptor Usage and Registration**
```dart
// packages/adapters/http_client/lib/src/http_client_impl.dart
class HttpClientImpl implements HttpClient {
  final Dio _dio;
  
  HttpClientImpl({
    required String baseUrl,
    required List<HttpInterceptor> interceptors,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout ?? Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? Duration(seconds: 30),
      sendTimeout: sendTimeout ?? Duration(seconds: 30),
    ));
    
    // Register interceptors in order of execution
    for (final interceptor in interceptors) {
      _dio.interceptors.add(_wrapInterceptor(interceptor));
    }
  }
  
  InterceptorsWrapper _wrapInterceptor(HttpInterceptor interceptor) {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final modifiedOptions = await interceptor.onRequest(options, handler);
          handler.next(modifiedOptions);
        } catch (e) {
          handler.reject(e as DioException);
        }
      },
      onResponse: (response, handler) async {
        try {
          final modifiedResponse = await interceptor.onResponse(response, handler);
          handler.next(modifiedResponse);
        } catch (e) {
          handler.reject(e as DioException);
        }
      },
      onError: (error, handler) async {
        try {
          final modifiedError = await interceptor.onError(error, handler);
          handler.next(modifiedError);
        } catch (e) {
          handler.next(e as DioException);
        }
      },
    );
  }
}
```

### 4. 🧭 Named Routing System & Navigation Protection

The routing system provides sophisticated navigation with guards, transitions, deep linking, and critical stack protection mechanisms:

#### **Navigation Stack Protection**

One of the most critical aspects of navigation management is preventing black screens and navigation errors:

```dart
// packages/shared/routing/lib/src/navigation_manager.dart
class NavigationManager {
  static NavigationManager? _instance;
  static NavigationManager get instance => _instance ??= NavigationManager._();
  NavigationManager._();

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final List<Route> _routeStack = <Route>[];
  final Logger _logger = Logger('NavigationManager');

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  
  /// Get current route stack size for protection mechanisms
  int get stackSize => _routeStack.length;
  
  /// Check if we can safely pop (prevent black screen)
  bool get canPop => _routeStack.length > 1;
  
  /// Get current route name for debugging and analytics
  String? get currentRouteName => 
    _routeStack.isNotEmpty ? _routeStack.last.settings.name : null;

  /// Initialize navigation manager with observer
  void initialize() {
    // Navigator observer to track route changes
    final observer = NavigationStackObserver(
      onDidPush: _onDidPush,
      onDidPop: _onDidPop,
      onDidRemove: _onDidRemove,
      onDidReplace: _onDidReplace,
    );
    
    // Register observer in main app
    _observers.add(observer);
  }

  /// Safe navigation with stack protection
  Future<T?> navigateTo<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool clearStack = false,
    bool replaceIfSame = true,
  }) async {
    try {
      final context = _navigatorKey.currentContext;
      if (context == null) {
        _logger.error('Navigation context is null - cannot navigate to $routeName');
        return null;
      }

      // Prevent navigation to same route if configured
      if (replaceIfSame && currentRouteName == routeName) {
        _logger.info('Already on route $routeName - skipping navigation');
        return null;
      }

      if (clearStack) {
        return await _navigateAndClearStack<T>(routeName, arguments);
      } else {
        return await Navigator.pushNamed<T>(
          context,
          routeName,
          arguments: arguments,
        );
      }
    } catch (e, stackTrace) {
      _logger.error('Navigation error to $routeName', e, stackTrace);
      // Fallback to safe route if navigation fails
      await _navigateToFallbackRoute();
      return null;
    }
  }

  /// Safe pop with black screen protection
  void pop<T extends Object?>([T? result]) {
    try {
      final context = _navigatorKey.currentContext;
      if (context == null) {
        _logger.error('Navigation context is null - cannot pop');
        return;
      }

      // Critical protection: never pop the last route
      if (!canPop) {
        _logger.warning('Attempted to pop last route - redirecting to home');
        navigateTo('/home');
        return;
      }

      Navigator.pop<T>(context, result);
    } catch (e, stackTrace) {
      _logger.error('Pop error', e, stackTrace);
      // Emergency fallback
      _handleNavigationEmergency();
    }
  }

  /// Pop until specific route with protection
  void popUntil(String routeName) {
    try {
      final context = _navigatorKey.currentContext;
      if (context == null) return;

      // Find target route in stack
      final targetRouteExists = _routeStack.any(
        (route) => route.settings.name == routeName,
      );

      if (!targetRouteExists) {
        _logger.warning('Target route $routeName not found in stack');
        navigateTo(routeName); // Navigate to it instead
        return;
      }

      Navigator.popUntil(
        context,
        (route) => route.settings.name == routeName,
      );
    } catch (e, stackTrace) {
      _logger.error('PopUntil error for route $routeName', e, stackTrace);
      _handleNavigationEmergency();
    }
  }

  /// Navigate and clear stack with protection
  Future<T?> _navigateAndClearStack<T>(String routeName, Object? arguments) async {
    final context = _navigatorKey.currentContext;
    if (context == null) return null;

    return await Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false, // Remove all routes
      arguments: arguments,
    );
  }

  /// Handle navigation emergencies (critical fallback)
  void _handleNavigationEmergency() {
    _logger.critical('Navigation emergency - clearing stack and going to home');
    
    try {
      // Clear the entire stack and go to a known safe route
      navigateTo('/home', clearStack: true);
    } catch (e) {
      // If even home fails, restart the app
      _logger.critical('Home navigation failed - app restart needed');
      // Trigger app restart mechanism
      _restartApp();
    }
  }

  /// Navigate to fallback route when primary navigation fails
  Future<void> _navigateToFallbackRoute() async {
    const fallbackRoutes = ['/home', '/splash', '/'];
    
    for (final route in fallbackRoutes) {
      try {
        await navigateTo(route, clearStack: true);
        return;
      } catch (e) {
        _logger.warning('Fallback route $route failed');
      }
    }
    
    // If all fallbacks fail, trigger emergency
    _handleNavigationEmergency();
  }

  /// Restart app (platform-specific implementation)
  void _restartApp() {
    // Implementation would depend on platform
    // For Flutter, this might involve Phoenix.rebirth() or similar
  }

  /// Route stack observers
  void _onDidPush(Route route, Route? previousRoute) {
    _routeStack.add(route);
    _logger.info('Route pushed: ${route.settings.name} (Stack: ${_routeStack.length})');
    
    // Analytics tracking
    _trackNavigation('push', route.settings.name, previousRoute?.settings.name);
  }

  void _onDidPop(Route route, Route? previousRoute) {
    if (_routeStack.isNotEmpty) {
      _routeStack.removeLast();
    }
    _logger.info('Route popped: ${route.settings.name} (Stack: ${_routeStack.length})');
    
    // Analytics tracking
    _trackNavigation('pop', previousRoute?.settings.name, route.settings.name);
  }

  void _onDidRemove(Route route, Route? previousRoute) {
    _routeStack.remove(route);
    _logger.info('Route removed: ${route.settings.name} (Stack: ${_routeStack.length})');
  }

  void _onDidReplace(Route route, Route? previousRoute) {
    final index = _routeStack.indexOf(previousRoute!);
    if (index != -1) {
      _routeStack[index] = route;
    }
    _logger.info('Route replaced: ${previousRoute.settings.name} -> ${route.settings.name}');
  }

  void _trackNavigation(String action, String? from, String? to) {
    // Send navigation analytics
    // Analytics.track('navigation', {
    //   'action': action,
    //   'from': from,
    //   'to': to,
    //   'stackSize': _routeStack.length,
    // });
  }
}
```

#### **Route Stack Observer Implementation**
```dart
// packages/shared/routing/lib/src/navigation_stack_observer.dart
class NavigationStackObserver extends NavigatorObserver {
  final Function(Route, Route?) onDidPush;
  final Function(Route, Route?) onDidPop;
  final Function(Route, Route?) onDidRemove;
  final Function(Route, Route?) onDidReplace;

  NavigationStackObserver({
    required this.onDidPush,
    required this.onDidPop,
    required this.onDidRemove,
    required this.onDidReplace,
  });

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    onDidPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    onDidPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    onDidRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null && oldRoute != null) {
      onDidReplace(newRoute, oldRoute);
    }
  }
}
```

#### **Module Navigation Isolation**

Navigation between modules requires careful isolation to prevent cross-dependencies:

```dart
// packages/shared/routing/lib/src/module_navigator.dart
abstract class ModuleNavigator {
  /// Navigate within the same module
  Future<T?> navigateInModule<T>(String routeName, {Object? arguments});
  
  /// Navigate to another module (requires delegate)
  Future<T?> navigateToModule<T>(
    String moduleName,
    String routeName, {
    Object? arguments,
  });
  
  /// Check if route exists in this module
  bool hasRoute(String routeName);
}

class ModuleNavigatorImpl implements ModuleNavigator {
  final String _moduleName;
  final Map<String, RouteBuilder> _routes;
  final ModuleNavigationDelegate _delegate;

  ModuleNavigatorImpl({
    required String moduleName,
    required Map<String, RouteBuilder> routes,
    required ModuleNavigationDelegate delegate,
  }) : _moduleName = moduleName,
       _routes = routes,
       _delegate = delegate;

  @override
  Future<T?> navigateInModule<T>(String routeName, {Object? arguments}) async {
    if (!_routes.containsKey(routeName)) {
      throw ModuleNavigationException(
        'Route $routeName not found in module $_moduleName',
      );
    }

    // Use global navigation manager for actual navigation
    return NavigationManager.instance.navigateTo<T>(
      '/$_moduleName$routeName',
      arguments: arguments,
    );
  }

  @override
  Future<T?> navigateToModule<T>(
    String moduleName,
    String routeName, {
    Object? arguments,
  }) async {
    // Delegate to main app for cross-module navigation
    return _delegate.navigateToModule<T>(
      moduleName,
      routeName,
      arguments: arguments,
    );
  }

  @override
  bool hasRoute(String routeName) => _routes.containsKey(routeName);
}
```

#### **Navigation Safety Middleware**
```dart
// packages/shared/routing/lib/src/navigation_middleware.dart
class NavigationMiddleware {
  static final List<NavigationInterceptor> _interceptors = [];
  
  static void addInterceptor(NavigationInterceptor interceptor) {
    _interceptors.add(interceptor);
  }
  
  static Future<NavigationResult> processNavigation(
    NavigationRequest request,
  ) async {
    NavigationRequest currentRequest = request;
    
    for (final interceptor in _interceptors) {
      final result = await interceptor.intercept(currentRequest);
      
      if (result.shouldStop) {
        return result;
      }
      
      if (result.modifiedRequest != null) {
        currentRequest = result.modifiedRequest!;
      }
    }
    
    return NavigationResult.proceed(currentRequest);
  }
}

abstract class NavigationInterceptor {
  Future<NavigationResult> intercept(NavigationRequest request);
}

// Example: Authentication check interceptor
class AuthenticationInterceptor implements NavigationInterceptor {
  final AuthenticationRepository _auth;
  
  AuthenticationInterceptor(this._auth);
  
  @override
  Future<NavigationResult> intercept(NavigationRequest request) async {
    final requiresAuth = _requiresAuthentication(request.routeName);
    
    if (requiresAuth && !await _auth.isAuthenticated()) {
      // Redirect to login
      return NavigationResult.redirect('/login');
    }
    
    return NavigationResult.proceed(request);
  }
  
  bool _requiresAuthentication(String routeName) {
    const publicRoutes = ['/login', '/register', '/splash'];
    return !publicRoutes.contains(routeName);
  }
}

class NavigationRequest {
  final String routeName;
  final Object? arguments;
  final Map<String, dynamic> metadata;
  
  const NavigationRequest({
    required this.routeName,
    this.arguments,
    this.metadata = const {},
  });
}

class NavigationResult {
  final bool shouldStop;
  final NavigationRequest? modifiedRequest;
  final String? redirectTo;
  
  const NavigationResult._({
    required this.shouldStop,
    this.modifiedRequest,
    this.redirectTo,
  });
  
  factory NavigationResult.proceed(NavigationRequest request) {
    return NavigationResult._(shouldStop: false, modifiedRequest: request);
  }
  
  factory NavigationResult.redirect(String routeName) {
    return NavigationResult._(shouldStop: true, redirectTo: routeName);
  }
  
  factory NavigationResult.stop() {
    return NavigationResult._(shouldStop: true);
  }
}
```

#### **Advanced Route Definition Architecture**

The routing system provides sophisticated navigation with guards, transitions, and deep linking:

#### **Route Definition Architecture**
```dart
// packages/shared/routing/
class CineRoute {
  static PageRoute<T> page<T>({
    required Widget child,
    RouteSettings? settings,
    List<RouteGuard>? guards,
  }) {
    return GuardedPageRoute<T>(
      builder: (_) => child,
      settings: settings,
      guards: guards ?? [],
    );
  }
  
  static PageRoute<T> fadeTransition<T>({
    required Widget child,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
    List<RouteGuard>? guards,
  }) {
    return GuardedPageRoute<T>(
      pageBuilder: (context, animation, _) => child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      settings: settings,
      guards: guards ?? [],
    );
  }
}
```

#### **Route Guards Implementation**
```dart
abstract class RouteGuard {
  Future<bool> canActivate(BuildContext context, RouteSettings settings);
  Future<void> onActivationFailed(BuildContext context, RouteSettings settings);
}

class AuthenticationGuard implements RouteGuard {
  final AuthenticationRepository _auth;
  
  @override
  Future<bool> canActivate(BuildContext context, RouteSettings settings) async {
    return await _auth.isAuthenticated();
  }
  
  @override
  Future<void> onActivationFailed(BuildContext context, RouteSettings settings) async {
    Navigator.pushNamedAndClearUntil(
      context, 
      '/login',
      (route) => false,
    );
  }
}
```

#### **Centralized Route Management**
```dart
// app/lib/core/app_routes.dart
class AppRoutes {
  // Route constants
  static const String splash = '/splash';
  static const String home = '/home';
  static const String movieDetails = '/movies/:movieId';
  static const String userProfile = '/profile/:userId';
  
  // Route generation
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final routeData = RouteData.fromSettings(settings);
    
    switch (routeData.name) {
      case splash:
        return CineRoute.fadeTransition(
          child: const SplashPage(),
          settings: settings,
        );
        
      case home:
        return CineRoute.page(
          child: const HomePage(),
          settings: settings,
          guards: [AuthenticationGuard()],
        );
        
      case movieDetails:
        final movieId = routeData.pathParameters['movieId'];
        return CineRoute.slideTransition(
          child: MovieDetailsPage(movieId: movieId ?? ''),
          settings: settings,
          direction: SlideDirection.fromRight,
        );
        
      default:
        return CineRoute.page(
          child: const NotFoundPage(),
          settings: settings,
        );
    }
  }
  
  // Type-safe navigation helpers
  static Future<void> navigateToMovieDetails(
    BuildContext context, 
    String movieId,
  ) {
    return Navigator.pushNamed(
      context, 
      movieDetails.replaceAll(':movieId', movieId),
    );
  }
}
```

#### **Deep Linking Support**
```dart
// app/lib/core/deep_link_handler.dart
class DeepLinkHandler {
  static Route<dynamic>? handleDeepLink(String link) {
    final uri = Uri.parse(link);
    final pathSegments = uri.pathSegments;
    
    // Handle different deep link patterns
    switch (pathSegments.first) {
      case 'movie':
        if (pathSegments.length >= 2) {
          return AppRoutes.generateRoute(
            RouteSettings(
              name: AppRoutes.movieDetails,
              arguments: {'movieId': pathSegments[1]},
            ),
          );
        }
        break;
      case 'share':
        return _handleShareLink(uri);
    }
    
    return null;
  }
}
```

### 5. 📦 Module Structure Implementation

Each feature module follows strict Clean Architecture with complete isolation:

#### **Feature Module Structure**
```
packages/features/movies/
├── lib/
│   ├── domain/                    # Business logic layer
│   │   ├── entities/             # Core business objects
│   │   │   └── movie.dart
│   │   ├── repositories/         # Abstract data contracts  
│   │   │   └── movie_repository.dart
│   │   ├── usecases/            # Business use cases
│   │   │   ├── get_movies.dart
│   │   │   ├── search_movies.dart
│   │   │   └── add_to_favorites.dart
│   │   └── errors/              # Domain-specific errors
│   │       └── movie_errors.dart
│   ├── data/                     # Data layer
│   │   ├── datasources/         # Data sources (API, local)
│   │   │   ├── movie_remote_datasource.dart
│   │   │   └── movie_local_datasource.dart
│   │   ├── models/              # Data transfer objects
│   │   │   └── movie_model.dart
│   │   ├── repositories/        # Repository implementations
│   │   │   └── movie_repository_impl.dart
│   │   └── mappers/             # Data mapping logic
│   │       └── movie_mapper.dart
│   ├── presentation/            # Presentation layer
│   │   ├── bloc/               # State management
│   │   │   ├── movies_bloc.dart
│   │   │   ├── movies_event.dart
│   │   │   └── movies_state.dart
│   │   ├── pages/              # Screens/Pages
│   │   │   ├── movies_list_page.dart
│   │   │   └── movie_details_page.dart
│   │   └── widgets/            # Reusable widgets
│   │       ├── movie_card.dart
│   │       └── movie_rating.dart
│   └── movies.dart             # Public API exports
├── test/                       # Feature tests
│   ├── domain/
│   ├── data/
│   └── presentation/
└── pubspec.yaml
```

#### **Clean Architecture Implementation**
```dart
// Domain layer - movies/lib/domain/entities/movie.dart
class Movie extends Equatable {
  final String id;
  final String title;
  final String overview;
  final DateTime releaseDate;
  final double rating;
  final String posterUrl;
  
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.releaseDate,
    required this.rating,
    required this.posterUrl,
  });
  
  @override
  List<Object?> get props => [id, title, overview, releaseDate, rating, posterUrl];
}

// Domain layer - Repository contract
abstract class MovieRepository {
  Future<Either<MovieFailure, List<Movie>>> getPopularMovies({int page = 1});
  Future<Either<MovieFailure, List<Movie>>> searchMovies(String query);
  Future<Either<MovieFailure, Movie>> getMovieDetails(String id);
}

// Use case implementation
class GetPopularMovies {
  final MovieRepository _repository;
  
  GetPopularMovies(this._repository);
  
  Future<Either<MovieFailure, List<Movie>>> call({int page = 1}) {
    return _repository.getPopularMovies(page: page);
  }
}
```

#### **Data Layer Implementation**
```dart
// Data layer - movies/lib/data/repositories/movie_repository_impl.dart
class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource _remoteDataSource;
  final MovieLocalDataSource _localDataSource;
  final ConnectivityClient _connectivity;
  
  MovieRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
  );
  
  @override
  Future<Either<MovieFailure, List<Movie>>> getPopularMovies({int page = 1}) async {
    try {
      // Check connectivity
      if (await _connectivity.hasInternetAccess()) {
        // Fetch from remote
        final remoteMovies = await _remoteDataSource.getPopularMovies(page: page);
        
        // Cache locally
        await _localDataSource.cacheMovies(remoteMovies);
        
        return Right(remoteMovies.map((model) => model.toEntity()).toList());
      } else {
        // Fallback to local cache
        final cachedMovies = await _localDataSource.getCachedMovies();
        return Right(cachedMovies.map((model) => model.toEntity()).toList());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
```

#### **Presentation Layer with BLoC**
```dart
// Presentation layer - movies/lib/presentation/bloc/movies_bloc.dart
class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final GetPopularMovies _getPopularMovies;
  final SearchMovies _searchMovies;
  
  MoviesBloc({
    required GetPopularMovies getPopularMovies,
    required SearchMovies searchMovies,
  }) : _getPopularMovies = getPopularMovies,
       _searchMovies = searchMovies,
       super(MoviesInitial()) {
    on<MoviesLoadPopular>(_onLoadPopular);
    on<MoviesSearch>(_onSearch);
    on<MoviesLoadMore>(_onLoadMore);
  }
  
  Future<void> _onLoadPopular(
    MoviesLoadPopular event,
    Emitter<MoviesState> emit,
  ) async {
    emit(MoviesLoading());
    
    final result = await _getPopularMovies(page: 1);
    
    result.fold(
      (failure) => emit(MoviesError(failure.message)),
      (movies) => emit(MoviesLoaded(
        movies: movies,
        hasReachedMax: movies.length < 20,
        currentPage: 1,
      )),
    );
  }
}
```

### 6. 🤖 Robot Testing Implementation

The Robot testing pattern provides maintainable, readable UI tests:

#### **Robot Base Class**
```dart
// packages/dev_util/lib/robot/robot.dart
abstract class Robot<S extends RobotScenario> {
  final WidgetTester tester;
  final NavigatorObserver navigatorObserver;
  S? _scenario;
  
  Robot({
    required this.tester,
    S? scenario,
  }) : _scenario = scenario {
    navigatorObserver = NavigatorObserverMock();
  }
  
  // Configuration and setup
  Future<void> configure({S? scenario}) async {
    _scenario = scenario ?? _scenario;
    await _scenario?.injectDependencies();
    await _scenario?.mockScenario();
    await _pumpWidget();
  }
  
  // Widget building - to be implemented by subclasses
  Widget build();
  
  // Pump widget with theming and localization
  Future<void> _pumpWidget() async {
    await tester.pumpWidget(
      MaterialApp(
        home: build(),
        navigatorObservers: [navigatorObserver],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
      ),
    );
    await awaitForAnimations();
  }
  
  // Animation handling
  Future<void> awaitForAnimations() async {
    await tester.pumpAndSettle();
  }
  
  // Golden testing
  Future<void> takeSnapshot(String filename) async {
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('golden_files/$filename.png'),
    );
  }
  
  // Navigation assertions
  void assertNavigatorRoute(String routeName) {
    verify(() => navigatorObserver.didPush(any(), any()));
  }
}
```

#### **Robot Element Helper**
```dart
// packages/dev_util/lib/robot/robot_element.dart
class RobotElement {
  final Finder finder;
  final WidgetTester tester;
  
  const RobotElement({required this.finder, required this.tester});
  
  // Factory constructors
  factory RobotElement.byKey(Key key, WidgetTester tester) {
    return RobotElement(finder: find.byKey(key), tester: tester);
  }
  
  factory RobotElement.byType(Type type, WidgetTester tester) {
    return RobotElement(finder: find.byType(type), tester: tester);
  }
  
  factory RobotElement.byText(String text, WidgetTester tester) {
    return RobotElement(finder: find.text(text), tester: tester);
  }
  
  // Visibility checks
  bool isVisible() => tester.any(finder);
  void assertIsVisible() => expect(finder, findsOneWidget);
  void assertIsNotVisible() => expect(finder, findsNothing);
  
  // Interactions
  Future<void> tap() async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
  
  Future<void> enterText(String text) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }
  
  Future<void> scrollTo({double delta = 100}) async {
    await tester.drag(finder, Offset(0, delta));
    await tester.pumpAndSettle();
  }
  
  // Content assertions
  void assertHasText(String expectedText) {
    expect(find.descendant(of: finder, matching: find.text(expectedText)), findsOneWidget);
  }
  
  void assertIsEnabled() {
    final widget = tester.widget(finder);
    expect(widget, isA<Widget>().having((w) => _isEnabled(w), 'enabled', true));
  }
  
  bool _isEnabled(Widget widget) {
    if (widget is ElevatedButton) return widget.onPressed != null;
    if (widget is TextButton) return widget.onPressed != null;
    if (widget is TextField) return widget.enabled ?? true;
    return true;
  }
}
```

#### **Scenario Pattern**
```dart
// Robot scenario for dependency injection and mocking
abstract class RobotScenario {
  Future<void> injectDependencies();
  Future<void> mockScenario();
}

class MoviesPageScenario extends RobotScenario {
  late MockMoviesBloc mockMoviesBloc;
  late List<Movie> mockMovies;
  
  @override
  Future<void> injectDependencies() async {
    mockMoviesBloc = MockMoviesBloc();
    
    // Inject mocks into service locator
    GetIt.instance.registerFactory<MoviesBloc>(() => mockMoviesBloc);
  }
  
  @override
  Future<void> mockScenario() async {
    // Create mock data
    mockMovies = [
      const Movie(
        id: '1',
        title: 'Test Movie',
        overview: 'A test movie',
        releaseDate: '2023-01-01',
        rating: 8.5,
        posterUrl: 'https://example.com/poster.jpg',
      ),
    ];
    
    // Setup mock responses
    when(() => mockMoviesBloc.state).thenReturn(
      MoviesLoaded(movies: mockMovies, hasReachedMax: false, currentPage: 1),
    );
    
    when(() => mockMoviesBloc.stream).thenAnswer(
      (_) => Stream.value(MoviesLoaded(movies: mockMovies, hasReachedMax: false, currentPage: 1)),
    );
  }
}
```

#### **Page Robot Implementation**
```dart
// Feature-specific robot
class MoviesPageRobot extends Robot<MoviesPageScenario> {
  MoviesPageRobot(WidgetTester tester) : super(tester: tester);
  
  @override
  Widget build() {
    return BlocProvider(
      create: (_) => GetIt.instance<MoviesBloc>(),
      child: const MoviesListPage(),
    );
  }
  
  // Page elements
  RobotElement get loadingIndicator => RobotElement.byType(CircularProgressIndicator, tester);
  RobotElement get errorMessage => RobotElement.byKey(const Key('error_message'), tester);
  RobotElement get moviesList => RobotElement.byType(ListView, tester);
  RobotElement get searchField => RobotElement.byKey(const Key('search_field'), tester);
  RobotElement get refreshButton => RobotElement.byKey(const Key('refresh_button'), tester);
  
  // Helper methods for complex interactions
  RobotElement movieCard(String movieId) {
    return RobotElement.byKey(Key('movie_card_$movieId'), tester);
  }
  
  // Page actions
  Future<void> searchForMovie(String query) async {
    await searchField.enterText(query);
    await awaitForAnimations();
  }
  
  Future<void> tapMovieCard(String movieId) async {
    await movieCard(movieId).tap();
    await awaitForAnimations();
  }
  
  Future<void> refreshMoviesList() async {
    await refreshButton.tap();
    await awaitForAnimations();
  }
  
  // Assertions
  void assertMoviesLoaded() {
    loadingIndicator.assertIsNotVisible();
    moviesList.assertIsVisible();
  }
  
  void assertMovieDisplayed(String title) {
    final movieTitleFinder = find.text(title);
    expect(movieTitleFinder, findsOneWidget);
  }
  
  void assertErrorShown(String errorMessage) {
    errorMessage.assertIsVisible();
    errorMessage.assertHasText(errorMessage);
  }
}
```

#### **Robot Test Implementation**
```dart
// test/robot/movies_page_robot_test.dart
void main() {
  group('MoviesPageRobot Tests', () {
    late MoviesPageRobot robot;
    late MoviesPageScenario scenario;
    
    setUp(() async {
      // Reset service locator
      GetIt.instance.reset();
      
      // Create scenario and robot
      scenario = MoviesPageScenario();
      robot = MoviesPageRobot(tester);
      
      // Configure robot with scenario
      await robot.configure(scenario: scenario);
    });
    
    testWidgets('should display movies when loaded', (tester) async {
      // Given - movies are loaded (mocked in scenario)
      
      // When - page is displayed
      // (already pumped in configure)
      
      // Then - movies should be visible
      robot.assertMoviesLoaded();
      robot.assertMovieDisplayed('Test Movie');
    });
    
    testWidgets('should navigate to movie details when movie tapped', (tester) async {
      // Given - movies are displayed
      robot.assertMoviesLoaded();
      
      // When - user taps on a movie
      await robot.tapMovieCard('1');
      
      // Then - should navigate to movie details
      robot.assertNavigatorRoute('/movies/1');
    });
    
    testWidgets('should show error when loading fails', (tester) async {
      // Given - error state in scenario
      scenario.mockMoviesBloc.emit(const MoviesError('Network error'));
      await robot.awaitForAnimations();
      
      // Then - error should be displayed
      robot.assertErrorShown('Network error');
    });
    
    testWidgets('golden test - movies list', (tester) async {
      // Given - movies loaded state
      robot.assertMoviesLoaded();
      
      // Then - should match golden file
      await robot.takeSnapshot('movies_list_loaded');
    });
  });
}
```

## 🔧 Dependency Injection

The project uses GetIt for service location with a structured injection system:

```dart
// app/lib/core/dependency_injection.dart
Future<void> setupDependencyInjection() async {
  final getIt = GetIt.instance;
  
  // External dependencies
  await _registerAdapters(getIt);
  
  // Feature dependencies
  await _registerFeatures(getIt);
  
  // App-level dependencies
  await _registerAppDependencies(getIt);
}

Future<void> _registerAdapters(GetIt getIt) async {
  // HTTP Client
  getIt.registerLazySingleton<HttpClient>(
    () => HttpClientImpl(
      baseUrl: Environment.apiBaseUrl,
      interceptors: [
        AuthInterceptor(),
        LoggerInterceptor(),
      ],
    ),
  );
  
  // Connectivity
  getIt.registerLazySingleton<ConnectivityClient>(
    () => ConnectivityClientImpl(),
  );
  
  // Media Picker
  getIt.registerLazySingleton<MediaPickerClient>(
    () => MediaPickerClientImpl(),
  );
}
```

## 🧪 Testing Strategy

The project implements a comprehensive testing pyramid:

### Unit Tests
- **Domain layer**: Pure business logic testing
- **Use cases**: Input/output validation
- **Repositories**: Mock data source testing

### Widget Tests (Robot Pattern)
- **Page testing**: Complete user flow testing
- **Component testing**: Individual widget testing
- **Golden tests**: Visual regression testing

### Integration Tests
- **End-to-end flows**: Complete user journeys
- **API integration**: Real API interaction testing

## 🚀 Deployment & CI/CD

The project supports multiple environments and automated deployment:

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.4'
      
      - name: Install Melos
        run: dart pub global activate melos
      
      - name: Bootstrap
        run: melos bootstrap
      
      - name: Run tests
        run: melos test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## 📈 Performance Considerations

- **Lazy loading**: Features loaded on demand
- **Image caching**: Efficient image loading and caching
- **State persistence**: Preserve state across app lifecycle
- **Memory management**: Proper disposal of resources
- **Bundle optimization**: Code splitting per feature

## 🔒 Security

- **Network security**: Certificate pinning, secure headers
- **Data encryption**: Sensitive data encryption at rest
- **Authentication**: JWT token management
- **Permission handling**: Runtime permission requests

## 🤝 Contributing

1. **Follow architectural patterns**: Maintain Clean Architecture principles
2. **Write tests**: Use Robot pattern for UI tests, unit tests for business logic  
3. **Document changes**: Update README for architectural changes
4. **Code review**: All changes require peer review
5. **Performance**: Profile changes for performance impact

## 📚 Additional Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [Melos Documentation](https://melos.invertase.dev/)
- [Flutter Testing Documentation](https://flutter.dev/docs/testing)

## 🏗️ Enhanced Module Structure & Dependencies

Based on InfinitePay's production architecture patterns, here's how enterprise-grade feature modules are structured with real dependency patterns:

### **Complete Package Ecosystem**
```
packages/
├── core/                            # Core application framework
│   ├── lib/
│   │   ├── navigator/              # Navigation management system
│   │   ├── permissions/            # Runtime permissions
│   │   ├── connectivity/           # Network state management
│   │   ├── analytics/              # Event tracking
│   │   └── diagnostics/           # Error reporting & logging
│   └── pubspec.yaml
│
├── global_entities/                 # Shared domain objects
│   ├── lib/
│   │   ├── error/                  # Common error types
│   │   ├── result/                 # Either/Result pattern implementations
│   │   ├── validators/             # Input validation
│   │   └── value_objects/         # Domain value objects
│   └── pubspec.yaml
│
├── infinite_app/                    # App framework & routing
│   ├── lib/
│   │   ├── routes/                # Route definitions & guards
│   │   ├── contracts/             # Cross-module contracts
│   │   ├── delegates/             # Module delegates
│   │   └── microapp_manager/      # Module lifecycle management
│   └── pubspec.yaml
│
├── shared/                         # Shared utilities & services
│   ├── networking/                # HTTP client abstractions
│   ├── infinite_connectivity/     # Connectivity monitoring
│   ├── shared_domain/            # Common domain patterns
│   ├── shared_presentation/      # Reusable UI components
│   ├── shared_identity_validation/ # Identity/auth validation
│   ├── internacional_phone_number/ # Phone number utilities
│   └── routing/                  # Deep linking & navigation
│
├── adapters/                      # External service abstractions
│   ├── infinite_http/            # HTTP client with Dio
│   ├── infinite_storage/         # Local storage abstraction
│   ├── bug_tracker/              # Error tracking (Sentry)
│   ├── analytics/                # Analytics abstraction
│   ├── monitoring/               # Performance monitoring
│   ├── sensors/                  # Device sensors
│   ├── barcode_scanner/          # QR/barcode scanning
│   ├── media_picker/             # Image/video picker
│   ├── notification/             # Push notifications
│   ├── remote_config/            # Feature flags & config
│   ├── ab_testing/               # A/B testing framework
│   ├── tracer/                   # Distributed tracing
│   ├── phone_support/            # Support integrations
│   └── user_review/              # App store reviews
│
├── apis/                          # API client packages
│   ├── movies_api/               # Movies API client
│   ├── user_api/                 # User management API
│   └── payment_api/              # Payment processing API
│
└── features/                      # Feature-specific modules
    ├── movies/                    # Movie management feature
    ├── user_profile/             # User profile management
    ├── authentication/           # Auth & session management
    ├── favorites/                # User favorites
    ├── notifications/            # In-app notifications
    ├── settings/                 # App settings
    └── camera_capture/           # Camera functionality
```

### **Real-World Feature Module Structure**

Based on InfinitePay's PIX feature module (which has 130+ dependencies), here's a production-grade module structure:

```dart
// packages/features/movies/pubspec.yaml
name: movies
resolution: workspace
description: Movies feature module with comprehensive functionality
version: 0.0.1
publish_to: none

environment:
  sdk: ">=3.6.0 <4.0.0"
  flutter: ">=3.27.4"

dependencies:
  flutter:
    sdk: flutter
    
  # Feature flags for gradual rollout
  cloudwalk_feature_flag:
    hosted: https://capypub.services.production.cloudwalk.network
    version: 0.1.103
    
  # State management
  flutter_bloc: 8.1.6
  bloc: 8.1.4
  
  # Functional programming & error handling
  dartz: 0.10.1
  equatable: 2.0.7
  meta: 1.15.0
  
  # Dependency injection
  service_locator:
    hosted: https://capypub.services.production.cloudwalk.network
    version: 0.1.88
  provider: 6.1.2
  
  # Core dependencies (internal packages)
  core:
    path: ../../core
  global_entities:
    path: ../../global_entities
  infinite_app:
    path: ../../infinite_app
    
  # Shared utilities
  infinite_connectivity:
    path: ../../shared/infinite_connectivity
  networking:
    path: ../../shared/networking
  shared_domain:
    path: ../../shared/shared_domain
  shared_presentation:
    path: ../../shared/shared_presentation
  routing:
    path: ../../shared/routing
  infinite_utils:
    path: ../../infinite_utils
    
  # Adapter dependencies
  infinite_http:
    path: ../../adapters/infinite_http
  infinite_storage:
    path: ../../adapters/infinite_storage
  bug_tracker:
    path: ../../adapters/bug_tracker
  analytics:
    path: ../../adapters/analytics
  monitoring:
    path: ../../adapters/monitoring
  ab_testing:
    path: ../../adapters/ab_testing
  sensors:
    path: ../../adapters/sensors
  remote_config:
    path: ../../adapters/remote_config
  media_picker:
    path: ../../adapters/media_picker
    
  # API clients
  movies_api:
    path: ../../apis/movies_api
  user_api:
    path: ../../apis/user_api
    
  # External packages (managed versions)
  intl: 0.19.0
  mask_text_input_formatter: 2.5.0
  flutter_pdfview: 1.4.0+1
  path_provider: 2.1.3
  modal_bottom_sheet: 3.0.0
  flutter_animate: 4.5.0
  styled_text: 4.0.0+1
  pull_to_refresh: 2.0.0
  geolocator: 11.0.0
  diacritic: 0.1.4
  
  # Private registry packages
  infinite_logger:
    version: 1.0.1
    hosted: https://capypub.services.production.cloudwalk.network
  utils:
    hosted: https://capypub.services.production.cloudwalk.network
    version: 0.0.4+8
  tools:
    hosted: https://capypub.services.production.cloudwalk.network
    version: 1.70.0
  centauri_icons:
    hosted: https://capypub.services.production.cloudwalk.network
    version: ^0.1.78
    
  # Git-based dependencies with version pinning
  keyboard_actions:
    git:
      url: git@github.com:diegoveloper/flutter_keyboard_actions.git
      ref: 3.4.7
  pix_flutter:
    git:
      url: git@github.com:cloudwalk/infinitepay-pix-flutter.git
      ref: v0.3.1
  validators:
    git:
      url: git@github.com:cloudwalk/cloudwalk-mobile-foundation.git
      ref: "v0.9.0"
      path: validators
      
  # Cross-feature dependencies (through contracts)
  user_profile_domain:
    path: ../user_profile/user_profile_domain
  authentication_domain:
    path: ../authentication/authentication_domain
  payment_domain:
    path: ../payment/payment_domain

dev_dependencies:
  dev_util:
    path: ../../dev_util
  build_runner: ">=2.3.0 <4.0.0"
  flutter_test:
    sdk: flutter
  mocktail: 1.0.4
  bloc_test: 9.1.7
  intl_utils: 2.8.8
  test: 1.25.8

flutter:
  assets:
    - assets/images/
    - packages/shared_presentation/assets/images/
    
flutter_intl:
  enabled: true
```

### **Enterprise Feature Module Architecture**
```
packages/features/movies/
├── lib/
│   ├── domain/                     # Business logic layer
│   │   ├── entities/
│   │   │   ├── movie.dart
│   │   │   ├── movie_rating.dart
│   │   │   ├── movie_favorite.dart
│   │   │   ├── movie_recommendation.dart
│   │   │   └── watchlist_item.dart
│   │   ├── repositories/           # Repository contracts
│   │   │   ├── movies_repository.dart
│   │   │   ├── rating_repository.dart
│   │   │   ├── favorites_repository.dart
│   │   │   └── recommendation_repository.dart
│   │   ├── usecases/              # Business operations
│   │   │   ├── get_popular_movies.dart
│   │   │   ├── get_movie_details.dart
│   │   │   ├── search_movies.dart
│   │   │   ├── rate_movie.dart
│   │   │   ├── add_to_favorites.dart
│   │   │   ├── get_recommendations.dart
│   │   │   └── manage_watchlist.dart
│   │   ├── errors/                # Domain-specific errors
│   │   │   ├── movies_exceptions.dart
│   │   │   ├── rating_errors.dart
│   │   │   └── favorites_errors.dart
│   │   └── contracts/             # External service contracts
│   │       ├── user_profile_contract.dart
│   │       ├── analytics_contract.dart
│   │       └── notification_contract.dart
│   │
│   ├── data/                      # Data access layer
│   │   ├── models/               # Data models (DTOs)
│   │   │   ├── movie_dto.dart
│   │   │   ├── rating_dto.dart
│   │   │   ├── favorites_dto.dart
│   │   │   └── recommendation_dto.dart
│   │   ├── repositories/         # Repository implementations
│   │   │   ├── movies_repository_impl.dart
│   │   │   ├── rating_repository_impl.dart
│   │   │   └── favorites_repository_impl.dart
│   │   ├── datasources/          # Data source implementations
│   │   │   ├── remote/
│   │   │   │   ├── movies_remote_datasource.dart
│   │   │   │   ├── rating_remote_datasource.dart
│   │   │   │   └── tmdb_api_client.dart
│   │   │   └── local/
│   │   │       ├── movies_local_datasource.dart
│   │   │       ├── favorites_local_datasource.dart
│   │   │       └── movies_database.dart
│   │   └── mappers/              # DTO to Entity mappers
│   │       ├── movie_mapper.dart
│   │       ├── rating_mapper.dart
│   │       └── favorites_mapper.dart
│   │
│   ├── infrastructure/            # Infrastructure implementations
│   │   ├── analytics/
│   │   │   └── movies_analytics_impl.dart
│   │   ├── cache/
│   │   │   ├── movies_cache_manager.dart
│   │   │   └── image_cache_manager.dart
│   │   ├── notifications/
│   │   │   └── movies_notification_service.dart
│   │   └── storage/
│   │       ├── movies_storage_service.dart
│   │       └── offline_sync_service.dart
│   │
│   ├── presentation/              # UI layer
│   │   ├── bloc/                 # State management
│   │   │   ├── movies_list/
│   │   │   │   ├── movies_list_bloc.dart
│   │   │   │   ├── movies_list_event.dart
│   │   │   │   └── movies_list_state.dart
│   │   │   ├── movie_details/
│   │   │   │   ├── movie_details_cubit.dart
│   │   │   │   └── movie_details_state.dart
│   │   │   ├── search/
│   │   │   │   ├── movie_search_bloc.dart
│   │   │   │   ├── movie_search_event.dart
│   │   │   │   └── movie_search_state.dart
│   │   │   └── favorites/
│   │   │       ├── favorites_cubit.dart
│   │   │       └── favorites_state.dart
│   │   ├── pages/                # Full-screen pages
│   │   │   ├── movies_list_page.dart
│   │   │   ├── movie_details_page.dart
│   │   │   ├── movie_search_page.dart
│   │   │   ├── favorites_page.dart
│   │   │   └── watchlist_page.dart
│   │   ├── components/           # Reusable UI components
│   │   │   ├── movie_card.dart
│   │   │   ├── rating_widget.dart
│   │   │   ├── genre_chips.dart
│   │   │   ├── movie_poster.dart
│   │   │   ├── loading_shimmer.dart
│   │   │   └── error_view.dart
│   │   ├── widgets/              # Feature-specific widgets
│   │   │   ├── movie_list_view.dart
│   │   │   ├── search_results_view.dart
│   │   │   ├── movie_rating_dialog.dart
│   │   │   └── recommendation_carousel.dart
│   │   └── utils/                # UI utilities
│   │       ├── movie_extensions.dart
│   │       ├── image_helpers.dart
│   │       └── navigation_helpers.dart
│   │
│   └── l10n/                     # Internationalization
│       ├── intl_en.arb
│       ├── intl_pt_BR.arb
│       └── generated/
│           └── movies_localizations.dart
│
├── assets/                       # Feature-specific assets
│   └── images/
│       ├── movie_placeholder.png
│       ├── rating_stars.png
│       └── favorites_icon.png
│
├── test/                         # Comprehensive test suite
│   ├── domain/
│   │   ├── entities/
│   │   ├── usecases/
│   │   └── repositories/
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── datasources/
│   ├── infrastructure/
│   ├── presentation/
│   │   ├── bloc/
│   │   ├── pages/
│   │   └── components/
│   ├── robot/                    # Robot pattern tests
│   │   ├── movies_page_robot.dart
│   │   ├── search_robot.dart
│   │   └── favorites_robot.dart
│   └── golden_files/             # Golden test files
│       ├── movies_list_loaded.png
│       ├── movie_details.png
│       └── search_results.png
│
└── pubspec.yaml                  # Package dependencies
```

### **Cross-Module Communication Patterns**

Real production systems use sophisticated contract patterns for module communication:

```dart
// packages/features/movies/lib/domain/contracts/user_profile_contract.dart
abstract class UserProfileContract {
  Future<Either<UserProfileError, UserProfile>> getCurrentUser();
  Future<Either<UserProfileError, void>> updateWatchPreferences(
    WatchPreferences preferences,
  );
  Stream<UserProfile> get userStream;
}

// packages/features/movies/lib/domain/contracts/analytics_contract.dart
abstract class MoviesAnalyticsContract {
  void trackMovieViewed(String movieId);
  void trackMovieRated(String movieId, double rating);
  void trackSearchPerformed(String query, int resultsCount);
  void trackFavoriteAdded(String movieId);
  void trackGenrePreference(List<String> genres);
}

// packages/features/movies/lib/domain/contracts/notification_contract.dart
abstract class MoviesNotificationContract {
  Future<Either<NotificationError, void>> sendNewMovieAlert(
    Movie movie, 
    UserProfile user,
  );
  Future<Either<NotificationError, void>> sendRecommendationNotification(
    List<Movie> recommendations,
    UserProfile user,
  );
}
```

## 🏗️ InfiniteModule Architecture & Navigation System

Based on InfinitePay's production module system, here's the sophisticated module architecture that provides nested navigation and stack management:

### **Base Module Architecture**

The InfiniteModule system provides a hierarchical navigation structure with automatic dependency injection and lifecycle management:

```dart
// packages/infinite_app/lib/src/infinite_module.dart - Base Module System
abstract class BaseModule extends StatefulWidget {
  List<InfiniteChildRoute> get routes;
  List<InjectionContainer> get dependencies;
  
  const BaseModule({Key? key}) : super(key: key);
  
  @mustCallSuper
  FutureOr<void> start() async {
    // Initialize all dependency containers
    for (final dependency in dependencies) {
      await dependency.call();
    }
    
    // Start nested modules recursively
    for (final route in routes) {
      if (route is InfiniteModuleRoute) {
        await route.module.start();
      }
    }
  }
  
  void dispose() {
    log('Disposing $this', name: 'InfinitePay - module');
  }
  
  void init() {
    log('Initializing $this', name: 'InfinitePay - module');
  }
  
  Widget build(BuildContext context);
}

// Self-contained module with its own navigation stack
abstract class InfiniteModule extends BaseModule {
  InfiniteModule({
    Key? key,
    GlobalKey<NavigatorState>? navigatorKey,
    this.observers = const <NavigatorObserver>[],
    this.initialRoute,
    this.stackRoutes = false,
  })  : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        _argsHolder = ArgsHolder(targetRoute: initialRoute),
        super(key: key);
        
  final GlobalKey<NavigatorState> navigatorKey;
  final List<NavigatorObserver> observers;
  final ArgsHolder _argsHolder;
  final bool stackRoutes;
  final String? initialRoute;
  
  // Dynamic route targeting for module navigation
  void setTargetRoute(String route) {
    _argsHolder.targetRoute = route;
  }
  
  void setInitialArgs(Object? args) {
    _argsHolder.args = args;
  }
  
  String get id => '$this';
  final _infiniteStackKey = GlobalKey<InfiniteStackState>();
  
  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    return ParentNavigator(
      child: InfiniteStack(
        key: _infiniteStackKey,
        child: ModuleNavigator(
          initialRoute: initialRoute,
          targetRoute: _argsHolder.targetRoute,
          module: this,
          args: _argsHolder.args,
          observers: observers,
          navigatorKey: navigatorKey,
          stackRoutes: stackRoutes,
          infiniteStackKey: _infiniteStackKey,
        ),
      ),
    );
  }
}
```

### **Hierarchical Navigation System**

The system provides sophisticated parent-child navigation with automatic stack management:

```dart
// packages/infinite_app/lib/src/parent_navigator.dart
class ParentNavigator extends StatelessWidget {
  final Widget child;
  
  const ParentNavigator({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: Navigator.of(context), // Exposes parent navigator
      child: Container(
        color: Colors.white,
        child: child,
      ),
    );
  }
  
  // Access parent navigator from anywhere in module hierarchy
  static NavigatorState of(BuildContext context) => context.parentNavigator;
}

// Extension for easy access to parent navigation
extension ParentNavigatorExtension on BuildContext {
  /// Navigate to parent module: context.parentNavigator.pop();
  NavigatorState get parentNavigator => read<NavigatorState>();
}
```

### **Intelligent Stack Management**

The InfiniteStack system automatically manages nested navigation stacks with parent-child relationships:

```dart
// packages/infinite_app/lib/src/infinite_stack_widget.dart
class InfiniteStack extends StatefulWidget {
  final Widget child;
  
  InfiniteStack({Key? key, required this.child}) : super(key: key);
  
  @override
  State<InfiniteStack> createState() => InfiniteStackState();
}

class InfiniteStackState extends State<InfiniteStack> {
  late InfiniteStackCounter stackCounter;
  InfiniteStackCounter? parentStackCounter;
  
  @override
  void initState() {
    super.initState();
    stackCounter = InfiniteStackCounter();
  }
  
  @override
  void dispose() {
    // Clean up child routes when module is disposed
    parentStackCounter?.clearChildrenRoutes();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Connect to parent stack for hierarchical management
    parentStackCounter = InfiniteStackProvider.of(context)?.stackCounter;
    return InfiniteStackProvider(
      stackCounter: stackCounter,
      child: widget.child,
    );
  }
  
  // Synchronize route management between parent and child stacks
  void addRoute(String route) {
    stackCounter.addRoute(route);
    parentStackCounter?.addChildRoute(route);
  }
  
  void removeRoute(String route) {
    stackCounter.removeRoute(route);
    parentStackCounter?.removeChildRoute(route);
  }
  
  void replaceRoute(String oldRoute, String newRoute) {
    stackCounter.replaceRoute(oldRoute, newRoute);
    parentStackCounter?.replaceChildRoute(oldRoute, newRoute);
  }
}
```

### **Stack Counter & Route Tracking**

Sophisticated route counting prevents navigation stack underflows and black screens:

```dart
// packages/infinite_app/lib/src/infinite_stack_counter.dart
class InfiniteStackCounter extends ChangeNotifier {
  List<String> _routes = ['/'];
  List<String> _childrenRoutes = [];
  
  // Total route count including children for stack protection
  int get count => _routes.length + _childrenRoutes.length;
  
  void addRoute(String route) {
    _routes.add(route);
    _notify();
  }
  
  void removeRoute(String route) {
    if (_routes.remove(route)) {
      _notify();
    }
  }
  
  // Parent-child route synchronization
  void addChildRoute(String route) {
    _childrenRoutes.add(route);
    _notify();
  }
  
  void removeChildRoute(String route) {
    if (_childrenRoutes.remove(route)) {
      _notify();
    }
  }
  
  void clearChildrenRoutes() {
    _childrenRoutes.clear();
    _notify();
  }
  
  // iOS-specific notification optimization
  void _notify() {
    if (defaultTargetPlatform != TargetPlatform.iOS || runningTest) {
      return;
    }
    Future.delayed(Durations.medium2, notifyListeners);
  }
}
```

### **Module Navigator with Smart Route Handling**

The ModuleNavigator provides intelligent route generation and argument passing:

```dart
// packages/infinite_app/lib/src/module_navigator.dart
class ModuleNavigator extends StatelessWidget {
  ModuleNavigator({
    Key? key,
    required this.module,
    required this.navigatorKey,
    required this.observers,
    required this.args,
    this.initialRoute,
    this.stackRoutes = false,
    this.targetRoute,
    required this.infiniteStackKey,
  }) : super(key: key);
  
  final InfiniteModule module;
  final GlobalKey<NavigatorState> navigatorKey;
  final List<NavigatorObserver> observers;
  final Object? args;
  final String? initialRoute;
  final bool stackRoutes;
  final String? targetRoute;
  final GlobalKey<InfiniteStackState> infiniteStackKey;
  
  String get _initialRoute => initialRoute ?? '/';
  String get _targetRoute => targetRoute ?? _initialRoute;
  bool get _initialIsTarget => _initialRoute == _targetRoute;
  
  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: navigatorKey,
      child: Builder(builder: (context) {
        return _AndroidBackButtonDispatcher(
          navigatorKey: navigatorKey,
          child: Navigator(
            key: navigatorKey,
            observers: [
              ...observers,
              ModuleNavigatorObserver(
                parentNavigator: context.parentNavigator,
                moduleId: module.id,
                infiniteStackKey: infiniteStackKey,
              ),
            ],
            onGenerateRoute: (settings) {
              var routeSettings = settings;
              final isInitialRoute = settings.name == _initialRoute;
              final isTargetRoute = settings.name == _targetRoute;
              
              // Skip initial route if not target and not stacking
              if (isInitialRoute && !_initialIsTarget && !stackRoutes) {
                return null;
              }
              
              // Smart argument passing
              final hasNotArgs = settings.arguments == null;
              final hasInitialArgs = args != null;
              final canPassArgs = isInitialRoute || isTargetRoute;
              
              if (canPassArgs && hasNotArgs && hasInitialArgs) {
                routeSettings = RouteSettings(
                  name: settings.name,
                  arguments: args,
                );
              }
              
              return onGenerateRouteByFeature(routeSettings, module, context);
            },
            initialRoute: _targetRoute,
          ),
        );
      }),
    );
  }
  
  static NavigatorState of(BuildContext context) => context.moduleNavigator;
}

// Platform-specific back button handling
class _AndroidBackButtonDispatcher extends StatelessWidget {
  const _AndroidBackButtonDispatcher({
    required this.child,
    required this.navigatorKey,
  });
  
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final stackCounter = InfiniteStackProvider.of(context)?.stackCounter;
      if (stackCounter == null) return child;
      
      return ListenableBuilder(
        listenable: stackCounter,
        builder: (_, child) {
          // Prevent iOS back gesture when only one route
          if (stackCounter.count == 1) {
            return child!;
          }
          return PopScope(canPop: false, child: child!);
        },
        child: child,
      );
    }
    
    // Android back button handling
    return WillPopScope(
      onWillPop: () async {
        final routePopped = await navigatorKey.currentState?.maybePop() ?? false;
        return !routePopped; // Let Flutter handle if no route was popped
      },
      child: child,
    );
  }
}
```

### **Production Module Implementation Example**

Here's how a real feature module implements the InfiniteModule pattern:

```dart
// packages/features/movies/lib/movies_module.dart
class MoviesModule extends InfiniteModule {
  MoviesModule({
    super.key,
    super.navigatorKey,
    super.observers,
    super.initialRoute = '/movies',
    super.stackRoutes = true,
  });
  
  @override
  List<InfiniteChildRoute> get routes => [
    InfiniteChildRoute(
      routeName: '/movies',
      builder: (context, args) => const MoviesListPage(),
      guard: AuthenticationGuard(), // Route protection
    ),
    InfiniteChildRoute(
      routeName: '/movies/details',
      builder: (context, args) => MovieDetailsPage(
        movieId: args as String,
      ),
    ),
    InfiniteChildRoute(
      routeName: '/movies/search',
      builder: (context, args) => const MovieSearchPage(),
    ),
    // Nested module example
    InfiniteModuleRoute(
      routeName: '/movies/favorites',
      module: FavoritesModule(),
    ),
  ];
  
  @override
  List<InjectionContainer> get dependencies => [
    () => MoviesInjectionContainer.init(),
    () => MoviesCacheInjectionContainer.init(),
  ];
  
  @override
  FutureOr<void> start() async {
    await super.start();
    
    // Module-specific initialization
    await _initializeMoviesCache();
    await _registerAnalyticsEvents();
    await _setupPeriodicDataSync();
  }
  
  @override
  void dispose() {
    // Clean up module resources
    MoviesInjectionContainer.dispose();
    super.dispose();
  }
  
  Future<void> _initializeMoviesCache() async {
    final cacheManager = GetIt.instance<MoviesCacheManager>();
    await cacheManager.initialize();
  }
  
  Future<void> _registerAnalyticsEvents() async {
    final analytics = GetIt.instance<Analytics>();
    analytics.registerModuleEvents('movies', [
      'movie_viewed',
      'movie_rated',
      'search_performed',
    ]);
  }
  
  Future<void> _setupPeriodicDataSync() async {
    final syncService = GetIt.instance<OfflineSyncService>();
    syncService.startPeriodicSync(
      interval: const Duration(minutes: 15),
      modules: ['movies'],
    );
  }
}

// App-level module for coordinating all feature modules
class MainAppModule extends AppBaseModule {
  MainAppModule({super.key});
  
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  @override
  List<InfiniteChildRoute> get routes => [
    InfiniteChildRoute(
      routeName: '/',
      builder: (context, args) => const SplashPage(),
    ),
    InfiniteChildRoute(
      routeName: '/home',
      builder: (context, args) => const HomePage(),
      guard: AuthenticationGuard(),
    ),
    // Feature modules
    InfiniteModuleRoute(
      routeName: '/movies',
      module: MoviesModule(),
    ),
    InfiniteModuleRoute(
      routeName: '/profile',
      module: UserProfileModule(),
    ),
    InfiniteModuleRoute(
      routeName: '/auth',
      module: AuthenticationModule(),
    ),
  ];
  
  @override
  List<InjectionContainer> get dependencies => [
    () => CoreInjectionContainer.init(),
    () => AdaptersInjectionContainer.init(),
    () => ContractsInjectionContainer.init(),
  ];
}
```

### **Module Navigation Extensions**

Easy access to module-specific navigation:

```dart
// Extension for accessing module navigator
extension ModuleNavigatorExtension on BuildContext {
  /// Navigate within current module: context.moduleNavigator.pushNamed('/route');
  NavigatorState get moduleNavigator => read<GlobalKey<NavigatorState>>().currentState!;
}

// Usage in widgets
class MovieListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Movie Title'),
      onTap: () {
        // Navigate within movies module
        context.moduleNavigator.pushNamed('/movies/details', arguments: movieId);
        
        // Navigate to parent app level
        context.parentNavigator.pushNamed('/profile');
      },
    );
  }
}
```

### **Arguments Management System**

The ArgsHolder provides dynamic argument passing between routes:

```dart
// Dynamic argument management for modules
class ArgsHolder {
  Object? args;
  String? targetRoute;
  
  ArgsHolder({this.targetRoute});
}

// Usage in navigation
final moviesModule = MoviesModule();
moviesModule.setTargetRoute('/movies/details');
moviesModule.setInitialArgs(MovieDetailsArgs(movieId: '123'));

// Navigate to module with specific route and args
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => moviesModule,
  ),
);
```

This InfiniteModule architecture provides:

1. **Hierarchical Navigation** - Nested modules with parent-child navigation
2. **Automatic Stack Management** - Prevents black screens and navigation errors  
3. **Smart Route Handling** - Dynamic route targeting and argument passing
4. **Platform-Specific Behavior** - iOS and Android back button handling
5. **Lifecycle Management** - Automatic initialization and cleanup
6. **Dependency Injection** - Module-specific dependency containers
7. **Route Protection** - Guards and authentication checks
8. **Performance Optimization** - Lazy loading and efficient stack management

### **Enterprise Dependency Injection Container**

Based on real InfinitePay patterns, here's how complex modules handle dependency injection:

```dart
// packages/features/movies/lib/infrastructure/injection/movies_injection_container.dart
class MoviesInjectionContainer {
  static Future<void> init() async {
    final getIt = GetIt.instance;
    
    // Register feature flags
    final featureFlags = getIt<CloudWalkFeatureFlag>();
    
    // External contracts (provided by main app)
    final userContract = getIt<UserProfileContract>();
    final analyticsContract = getIt<MoviesAnalyticsContract>();
    final notificationContract = getIt<MoviesNotificationContract>();
    
    // Data Sources - Remote
    getIt.registerLazySingleton<MoviesRemoteDataSource>(
      () => MoviesRemoteDataSourceImpl(
        httpClient: getIt<HttpClient>(),
        apiClient: getIt<MoviesApiClient>(),
        logger: getIt<Logger>(),
        featureFlags: featureFlags,
      ),
    );
    
    getIt.registerLazySingleton<RatingRemoteDataSource>(
      () => RatingRemoteDataSourceImpl(
        httpClient: getIt<HttpClient>(),
        userContract: userContract,
        logger: getIt<Logger>(),
      ),
    );
    
    // Data Sources - Local
    getIt.registerLazySingleton<MoviesLocalDataSource>(
      () => MoviesLocalDataSourceImpl(
        storage: getIt<LocalStorage>(),
        database: getIt<MoviesDatabase>(),
        cacheManager: getIt<MoviesCacheManager>(),
      ),
    );
    
    getIt.registerLazySingleton<FavoritesLocalDataSource>(
      () => FavoritesLocalDataSourceImpl(
        storage: getIt<LocalStorage>(),
        userContract: userContract,
      ),
    );
    
    // Repositories
    getIt.registerLazySingleton<MoviesRepository>(
      () => MoviesRepositoryImpl(
        remoteDataSource: getIt<MoviesRemoteDataSource>(),
        localDataSource: getIt<MoviesLocalDataSource>(),
        networkInfo: getIt<NetworkInfo>(),
        cacheManager: getIt<MoviesCacheManager>(),
        analytics: analyticsContract,
        logger: getIt<Logger>(),
      ),
    );
    
    getIt.registerLazySingleton<RatingRepository>(
      () => RatingRepositoryImpl(
        remoteDataSource: getIt<RatingRemoteDataSource>(),
        userContract: userContract,
        analytics: analyticsContract,
      ),
    );
    
    getIt.registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(
        localDataSource: getIt<FavoritesLocalDataSource>(),
        userContract: userContract,
        notificationContract: notificationContract,
        analytics: analyticsContract,
      ),
    );
    
    getIt.registerLazySingleton<RecommendationRepository>(
      () => RecommendationRepositoryImpl(
        remoteDataSource: getIt<MoviesRemoteDataSource>(),
        userContract: userContract,
        analytics: analyticsContract,
        abTesting: getIt<ABTestingClient>(),
      ),
    );
    
    // Use Cases
    getIt.registerLazySingleton(() => GetPopularMovies(getIt()));
    getIt.registerLazySingleton(() => GetMovieDetails(getIt()));
    getIt.registerLazySingleton(() => SearchMovies(getIt()));
    getIt.registerLazySingleton(() => RateMovie(getIt()));
    getIt.registerLazySingleton(() => AddToFavorites(getIt()));
    getIt.registerLazySingleton(() => RemoveFromFavorites(getIt()));
    getIt.registerLazySingleton(() => GetFavorites(getIt()));
    getIt.registerLazySingleton(() => GetRecommendations(getIt()));
    getIt.registerLazySingleton(() => ManageWatchlist(getIt()));
    getIt.registerLazySingleton(() => GetMoviesByGenre(getIt()));
    getIt.registerLazySingleton(() => GetTrendingMovies(getIt()));
    
    // Infrastructure Services
    getIt.registerLazySingleton<MoviesCacheManager>(
      () => MoviesCacheManagerImpl(
        cacheManager: getIt<CacheManager>(),
        storage: getIt<LocalStorage>(),
      ),
    );
    
    getIt.registerLazySingleton<MoviesDatabase>(
      () => MoviesDatabaseImpl(),
    );
    
    getIt.registerLazySingleton<OfflineSyncService>(
      () => OfflineSyncServiceImpl(
        moviesRepository: getIt<MoviesRepository>(),
        connectivity: getIt<ConnectivityClient>(),
        storage: getIt<LocalStorage>(),
      ),
    );
    
    // BLoC/Cubit - Factory registration for stateful widgets
    getIt.registerFactory(
      () => MoviesListBloc(
        getPopularMovies: getIt(),
        getTrendingMovies: getIt(),
        searchMovies: getIt(),
        connectivity: getIt<ConnectivityClient>(),
        analytics: analyticsContract,
        logger: getIt<Logger>(),
      ),
    );
    
    getIt.registerFactory(
      () => MovieDetailsCubit(
        getMovieDetails: getIt(),
        rateMovie: getIt(),
        addToFavorites: getIt(),
        removeFromFavorites: getIt(),
        getRecommendations: getIt(),
        analytics: analyticsContract,
        userContract: userContract,
      ),
    );
    
    getIt.registerFactory(
      () => MovieSearchBloc(
        searchMovies: getIt(),
        getMoviesByGenre: getIt(),
        analytics: analyticsContract,
      ),
    );
    
    getIt.registerFactory(
      () => FavoritesCubit(
        getFavorites: getIt(),
        addToFavorites: getIt(),
        removeFromFavorites: getIt(),
        userContract: userContract,
        analytics: analyticsContract,
      ),
    );
    
    getIt.registerFactory(
      () => WatchlistCubit(
        manageWatchlist: getIt(),
        userContract: userContract,
        notificationContract: notificationContract,
      ),
    );
  }
  
  static void dispose() {
    final getIt = GetIt.instance;
    
    // Dispose of module-specific registrations
    // BLoCs/Cubits
    getIt.unregister<MoviesListBloc>();
    getIt.unregister<MovieDetailsCubit>();
    getIt.unregister<MovieSearchBloc>();
    getIt.unregister<FavoritesCubit>();
    getIt.unregister<WatchlistCubit>();
    
    // Use cases
    getIt.unregister<GetPopularMovies>();
    getIt.unregister<GetMovieDetails>();
    getIt.unregister<SearchMovies>();
    getIt.unregister<RateMovie>();
    getIt.unregister<AddToFavorites>();
    getIt.unregister<RemoveFromFavorites>();
    getIt.unregister<GetFavorites>();
    getIt.unregister<GetRecommendations>();
    getIt.unregister<ManageWatchlist>();
    getIt.unregister<GetMoviesByGenre>();
    getIt.unregister<GetTrendingMovies>();
    
    // Repositories  
    getIt.unregister<MoviesRepository>();
    getIt.unregister<RatingRepository>();
    getIt.unregister<FavoritesRepository>();
    getIt.unregister<RecommendationRepository>();
    
    // Data sources
    getIt.unregister<MoviesRemoteDataSource>();
    getIt.unregister<MoviesLocalDataSource>();
    getIt.unregister<RatingRemoteDataSource>();
    getIt.unregister<FavoritesLocalDataSource>();
    
    // Infrastructure services
    getIt.unregister<MoviesCacheManager>();
    getIt.unregister<MoviesDatabase>();
    getIt.unregister<OfflineSyncService>();
  }
}
│   │   │   │   └── movie_review.dart
│   │   │   ├── repositories/
│   │   │   │   ├── movie_repository.dart
│   │   │   │   ├── rating_repository.dart
│   │   │   │   └── review_repository.dart
│   │   │   ├── usecases/
│   │   │   │   ├── get_popular_movies.dart
│   │   │   │   ├── search_movies.dart
│   │   │   │   ├── rate_movie.dart
│   │   │   │   ├── add_to_favorites.dart
│   │   │   │   └── get_movie_recommendations.dart
│   │   │   └── errors/
│   │   │       ├── movie_exceptions.dart
│   │   │       └── rating_exceptions.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── movie_remote_datasource.dart
│   │   │   │   ├── movie_local_datasource.dart
│   │   │   │   ├── rating_remote_datasource.dart
│   │   │   │   └── cache_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── movie_model.dart
│   │   │   │   ├── movie_response_model.dart
│   │   │   │   └── rating_model.dart
│   │   │   ├── repositories/
│   │   │   │   ├── movie_repository_impl.dart
│   │   │   │   └── rating_repository_impl.dart
│   │   │   └── mappers/
│   │   │       ├── movie_mapper.dart
│   │   │       └── rating_mapper.dart
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   │   ├── movies_list/
│   │   │   │   │   ├── movies_list_bloc.dart
│   │   │   │   │   ├── movies_list_event.dart
│   │   │   │   │   └── movies_list_state.dart
│   │   │   │   ├── movie_details/
│   │   │   │   │   ├── movie_details_cubit.dart
│   │   │   │   │   └── movie_details_state.dart
│   │   │   │   └── search/
│   │   │   │       ├── movie_search_bloc.dart
│   │   │   │       ├── movie_search_event.dart
│   │   │   │       └── movie_search_state.dart
│   │   │   ├── pages/
│   │   │   │   ├── movies_list_page.dart
│   │   │   │   ├── movie_details_page.dart
│   │   │   │   └── movie_search_page.dart
│   │   │   └── widgets/
│   │   │       ├── movie_card.dart
│   │   │       ├── movie_rating_widget.dart
│   │   │       ├── movie_poster.dart
│   │   │       └── favorite_button.dart
│   │   ├── injection_container.dart  # Module-specific DI
│   │   ├── movie_routes.dart        # Module routes
│   │   └── movies.dart              # Public API
│   ├── test/
│   │   ├── domain/
│   │   ├── data/
│   │   ├── presentation/
│   │   └── robot/
│   │       ├── movies_list_robot.dart
│   │       ├── movie_details_robot.dart
│   │       └── scenarios/
│   ├── l10n/                        # Module localization
│   │   ├── intl_en.arb
│   │   └── intl_pt_BR.arb
│   └── assets/                      # Module-specific assets
│       └── images/
├── favorites/                       # Favorites management
│   ├── lib/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── favorite_item.dart
│   │   │   ├── repositories/
│   │   │   │   └── favorites_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_to_favorites.dart
│   │   │       ├── remove_from_favorites.dart
│   │   │       └── get_favorites_list.dart
│   │   ├── data/
│   │   ├── presentation/
│   │   └── injection_container.dart
│   └── test/
├── user_profile/                    # User management
│   ├── lib/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── user.dart
│   │   │   │   └── user_preferences.dart
│   │   │   ├── repositories/
│   │   │   │   └── user_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_user_profile.dart
│   │   │       ├── update_user_profile.dart
│   │   │       └── manage_preferences.dart
│   │   └── contracts/               # Cross-module contracts
│   │       └── user_profile_contract.dart
│   └── test/
├── authentication/                  # Auth module
│   ├── lib/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── auth_token.dart
│   │   │   │   └── user_credentials.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_user.dart
│   │   │       ├── logout_user.dart
│   │   │       ├── refresh_token.dart
│   │   │       └── validate_session.dart
│   │   └── contracts/
│   │       └── auth_contract.dart
│   └── test/
└── shared_features/                 # Cross-cutting features
    ├── analytics/
    ├── caching/
    ├── storage/
    └── networking/
```

### **Module Dependency Contracts**
```dart
// packages/features/movies/lib/contracts/movies_contract.dart
abstract class MoviesContract {
  Future<Either<MovieFailure, List<Movie>>> getPopularMovies();
  Future<Either<MovieFailure, Movie>> getMovieDetails(String id);
  Future<Either<MovieFailure, bool>> addToFavorites(String movieId);
}

// Contract implementation in main app
class MoviesContractImpl implements MoviesContract {
  final GetPopularMovies _getPopularMovies;
  final GetMovieDetails _getMovieDetails;
  final AddToFavorites _addToFavorites;

  MoviesContractImpl({
    required GetPopularMovies getPopularMovies,
    required GetMovieDetails getMovieDetails,
    required AddToFavorites addToFavorites,
  }) : _getPopularMovies = getPopularMovies,
       _getMovieDetails = getMovieDetails,
       _addToFavorites = addToFavorites;

  @override
  Future<Either<MovieFailure, List<Movie>>> getPopularMovies() {
    return _getPopularMovies();
  }

  @override
  Future<Either<MovieFailure, Movie>> getMovieDetails(String id) {
    return _getMovieDetails(GetMovieDetailsParams(id: id));
  }

  @override
  Future<Either<MovieFailure, bool>> addToFavorites(String movieId) {
    return _addToFavorites(AddToFavoritesParams(movieId: movieId));
  }
}
```

## 🔧 Advanced Dependency Injection & Module System

### **Module-Specific Injection Containers**

Each feature module has its own injection container following InfinitePay's pattern:

```dart
// packages/features/movies/lib/injection_container.dart
class MoviesInjectionContainer {
  static Future<void> init() async {
    final getIt = GetIt.instance;

    // External dependencies (provided by main app)
    // These are registered by the main app and consumed by the module
    
    // Data Sources
    getIt.registerLazySingleton<MovieRemoteDataSource>(
      () => MovieRemoteDataSourceImpl(
        httpClient: getIt<HttpClient>(),
      ),
    );

    getIt.registerLazySingleton<MovieLocalDataSource>(
      () => MovieLocalDataSourceImpl(
        localStorage: getIt<LocalStorage>(),
      ),
    );

    // Repositories
    getIt.registerLazySingleton<MovieRepository>(
      () => MovieRepositoryImpl(
        remoteDataSource: getIt<MovieRemoteDataSource>(),
        localDataSource: getIt<MovieLocalDataSource>(),
        networkInfo: getIt<NetworkInfo>(),
      ),
    );

    getIt.registerLazySingleton<RatingRepository>(
      () => RatingRepositoryImpl(
        remoteDataSource: getIt<RatingRemoteDataSource>(),
        localDataSource: getIt<RatingLocalDataSource>(),
      ),
    );

    // Use Cases
    getIt.registerLazySingleton(() => GetPopularMovies(getIt()));
    getIt.registerLazySingleton(() => GetMovieDetails(getIt()));
    getIt.registerLazySingleton(() => SearchMovies(getIt()));
    getIt.registerLazySingleton(() => RateMovie(getIt()));
    getIt.registerLazySingleton(() => AddToFavorites(getIt()));

    // BLoC/Cubit - Factory registration for stateful widgets
    getIt.registerFactory(
      () => MoviesListBloc(
        getPopularMovies: getIt(),
        searchMovies: getIt(),
      ),
    );

    getIt.registerFactory(
      () => MovieDetailsCubit(
        getMovieDetails: getIt(),
        rateMovie: getIt(),
        addToFavorites: getIt(),
      ),
    );

    getIt.registerFactory(
      () => MovieSearchBloc(
        searchMovies: getIt(),
      ),
    );
  }

  static void dispose() {
    final getIt = GetIt.instance;
    
    // Dispose of module-specific registrations
    getIt.unregister<MoviesListBloc>();
    getIt.unregister<MovieDetailsCubit>();
    getIt.unregister<MovieSearchBloc>();
    
    // Use cases
    getIt.unregister<GetPopularMovies>();
    getIt.unregister<GetMovieDetails>();
    getIt.unregister<SearchMovies>();
    getIt.unregister<RateMovie>();
    getIt.unregister<AddToFavorites>();
    
    // Repositories  
    getIt.unregister<MovieRepository>();
    getIt.unregister<RatingRepository>();
    
    // Data sources
    getIt.unregister<MovieRemoteDataSource>();
    getIt.unregister<MovieLocalDataSource>();
  }
}
```

### **Main App Dependency Injection System**
```dart
// app/lib/core/dependency_injection.dart
class DependencyInjection {
  static final GetIt _getIt = GetIt.instance;
  
  static Future<void> init() async {
    await _registerCore();
    await _registerAdapters();
    await _registerModules();
    await _registerContracts();
  }

  static Future<void> _registerCore() async {
    // Core services that all modules depend on
    _getIt.registerLazySingleton<Logger>(
      () => Logger('CineApp'),
    );

    _getIt.registerLazySingleton<NavigationManager>(
      () => NavigationManager.instance,
    );

    _getIt.registerLazySingleton<Analytics>(
      () => AnalyticsImpl(),
    );

    _getIt.registerLazySingleton<CacheManager>(
      () => CacheManagerImpl(),
    );

    _getIt.registerLazySingleton<LocalStorage>(
      () => LocalStorageImpl(),
    );

    _getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(
        connectivity: _getIt<ConnectivityClient>(),
      ),
    );
  }

  static Future<void> _registerAdapters() async {
    // HTTP Client with interceptors
    _getIt.registerLazySingleton<HttpClient>(
      () => HttpClientImpl(
        baseUrl: Environment.apiBaseUrl,
        interceptors: [
          AuthInterceptor(
            tokenRepository: _getIt<TokenRepository>(),
            authRepository: _getIt<AuthenticationRepository>(),
          ),
          LoggerInterceptor(),
          RetryInterceptor(),
          CacheInterceptor(cacheManager: _getIt<CacheManager>()),
        ],
      ),
    );

    // Connectivity
    _getIt.registerLazySingleton<ConnectivityClient>(
      () => ConnectivityClientImpl(),
    );

    // Media Picker
    _getIt.registerLazySingleton<MediaPickerClient>(
      () => MediaPickerClientImpl(),
    );
  }

  static Future<void> _registerModules() async {
    // Initialize each module's injection container
    await MoviesInjectionContainer.init();
    await FavoritesInjectionContainer.init();
    await UserProfileInjectionContainer.init();
    await AuthenticationInjectionContainer.init();
  }

  static Future<void> _registerContracts() async {
    // Register contract implementations for cross-module communication
    _getIt.registerLazySingleton<MoviesContract>(
      () => MoviesContractImpl(
        getPopularMovies: _getIt<GetPopularMovies>(),
        getMovieDetails: _getIt<GetMovieDetails>(),
        addToFavorites: _getIt<AddToFavorites>(),
      ),
    );

    _getIt.registerLazySingleton<UserProfileContract>(
      () => UserProfileContractImpl(
        getUserProfile: _getIt<GetUserProfile>(),
        updateUserProfile: _getIt<UpdateUserProfile>(),
      ),
    );

    _getIt.registerLazySingleton<AuthContract>(
      () => AuthContractImpl(
        loginUser: _getIt<LoginUser>(),
        logoutUser: _getIt<LogoutUser>(),
        refreshToken: _getIt<RefreshToken>(),
      ),
    );
  }

  static Future<void> dispose() async {
    // Dispose modules in reverse order
    AuthenticationInjectionContainer.dispose();
    UserProfileInjectionContainer.dispose();
    FavoritesInjectionContainer.dispose();
    MoviesInjectionContainer.dispose();
    
    // Reset GetIt instance
    await _getIt.reset();
  }
}
```

## 🧠 Comprehensive BLoC Architecture Patterns

### **How to Properly Create BLoCs and Cubits**

Following InfinitePay's production patterns, here's the step-by-step guide to create properly structured BLoCs and Cubits:

#### **Step 1: Choose Between BLoC vs Cubit**

**Use BLoC when:**
- Complex state transitions with multiple event types
- Need explicit event tracking for debugging/analytics
- Multiple input sources trigger the same state changes
- Reactive programming patterns are beneficial

**Use Cubit when:**
- Simple state management with direct method calls
- Straightforward CRUD operations
- UI-driven state changes
- Quick prototyping or simple features

#### **Step 2: Define Domain Entities & Use Cases First**

Always start with the domain layer before creating BLoCs:

```dart
// 1. Domain Entity
// packages/features/movies/lib/domain/entities/movie.dart
class Movie extends Equatable {
  final String id;
  final String title;
  final String overview;
  final String releaseDate;
  final double rating;
  final String? posterUrl;
  final bool isFavorited;
  final double? userRating;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.releaseDate,
    required this.rating,
    this.posterUrl,
    this.isFavorited = false,
    this.userRating,
  });

  Movie copyWith({
    String? id,
    String? title,
    String? overview,
    String? releaseDate,
    double? rating,
    String? posterUrl,
    bool? isFavorited,
    double? userRating,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      releaseDate: releaseDate ?? this.releaseDate,
      rating: rating ?? this.rating,
      posterUrl: posterUrl ?? this.posterUrl,
      isFavorited: isFavorited ?? this.isFavorited,
      userRating: userRating ?? this.userRating,
    );
  }

  @override
  List<Object?> get props => [
    id, title, overview, releaseDate, rating, 
    posterUrl, isFavorited, userRating,
  ];
}

// 2. Use Case with Proper Error Handling
// packages/features/movies/lib/domain/usecases/get_popular_movies.dart
class GetPopularMovies extends UseCase<List<Movie>, GetPopularMoviesParams> {
  final MoviesRepository repository;
  
  GetPopularMovies(this.repository);
  
  @override
  Future<Either<Failure, List<Movie>>> call(GetPopularMoviesParams params) {
    return repository.getPopularMovies(
      page: params.page,
      language: params.language,
    );
  }
}

class GetPopularMoviesParams extends Equatable {
  final int page;
  final String language;
  
  const GetPopularMoviesParams({
    this.page = 1,
    this.language = 'en-US',
  });
  
  @override
  List<Object> get props => [page, language];
}
```

#### **Step 3: Create Base Classes for Consistency**

```dart
// packages/core/lib/presentation/base_bloc.dart
abstract class BaseState extends Equatable {
  const BaseState();
}

abstract class BaseEvent extends Equatable {
  const BaseEvent();
}

// Loading states mixin for consistent loading behavior
mixin LoadingStateMixin {
  bool get isLoading => false;
  bool get isInitialLoading => false;
  bool get isLoadingMore => false;
  bool get isRefreshing => false;
}

// Error states mixin for consistent error handling
mixin ErrorStateMixin {
  String? get errorMessage => null;
  bool get hasError => errorMessage != null;
  Failure? get failure => null;
}

// Success states mixin
mixin SuccessStateMixin {
  bool get isSuccess => false;
  String? get successMessage => null;
}

// Base BLoC with common functionality
abstract class BaseBloc<Event extends BaseEvent, State extends BaseState> 
    extends Bloc<Event, State> {
  
  final Logger logger;
  final Analytics? analytics;
  
  BaseBloc({
    required State initialState,
    required this.logger,
    this.analytics,
  }) : super(initialState);
  
  @override
  void onTransition(Transition<Event, State> transition) {
    super.onTransition(transition);
    logger.info(
      'BLoC Transition: ${transition.event.runtimeType} -> ${transition.nextState.runtimeType}'
    );
    
    // Track analytics for important events
    analytics?.track('bloc_transition', {
      'bloc': runtimeType.toString(),
      'event': transition.event.runtimeType.toString(),
      'state': transition.nextState.runtimeType.toString(),
    });
  }
  
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    logger.error('BLoC Error', error, stackTrace);
    analytics?.trackError(error, stackTrace, {
      'bloc': runtimeType.toString(),
    });
    super.onError(bloc, error, stackTrace);
  }
  
  // Helper method for handling Either results
  void handleEitherResult<T>(
    Either<Failure, T> result,
    void Function(T) onSuccess,
    void Function(Failure) onFailure,
  ) {
    result.fold(onFailure, onSuccess);
  }
}

// Base Cubit with common functionality  
abstract class BaseCubit<State extends BaseState> extends Cubit<State> {
  final Logger logger;
  final Analytics? analytics;
  
  BaseCubit({
    required State initialState,
    required this.logger,
    this.analytics,
  }) : super(initialState);
  
  @override
  void onChange(Change<State> change) {
    super.onChange(change);
    logger.info(
      'Cubit Change: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}'
    );
  }
  
  @override
  void onError(Object error, StackTrace stackTrace) {
    logger.error('Cubit Error', error, stackTrace);
    analytics?.trackError(error, stackTrace, {
      'cubit': runtimeType.toString(),
    });
    super.onError(error, stackTrace);
  }
  
  // Safe emit that handles closed state
  void safeEmit(State state) {
    if (!isClosed) {
      emit(state);
    }
  }
  
  // Helper method for handling Either results
  void handleEitherResult<T>(
    Either<Failure, T> result,
    void Function(T) onSuccess,
    void Function(Failure) onFailure,
  ) {
    result.fold(onFailure, onSuccess);
  }
}
```

#### **Step 4: Create Comprehensive State Classes**

```dart
// packages/features/movies/lib/presentation/bloc/movies_list/movies_list_state.dart
abstract class MoviesListState extends BaseState 
    with LoadingStateMixin, ErrorStateMixin, SuccessStateMixin {
  const MoviesListState();
}

class MoviesListInitial extends MoviesListState {
  const MoviesListInitial();
  
  @override
  List<Object> get props => [];
}

class MoviesListLoading extends MoviesListState {
  const MoviesListLoading();
  
  @override
  bool get isLoading => true;
  @override
  bool get isInitialLoading => true;
  
  @override
  List<Object> get props => [];
}

class MoviesListLoaded extends MoviesListState {
  final List<Movie> movies;
  final int currentPage;
  final bool hasReachedMax;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? refreshError;
  final String? loadMoreError;

  const MoviesListLoaded({
    required this.movies,
    required this.currentPage,
    required this.hasReachedMax,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.refreshError,
    this.loadMoreError,
  });

  @override
  bool get isLoading => isRefreshing || isLoadingMore;
  @override
  bool get isRefreshing => isRefreshing;
  @override
  bool get isLoadingMore => isLoadingMore;
  @override
  String? get errorMessage => refreshError ?? loadMoreError;

  MoviesListLoaded copyWith({
    List<Movie>? movies,
    int? currentPage,
    bool? hasReachedMax,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? refreshError,
    String? loadMoreError,
  }) {
    return MoviesListLoaded(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      refreshError: refreshError,
      loadMoreError: loadMoreError,
    );
  }

  @override
  List<Object?> get props => [
    movies, currentPage, hasReachedMax, isRefreshing, 
    isLoadingMore, refreshError, loadMoreError,
  ];
}

class MoviesListError extends MoviesListState {
  final String message;
  final Failure failure;

  const MoviesListError({
    required this.message,
    required this.failure,
  });
  
  @override
  String get errorMessage => message;
  @override
  Failure get failure => failure;

  @override
  List<Object> get props => [message, failure];
}

class MoviesListSearching extends MoviesListState {
  const MoviesListSearching();
  
  @override
  bool get isLoading => true;
  
  @override
  List<Object> get props => [];
}

class MoviesListSearchResults extends MoviesListState {
  final List<Movie> movies;
  final String query;

  const MoviesListSearchResults({
    required this.movies,
    required this.query,
  });

  @override
  List<Object> get props => [movies, query];
}
```

#### **Step 5: Create Comprehensive Event Classes (for BLoC)**

```dart
// packages/features/movies/lib/presentation/bloc/movies_list/movies_list_event.dart
abstract class MoviesListEvent extends BaseEvent {
  const MoviesListEvent();
}

class MoviesListLoadRequested extends MoviesListEvent {
  const MoviesListLoadRequested();
  
  @override
  List<Object> get props => [];
}

class MoviesListRefreshRequested extends MoviesListEvent {
  const MoviesListRefreshRequested();
  
  @override
  List<Object> get props => [];
}

class MoviesListLoadMoreRequested extends MoviesListEvent {
  const MoviesListLoadMoreRequested();
  
  @override
  List<Object> get props => [];
}

class MoviesListSearchRequested extends MoviesListEvent {
  final String query;
  
  const MoviesListSearchRequested(this.query);
  
  @override
  List<Object> get props => [query];
}

class MoviesListSearchCleared extends MoviesListEvent {
  const MoviesListSearchCleared();
  
  @override
  List<Object> get props => [];
}

class MoviesListGenreFilterApplied extends MoviesListEvent {
  final List<String> genres;
  
  const MoviesListGenreFilterApplied(this.genres);
  
  @override
  List<Object> get props => [genres];
}

class MoviesListSortChanged extends MoviesListEvent {
  final MovieSortType sortType;
  
  const MoviesListSortChanged(this.sortType);
  
  @override
  List<Object> get props => [sortType];
}
```

#### **Step 6: Implement Proper BLoC with Business Logic**

```dart
// packages/features/movies/lib/presentation/bloc/movies_list/movies_list_bloc.dart
class MoviesListBloc extends BaseBloc<MoviesListEvent, MoviesListState> {
  final GetPopularMovies _getPopularMovies;
  final SearchMovies _searchMovies;
  final GetTrendingMovies _getTrendingMovies;
  final ConnectivityClient _connectivity;

  MoviesListBloc({
    required GetPopularMovies getPopularMovies,
    required SearchMovies searchMovies,
    required GetTrendingMovies getTrendingMovies,
    required ConnectivityClient connectivity,
    required super.logger,
    super.analytics,
  }) : _getPopularMovies = getPopularMovies,
       _searchMovies = searchMovies,
       _getTrendingMovies = getTrendingMovies,
       _connectivity = connectivity,
       super(initialState: const MoviesListInitial()) {
    
    // Register event handlers
    on<MoviesListLoadRequested>(_onLoadRequested);
    on<MoviesListRefreshRequested>(_onRefreshRequested);
    on<MoviesListLoadMoreRequested>(_onLoadMoreRequested);
    on<MoviesListSearchRequested>(_onSearchRequested);
    on<MoviesListSearchCleared>(_onSearchCleared);
    on<MoviesListGenreFilterApplied>(_onGenreFilterApplied);
    on<MoviesListSortChanged>(_onSortChanged);
  }

  Future<void> _onLoadRequested(
    MoviesListLoadRequested event,
    Emitter<MoviesListState> emit,
  ) async {
    // Prevent multiple simultaneous loads
    if (state is MoviesListLoading) return;
    
    emit(const MoviesListLoading());
    
    // Check connectivity first
    if (!await _connectivity.hasConnection()) {
      emit(MoviesListError(
        message: 'No internet connection',
        failure: NetworkFailure('No internet connection'),
      ));
      return;
    }
    
    final result = await _getPopularMovies(const GetPopularMoviesParams(page: 1));
    
    handleEitherResult(
      result,
      (movies) {
        logger.info('Loaded ${movies.length} movies');
        analytics?.track('movies_loaded', {
          'count': movies.length,
          'source': 'popular',
        });
        
        emit(MoviesListLoaded(
          movies: movies,
          hasReachedMax: movies.length < 20,
          currentPage: 1,
        ));
      },
      (failure) {
        logger.error('Failed to load movies: ${failure.message}');
        analytics?.trackError(failure, StackTrace.current, {
          'action': 'load_movies',
        });
        
        emit(MoviesListError(
          message: failure.message,
          failure: failure,
        ));
      },
    );
  }

  Future<void> _onRefreshRequested(
    MoviesListRefreshRequested event,
    Emitter<MoviesListState> emit,
  ) async {
    final currentState = state;
    
    // Maintain current state while refreshing
    if (currentState is MoviesListLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const MoviesListLoading());
    }

    final result = await _getPopularMovies(const GetPopularMoviesParams(page: 1));
    
    handleEitherResult(
      result,
      (movies) {
        analytics?.track('movies_refreshed', {
          'count': movies.length,
        });
        
        emit(MoviesListLoaded(
          movies: movies,
          hasReachedMax: movies.length < 20,
          currentPage: 1,
          isRefreshing: false,
        ));
      },
      (failure) {
        if (currentState is MoviesListLoaded) {
          emit(currentState.copyWith(
            isRefreshing: false,
            refreshError: failure.message,
          ));
        } else {
          emit(MoviesListError(
            message: failure.message,
            failure: failure,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMoreRequested(
    MoviesListLoadMoreRequested event,
    Emitter<MoviesListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MoviesListLoaded || 
        currentState.hasReachedMax || 
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await _getPopularMovies(
      GetPopularMoviesParams(page: currentState.currentPage + 1),
    );
    
    handleEitherResult(
      result,
      (newMovies) {
        final allMovies = [...currentState.movies, ...newMovies];
        analytics?.track('movies_loaded_more', {
          'page': currentState.currentPage + 1,
          'new_count': newMovies.length,
          'total_count': allMovies.length,
        });
        
        emit(currentState.copyWith(
          movies: allMovies,
          currentPage: currentState.currentPage + 1,
          hasReachedMax: newMovies.length < 20,
          isLoadingMore: false,
          loadMoreError: null,
        ));
      },
      (failure) {
        emit(currentState.copyWith(
          isLoadingMore: false,
          loadMoreError: failure.message,
        ));
      },
    );
  }

  Future<void> _onSearchRequested(
    MoviesListSearchRequested event,
    Emitter<MoviesListState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      add(const MoviesListSearchCleared());
      return;
    }

    emit(const MoviesListSearching());
    
    final result = await _searchMovies(SearchMoviesParams(query: event.query));
    
    handleEitherResult(
      result,
      (movies) {
        analytics?.track('movies_search_performed', {
          'query': event.query,
          'results_count': movies.length,
        });
        
        emit(MoviesListSearchResults(
          movies: movies,
          query: event.query,
        ));
      },
      (failure) {
        emit(MoviesListError(
          message: failure.message,
          failure: failure,
        ));
      },
    );
  }

  Future<void> _onSearchCleared(
    MoviesListSearchCleared event,
    Emitter<MoviesListState> emit,
  ) async {
    analytics?.track('movies_search_cleared');
    add(const MoviesListLoadRequested());
  }

  Future<void> _onGenreFilterApplied(
    MoviesListGenreFilterApplied event,
    Emitter<MoviesListState> emit,
  ) async {
    // Implementation for genre filtering
    analytics?.track('movies_genre_filter_applied', {
      'genres': event.genres,
    });
    // Custom logic for filtering by genres
  }

  Future<void> _onSortChanged(
    MoviesListSortChanged event,
    Emitter<MoviesListState> emit,
  ) async {
    // Implementation for sorting
    analytics?.track('movies_sort_changed', {
      'sort_type': event.sortType.toString(),
    });
    // Custom logic for sorting movies
  }
}
```

#### **Step 7: Implement Cubit for Simpler State Management**

```dart
// packages/features/movies/lib/presentation/bloc/movie_details/movie_details_cubit.dart
class MovieDetailsCubit extends BaseCubit<MovieDetailsState> {
  final GetMovieDetails _getMovieDetails;
  final RateMovie _rateMovie;
  final AddToFavorites _addToFavorites;
  final RemoveFromFavorites _removeFromFavorites;
  final GetRecommendations _getRecommendations;

  MovieDetailsCubit({
    required GetMovieDetails getMovieDetails,
    required RateMovie rateMovie,
    required AddToFavorites addToFavorites,
    required RemoveFromFavorites removeFromFavorites,
    required GetRecommendations getRecommendations,
    required super.logger,
    super.analytics,
  }) : _getMovieDetails = getMovieDetails,
       _rateMovie = rateMovie,
       _addToFavorites = addToFavorites,
       _removeFromFavorites = removeFromFavorites,
       _getRecommendations = getRecommendations,
       super(initialState: const MovieDetailsInitial());

  Future<void> loadMovie(String movieId) async {
    safeEmit(const MovieDetailsLoading());
    
    final result = await _getMovieDetails(GetMovieDetailsParams(id: movieId));
    
    handleEitherResult(
      result,
      (movie) {
        logger.info('Loaded movie details for: ${movie.title}');
        analytics?.track('movie_details_loaded', {
          'movie_id': movieId,
          'movie_title': movie.title,
        });
        
        safeEmit(MovieDetailsLoaded(movie: movie));
        
        // Load recommendations after movie details
        _loadRecommendations(movieId);
      },
      (failure) {
        logger.error('Failed to load movie details: ${failure.message}');
        analytics?.trackError(failure, StackTrace.current, {
          'action': 'load_movie_details',
          'movie_id': movieId,
        });
        
        safeEmit(MovieDetailsError(
          message: failure.message,
          failure: failure,
        ));
      },
    );
  }

  Future<void> rateMovie(String movieId, double rating) async {
    final currentState = state;
    if (currentState is! MovieDetailsLoaded) return;

    safeEmit(currentState.copyWith(isRating: true));
    
    final result = await _rateMovie(RateMovieParams(
      movieId: movieId,
      rating: rating,
    ));
    
    handleEitherResult(
      result,
      (success) {
        analytics?.track('movie_rated', {
          'movie_id': movieId,
          'rating': rating,
        });
        
        safeEmit(currentState.copyWith(
          isRating: false,
          movie: currentState.movie.copyWith(userRating: rating),
          ratingError: null,
        ));
      },
      (failure) {
        safeEmit(currentState.copyWith(
          isRating: false,
          ratingError: failure.message,
        ));
      },
    );
  }

  Future<void> toggleFavorite(String movieId) async {
    final currentState = state;
    if (currentState is! MovieDetailsLoaded) return;

    final isFavorited = currentState.movie.isFavorited;
    safeEmit(currentState.copyWith(isTogglingFavorite: true));
    
    final result = isFavorited
        ? await _removeFromFavorites(RemoveFromFavoritesParams(movieId: movieId))
        : await _addToFavorites(AddToFavoritesParams(movieId: movieId));
    
    handleEitherResult(
      result,
      (newFavoriteStatus) {
        analytics?.track(isFavorited ? 'movie_unfavorited' : 'movie_favorited', {
          'movie_id': movieId,
        });
        
        safeEmit(currentState.copyWith(
          isTogglingFavorite: false,
          movie: currentState.movie.copyWith(isFavorited: newFavoriteStatus),
          favoriteError: null,
        ));
      },
      (failure) {
        safeEmit(currentState.copyWith(
          isTogglingFavorite: false,
          favoriteError: failure.message,
        ));
      },
    );
  }

  Future<void> _loadRecommendations(String movieId) async {
    final currentState = state;
    if (currentState is! MovieDetailsLoaded) return;

    safeEmit(currentState.copyWith(isLoadingRecommendations: true));
    
    final result = await _getRecommendations(GetRecommendationsParams(movieId: movieId));
    
    handleEitherResult(
      result,
      (recommendations) {
        safeEmit(currentState.copyWith(
          isLoadingRecommendations: false,
          recommendations: recommendations,
        ));
      },
      (failure) {
        safeEmit(currentState.copyWith(
          isLoadingRecommendations: false,
          recommendationsError: failure.message,
        ));
      },
    );
  }

  Future<void> retryLoadingRecommendations(String movieId) async {
    await _loadRecommendations(movieId);
  }
}

// Corresponding State classes for MovieDetailsCubit
abstract class MovieDetailsState extends BaseState 
    with LoadingStateMixin, ErrorStateMixin {
  const MovieDetailsState();
}

class MovieDetailsInitial extends MovieDetailsState {
  const MovieDetailsInitial();
  
  @override
  List<Object> get props => [];
}

class MovieDetailsLoading extends MovieDetailsState {
  const MovieDetailsLoading();
  
  @override
  bool get isLoading => true;
  
  @override
  List<Object> get props => [];
}

class MovieDetailsLoaded extends MovieDetailsState {
  final Movie movie;
  final bool isRating;
  final bool isTogglingFavorite;
  final bool isLoadingRecommendations;
  final List<Movie> recommendations;
  final String? ratingError;
  final String? favoriteError;
  final String? recommendationsError;

  const MovieDetailsLoaded({
    required this.movie,
    this.isRating = false,
    this.isTogglingFavorite = false,
    this.isLoadingRecommendations = false,
    this.recommendations = const [],
    this.ratingError,
    this.favoriteError,
    this.recommendationsError,
  });

  @override
  bool get isLoading => isRating || isTogglingFavorite || isLoadingRecommendations;
  @override
  String? get errorMessage => ratingError ?? favoriteError ?? recommendationsError;

  MovieDetailsLoaded copyWith({
    Movie? movie,
    bool? isRating,
    bool? isTogglingFavorite,
    bool? isLoadingRecommendations,
    List<Movie>? recommendations,
    String? ratingError,
    String? favoriteError,
    String? recommendationsError,
  }) {
    return MovieDetailsLoaded(
      movie: movie ?? this.movie,
      isRating: isRating ?? this.isRating,
      isTogglingFavorite: isTogglingFavorite ?? this.isTogglingFavorite,
      isLoadingRecommendations: isLoadingRecommendations ?? this.isLoadingRecommendations,
      recommendations: recommendations ?? this.recommendations,
      ratingError: ratingError,
      favoriteError: favoriteError,
      recommendationsError: recommendationsError,
    );
  }

  @override
  List<Object?> get props => [
    movie, isRating, isTogglingFavorite, isLoadingRecommendations,
    recommendations, ratingError, favoriteError, recommendationsError,
  ];
}

class MovieDetailsError extends MovieDetailsState {
  final String message;
  final Failure failure;

  const MovieDetailsError({
    required this.message,
    required this.failure,
  });
  
  @override
  String get errorMessage => message;
  @override
  Failure get failure => failure;

  @override
  List<Object> get props => [message, failure];
}
```

#### **Step 8: Proper Widget Integration**

```dart
// packages/features/movies/lib/presentation/pages/movies_list_page.dart
class MoviesListPage extends StatelessWidget {
  const MoviesListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<MoviesListBloc>()
        ..add(const MoviesListLoadRequested()),
      child: const _MoviesListView(),
    );
  }
}

class _MoviesListView extends StatelessWidget {
  const _MoviesListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<MoviesListBloc, MoviesListState>(
        listenWhen: (previous, current) {
          // Only listen to error states for showing snackbars
          return current is MoviesListError ||
                 (current is MoviesListLoaded && current.hasError);
        },
        listener: (context, state) {
          if (state is MoviesListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is MoviesListLoaded && state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        buildWhen: (previous, current) {
          // Rebuild for all state changes except error-only updates
          return !(current is MoviesListLoaded && 
                  previous is MoviesListLoaded && 
                  current.movies == previous.movies);
        },
        builder: (context, state) {
          return switch (state) {
            MoviesListInitial() => const Center(
                child: Text('Ready to load movies'),
              ),
            MoviesListLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            MoviesListLoaded() => _buildMoviesList(context, state),
            MoviesListSearching() => const Center(
                child: CircularProgressIndicator(),
              ),
            MoviesListSearchResults() => _buildSearchResults(context, state),
            MoviesListError() => _buildErrorView(context, state),
          };
        },
      ),
    );
  }

  Widget _buildMoviesList(BuildContext context, MoviesListLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MoviesListBloc>().add(const MoviesListRefreshRequested());
        // Wait for refresh to complete
        await context.read<MoviesListBloc>().stream
            .firstWhere((state) => state is MoviesListLoaded && !state.isRefreshing);
      },
      child: ListView.separated(
        itemCount: state.hasReachedMax 
            ? state.movies.length 
            : state.movies.length + 1,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          if (index >= state.movies.length) {
            // Load more indicator
            if (!state.hasReachedMax && !state.isLoadingMore) {
              // Trigger load more
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<MoviesListBloc>().add(const MoviesListLoadMoreRequested());
              });
            }
            return state.isLoadingMore
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink();
          }

          final movie = state.movies[index];
          return MovieCard(
            movie: movie,
            onTap: () => _navigateToDetails(context, movie.id),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, MoviesListSearchResults state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text('Search results for: "${state.query}"'),
              ),
              TextButton(
                onPressed: () {
                  context.read<MoviesListBloc>().add(const MoviesListSearchCleared());
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.movies.isEmpty
              ? const Center(child: Text('No movies found'))
              : ListView.separated(
                  itemCount: state.movies.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final movie = state.movies[index];
                    return MovieCard(
                      movie: movie,
                      onTap: () => _navigateToDetails(context, movie.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, MoviesListError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(state.message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<MoviesListBloc>().add(const MoviesListLoadRequested());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Search Movies'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter movie title...',
          ),
          onSubmitted: (query) {
            Navigator.of(dialogContext).pop();
            context.read<MoviesListBloc>().add(MoviesListSearchRequested(query));
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(BuildContext context, String movieId) {
    context.moduleNavigator.pushNamed(
      '/movies/details',
      arguments: movieId,
    );
  }
}
```

#### **Step 9: Testing BLoCs and Cubits**

```dart
// test/presentation/bloc/movies_list_bloc_test.dart
void main() {
  group('MoviesListBloc', () {
    late MoviesListBloc moviesListBloc;
    late MockGetPopularMovies mockGetPopularMovies;
    late MockSearchMovies mockSearchMovies;
    late MockConnectivityClient mockConnectivity;
    late MockLogger mockLogger;
    late MockAnalytics mockAnalytics;

    setUp(() {
      mockGetPopularMovies = MockGetPopularMovies();
      mockSearchMovies = MockSearchMovies();
      mockConnectivity = MockConnectivityClient();
      mockLogger = MockLogger();
      mockAnalytics = MockAnalytics();

      moviesListBloc = MoviesListBloc(
        getPopularMovies: mockGetPopularMovies,
        searchMovies: mockSearchMovies,
        getTrendingMovies: MockGetTrendingMovies(),
        connectivity: mockConnectivity,
        logger: mockLogger,
        analytics: mockAnalytics,
      );
    });

    tearDown(() {
      moviesListBloc.close();
    });

    group('MoviesListLoadRequested', () {
      blocTest<MoviesListBloc, MoviesListState>(
        'emits [MoviesListLoading, MoviesListLoaded] when successful',
        build: () {
          when(() => mockConnectivity.hasConnection())
              .thenAnswer((_) async => true);
          when(() => mockGetPopularMovies(any()))
              .thenAnswer((_) async => const Right(tMoviesList));
          return moviesListBloc;
        },
        act: (bloc) => bloc.add(const MoviesListLoadRequested()),
        expect: () => [
          const MoviesListLoading(),
          MoviesListLoaded(
            movies: tMoviesList,
            hasReachedMax: false,
            currentPage: 1,
          ),
        ],
        verify: (_) {
          verify(() => mockConnectivity.hasConnection()).called(1);
          verify(() => mockGetPopularMovies(const GetPopularMoviesParams(page: 1)))
              .called(1);
          verify(() => mockAnalytics.track('movies_loaded', any())).called(1);
        },
      );

      blocTest<MoviesListBloc, MoviesListState>(
        'emits [MoviesListLoading, MoviesListError] when network failure',
        build: () {
          when(() => mockConnectivity.hasConnection())
              .thenAnswer((_) async => false);
          return moviesListBloc;
        },
        act: (bloc) => bloc.add(const MoviesListLoadRequested()),
        expect: () => [
          const MoviesListLoading(),
          const MoviesListError(
            message: 'No internet connection',
            failure: NetworkFailure('No internet connection'),
          ),
        ],
        verify: (_) {
          verify(() => mockConnectivity.hasConnection()).called(1);
          verifyNever(() => mockGetPopularMovies(any()));
        },
      );
    });
  });
}
```

### **Key Principles for Creating BLoCs and Cubits:**

1. **Always start with Domain Layer** - Define entities and use cases first
2. **Use Base Classes** - Consistent error handling and logging
3. **Comprehensive States** - Cover all possible UI states with proper properties
4. **Proper Event Design** - Clear, specific events with necessary data
5. **Business Logic in BLoC** - Keep UI logic separate from business logic
6. **Error Handling** - Always handle failures and network issues
7. **Analytics Integration** - Track important user actions and errors
8. **Testing** - Write comprehensive tests for all event/state combinations
9. **Factory Registration** - Use GetIt factory pattern for stateful widgets
10. **Safe State Emission** - Check if BLoC/Cubit is closed before emitting

This comprehensive guide ensures that all BLoCs and Cubits follow production-grade patterns used in InfinitePay's architecture.

### **State Management Hierarchy (Original Pattern)**
class MoviesListBloc extends Bloc<MoviesListEvent, MoviesListState> {
  final GetPopularMovies _getPopularMovies;
  final SearchMovies _searchMovies;
  final Logger _logger;

  MoviesListBloc({
    required GetPopularMovies getPopularMovies,
    required SearchMovies searchMovies,
    Logger? logger,
  }) : _getPopularMovies = getPopularMovies,
       _searchMovies = searchMovies,
       _logger = logger ?? Logger('MoviesListBloc'),
       super(const MoviesListInitial()) {
    
    on<MoviesListLoadRequested>(_onLoadRequested);
    on<MoviesListRefreshRequested>(_onRefreshRequested);
    on<MoviesListLoadMoreRequested>(_onLoadMoreRequested);
    on<MoviesListSearchRequested>(_onSearchRequested);
    on<MoviesListSearchCleared>(_onSearchCleared);
  }

  Future<void> _onLoadRequested(
    MoviesListLoadRequested event,
    Emitter<MoviesListState> emit,
  ) async {
    if (state is MoviesListLoading) return; // Prevent multiple loads
    
    emit(const MoviesListLoading());
    
    final result = await _getPopularMovies(const GetPopularMoviesParams(page: 1));
    
    result.fold(
      (failure) {
        _logger.error('Failed to load movies: ${failure.message}');
        emit(MoviesListError(failure.message));
      },
      (movies) {
        _logger.info('Loaded ${movies.length} movies');
        emit(MoviesListLoaded(
          movies: movies,
          hasReachedMax: movies.length < 20,
          currentPage: 1,
        ));
      },
    );
  }

  Future<void> _onRefreshRequested(
    MoviesListRefreshRequested event,
    Emitter<MoviesListState> emit,
  ) async {
    // Maintain current state while refreshing
    if (state is MoviesListLoaded) {
      final currentState = state as MoviesListLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const MoviesListLoading());
    }

    final result = await _getPopularMovies(const GetPopularMoviesParams(page: 1));
    
    result.fold(
      (failure) {
        if (state is MoviesListLoaded) {
          final currentState = state as MoviesListLoaded;
          emit(currentState.copyWith(
            isRefreshing: false,
            refreshError: failure.message,
          ));
        } else {
          emit(MoviesListError(failure.message));
        }
      },
      (movies) {
        emit(MoviesListLoaded(
          movies: movies,
          hasReachedMax: movies.length < 20,
          currentPage: 1,
          isRefreshing: false,
        ));
      },
    );
  }

  Future<void> _onLoadMoreRequested(
    MoviesListLoadMoreRequested event,
    Emitter<MoviesListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MoviesListLoaded || 
        currentState.hasReachedMax || 
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await _getPopularMovies(
      GetPopularMoviesParams(page: currentState.currentPage + 1),
    );
    
    result.fold(
      (failure) {
        emit(currentState.copyWith(
          isLoadingMore: false,
          loadMoreError: failure.message,
        ));
      },
      (newMovies) {
        final allMovies = [...currentState.movies, ...newMovies];
        emit(currentState.copyWith(
          movies: allMovies,
          currentPage: currentState.currentPage + 1,
          hasReachedMax: newMovies.length < 20,
          isLoadingMore: false,
          loadMoreError: null,
        ));
      },
    );
  }

  Future<void> _onSearchRequested(
    MoviesListSearchRequested event,
    Emitter<MoviesListState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      add(const MoviesListSearchCleared());
      return;
    }

    emit(const MoviesListSearching());
    
    final result = await _searchMovies(SearchMoviesParams(query: event.query));
    
    result.fold(
      (failure) => emit(MoviesListError(failure.message)),
      (movies) => emit(MoviesListSearchResults(
        movies: movies,
        query: event.query,
      )),
    );
  }

  Future<void> _onSearchCleared(
    MoviesListSearchCleared event,
    Emitter<MoviesListState> emit,
  ) async {
    add(const MoviesListLoadRequested());
  }

  @override
  void onTransition(Transition<MoviesListEvent, MoviesListState> transition) {
    super.onTransition(transition);
    _logger.info('Transition: ${transition.event} -> ${transition.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _logger.error('BLoC Error', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}

// State definitions with comprehensive properties
abstract class MoviesListState extends BaseState with LoadingStateMixin, ErrorStateMixin {
  const MoviesListState();
}

class MoviesListInitial extends MoviesListState {
  const MoviesListInitial();
  
  @override
  List<Object> get props => [];
}

class MoviesListLoading extends MoviesListState {
  const MoviesListLoading();
  
  @override
  bool get isLoading => true;
  @override
  bool get isInitialLoading => true;
  
  @override
  List<Object> get props => [];
}

class MoviesListLoaded extends MoviesListState {
  final List<Movie> movies;
  final int currentPage;
  final bool hasReachedMax;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? refreshError;
  final String? loadMoreError;

  const MoviesListLoaded({
    required this.movies,
    required this.currentPage,
    required this.hasReachedMax,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.refreshError,
    this.loadMoreError,
  });

  @override
  bool get isLoading => isRefreshing || isLoadingMore;
  @override
  bool get isLoadingMore => isLoadingMore;

  MoviesListLoaded copyWith({
    List<Movie>? movies,
    int? currentPage,
    bool? hasReachedMax,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? refreshError,
    String? loadMoreError,
  }) {
    return MoviesListLoaded(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      refreshError: refreshError,
      loadMoreError: loadMoreError,
    );
  }

  @override
  List<Object?> get props => [
    movies, currentPage, hasReachedMax, isRefreshing, 
    isLoadingMore, refreshError, loadMoreError,
  ];
}

class MoviesListSearching extends MoviesListState {
  const MoviesListSearching();
  
  @override
  bool get isLoading => true;
  
  @override
  List<Object> get props => [];
}

class MoviesListSearchResults extends MoviesListState {
  final List<Movie> movies;
  final String query;

  const MoviesListSearchResults({
    required this.movies,
    required this.query,
  });

  @override
  List<Object> get props => [movies, query];
}

class MoviesListError extends MoviesListState {
  final String message;

  const MoviesListError(this.message);
  
  @override
  String get errorMessage => message;

  @override
  List<Object> get props => [message];
}
```

### **Cubit for Simpler State Management**
```dart
// packages/features/movies/lib/presentation/bloc/movie_details/movie_details_cubit.dart
class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  final GetMovieDetails _getMovieDetails;
  final RateMovie _rateMovie;
  final AddToFavorites _addToFavorites;
  final Logger _logger;

  MovieDetailsCubit({
    required GetMovieDetails getMovieDetails,
    required RateMovie rateMovie,
    required AddToFavorites addToFavorites,
    Logger? logger,
  }) : _getMovieDetails = getMovieDetails,
       _rateMovie = rateMovie,
       _addToFavorites = addToFavorites,
       _logger = logger ?? Logger('MovieDetailsCubit'),
       super(const MovieDetailsInitial());

  Future<void> loadMovie(String movieId) async {
    emit(const MovieDetailsLoading());
    
    final result = await _getMovieDetails(GetMovieDetailsParams(id: movieId));
    
    result.fold(
      (failure) {
        _logger.error('Failed to load movie details: ${failure.message}');
        emit(MovieDetailsError(failure.message));
      },
      (movie) {
        _logger.info('Loaded movie details for: ${movie.title}');
        emit(MovieDetailsLoaded(movie: movie));
      },
    );
  }

  Future<void> rateMovie(String movieId, double rating) async {
    final currentState = state;
    if (currentState is! MovieDetailsLoaded) return;

    emit(currentState.copyWith(isRating: true));
    
    final result = await _rateMovie(RateMovieParams(
      movieId: movieId,
      rating: rating,
    ));
    
    result.fold(
      (failure) {
        emit(currentState.copyWith(
          isRating: false,
          ratingError: failure.message,
        ));
      },
      (success) {
        emit(currentState.copyWith(
          isRating: false,
          movie: currentState.movie.copyWith(userRating: rating),
        ));
      },
    );
  }

  Future<void> toggleFavorite(String movieId) async {
    final currentState = state;
    if (currentState is! MovieDetailsLoaded) return;

    emit(currentState.copyWith(isTogglingFavorite: true));
    
    final result = await _addToFavorites(AddToFavoritesParams(movieId: movieId));
    
    result.fold(
      (failure) {
        emit(currentState.copyWith(
          isTogglingFavorite: false,
          favoriteError: failure.message,
        ));
      },
      (isFavorited) {
        emit(currentState.copyWith(
          isTogglingFavorite: false,
          movie: currentState.movie.copyWith(isFavorited: isFavorited),
        ));
      },
    );
  }

  @override
  void onChange(Change<MovieDetailsState> change) {
    super.onChange(change);
    _logger.info('State changed: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}');
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    _logger.error('Cubit Error', error, stackTrace);
    super.onError(error, stackTrace);
  }
}
```

## 🤖 Claude Code Specialists & AI Development Tools

This project integrates with Claude Code's specialized agents for enhanced development workflow:

### **Available Claude Specialists**

#### **🔧 Flutter Debugger**
```bash
# Automatic debugging assistance for Flutter issues
# Specializes in: BLoC state issues, build errors, test failures, runtime exceptions
# Usage: Activated automatically when errors occur

# Example integration in development workflow:
melos analyze  # Triggers flutter-debugger for analysis issues
melos test    # Activates for test failures and debugging
```

#### **🎨 Design System Specialist**
```bash
# Expert in InfinitePay Design System patterns
# Always references design system documentation
# Returns runnable code with citations

# Usage examples:
# - Creating consistent UI components
# - Implementing design system tokens
# - Maintaining visual consistency across modules
```

#### **🏗️ BLoC Architecture Specialist**
```bash
# Expert in Flutter BLoC/Cubit architecture
# Specializes in: Clean Architecture patterns, SOLID principles
# Usage: Proactive guidance for state management decisions

# Activated when:
# - Creating new BLoC implementations
# - Reviewing state management architecture
# - Implementing complex state flows
```

#### **🧪 Integration Test Engineer**
```bash
# Specializes in Flutter integration tests (*_integration_test.dart)
# Expert in: test-driven mock development, page objects, test flows

# Example usage:
melos test:integration  # Triggers integration test specialist
# - Debugging test failures  
# - Creating mocks following TDD patterns
# - Developing page objects and flows
```

#### **🔬 Unit Test Specialist**
```bash
# Expert in Flutter unit testing with mocktail and bloc_test
# Follows strict AAA (Arrange-Act-Assert) patterns

# Usage examples:
melos test:unit  # Activates for unit testing guidance
# - Creating Cubit/BLoC tests
# - Implementing mocktail patterns
# - Following testing best practices
```

#### **🎭 Widget Test Robot Specialist**
```bash
# Expert in Flutter widget testing using Robot pattern
# Specializes in: Robot test files, scenarios, golden tests

# Example activation:
melos test:robot  # Triggers robot testing specialist
# - Creating Robot test files
# - Implementing test scenarios  
# - Golden test generation
```

#### **🧭 Flutter Code Reviewer**
```bash
# Proactive code review focusing on:
# - Clean Architecture compliance
# - SOLID principles adherence
# - Performance optimization
# - Security considerations

# Automatic activation after:
melos generate   # Reviews generated code
git commit      # Pre-commit code review
```

### **AI-Enhanced Development Commands**

#### **Intelligent Code Generation**
```bash
# Enhanced melos commands with AI assistance
melos generate --ai-review     # Generate code with automatic review
melos analyze --ai-suggest     # Analysis with improvement suggestions
melos test --ai-debug         # Testing with intelligent debugging

# AI-powered development workflows
melos ai:review-pr            # Complete PR review with all specialists
melos ai:debug-issue          # Multi-specialist issue debugging
melos ai:optimize-performance # Performance analysis and suggestions
```

#### **Smart Testing Integration**
```yaml
# .github/workflows/ai-enhanced-ci.yml
name: AI-Enhanced CI/CD

jobs:
  ai_code_review:
    runs-on: ubuntu-latest
    steps:
      - name: AI Code Review
        run: |
          melos bootstrap
          melos ai:review-pr --automated
          melos ai:test-suggestions --implement
```

#### **Development Assistant Configuration**
```dart
// app/lib/core/ai_development_config.dart
class AIDevelopmentConfig {
  static const Map<String, String> specialistConfig = {
    'flutter-debugger': 'Auto-activate on errors and test failures',
    'design-system-specialist': 'Review all UI component changes',
    'bloc-architecture-specialist': 'Guide state management decisions',
    'integration-test-engineer': 'Assist with integration test development',
    'unit-test-specialist': 'Ensure comprehensive unit test coverage',
    'widget-test-robot-specialist': 'Implement Robot pattern tests',
    'flutter-code-reviewer': 'Review all code changes proactively',
  };

  static const List<String> proactiveSpecialists = [
    'flutter-debugger',
    'bloc-architecture-specialist', 
    'flutter-code-reviewer',
  ];
}
```

### **AI-Powered Development Workflow**

#### **1. Feature Development Cycle**
```bash
# AI-assisted feature development
melos ai:start-feature movies_search
# -> Activates bloc-architecture-specialist for state management guidance
# -> Activates design-system-specialist for UI consistency
# -> Sets up testing framework with test specialists

melos ai:implement-feature
# -> Real-time code review during implementation
# -> Automatic architectural guidance
# -> Performance optimization suggestions

melos ai:test-feature  
# -> Comprehensive testing with all test specialists
# -> Robot pattern implementation
# -> Integration test guidance

melos ai:review-feature
# -> Complete code review with flutter-code-reviewer
# -> Security and performance analysis
# -> Clean Architecture compliance check
```

#### **2. Debugging and Issue Resolution**
```bash
# Intelligent debugging workflow
melos ai:debug-issue "BLoC state not updating"
# -> Activates flutter-debugger for BLoC analysis
# -> Activates bloc-architecture-specialist for state management review
# -> Provides step-by-step debugging guidance

melos ai:analyze-performance
# -> Performance profiling with recommendations
# -> Memory leak detection
# -> Optimization suggestions
```

#### **3. Quality Assurance Integration**
```bash
# AI-enhanced QA process
melos ai:quality-check
# -> Runs all code quality specialists
# -> Generates comprehensive quality report
# -> Provides actionable improvement suggestions

melos ai:security-audit
# -> Security-focused code review
# -> Vulnerability detection
# -> Best practice compliance
```

### **Development Environment Integration**

#### **VS Code Extension Integration**
```json
// .vscode/claude-code.json
{
  "autoActivateSpecialists": true,
  "proactiveReview": true,
  "specialistPreferences": {
    "flutter-debugger": "high-priority",
    "bloc-architecture-specialist": "medium-priority",
    "design-system-specialist": "medium-priority"
  },
  "aiCommands": {
    "generateTests": "melos ai:generate-tests",
    "reviewCode": "melos ai:review-current",
    "debugIssue": "melos ai:debug-current"
  }
}
```

This comprehensive architecture guide provides everything needed to build scalable, maintainable Flutter applications using enterprise-grade patterns. The integration with Claude Code specialists ensures AI-assisted development with automatic code review, debugging support, and architectural guidance throughout the development lifecycle.

Each architectural decision is made with long-term maintainability, testability, and team collaboration in mind, while the AI enhancement tools provide intelligent assistance for common development tasks and quality assurance processes.