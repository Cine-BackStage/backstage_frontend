# Error Message Guidelines for Backstage Cinema

## Principle
All error messages shown to users must be user-friendly, non-technical, and actionable. Technical details should only be logged, never displayed to end users.

## Error Message Transformation Rules

### Network Errors
- **Technical**: "Connection timeout", "Network error", "Failed to fetch"
- **User-Friendly**: "Não foi possível conectar ao servidor. Verifique sua conexão com a internet."

### Server Errors (500, 502, 503)
- **Technical**: "Internal server error", "Bad gateway", "Service unavailable"
- **User-Friendly**: "O servidor está temporariamente indisponível. Por favor, tente novamente em alguns instantes."

### Authentication Errors (401)
- **Technical**: "Unauthorized", "Invalid token", "Token expired"
- **User-Friendly**: "Sua sessão expirou. Por favor, faça login novamente."

### Permission Errors (403)
- **Technical**: "Forbidden", "Access denied"
- **User-Friendly**: "Você não tem permissão para acessar este recurso."

### Not Found Errors (404)
- **Technical**: "Not found", "Resource not found", "Endpoint not found"
- **User-Friendly**: "O recurso solicitado não foi encontrado."

### Validation Errors (400)
- **Technical**: "Validation failed", "Invalid input", "Bad request"
- **User-Friendly**: Extract the specific field error if available, otherwise "Os dados informados são inválidos. Por favor, verifique e tente novamente."

### Conflict Errors (409)
- **Technical**: "Conflict", "Already exists", "Duplicate entry"
- **User-Friendly**: "Este registro já existe no sistema."

### Timeout Errors
- **Technical**: "Request timeout", "Connection timeout"
- **User-Friendly**: "A operação demorou muito tempo. Por favor, tente novamente."

### Parse/Type Errors
- **Technical**: "Type cast error", "Parse error", "Invalid format"
- **User-Friendly**: "Ocorreu um erro ao processar os dados. Por favor, tente novamente."

### Generic/Unknown Errors
- **Technical**: Any unhandled error
- **User-Friendly**: "Ocorreu um erro inesperado. Por favor, tente novamente."

## Implementation Location

All error transformations are handled in the `ErrorMapper` class:
- File: `lib/core/errors/error_mapper.dart`
- Method: `fromDioException()`, `fromException()`

## Failure Types

Each Failure type should have:
1. **message**: Technical message for logging (kept for debugging)
2. **userMessage**: User-friendly message displayed in UI
3. **statusCode**: HTTP status code if applicable
4. **isCritical**: Boolean flag for visual distinction

Example:
```dart
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network connection error',  // Technical
    super.technicalMessage,
    super.statusCode,
  });

  @override
  String get userMessage => 'Verifique sua conexão com a internet e tente novamente.';  // User-friendly
}
```

## UI Display Rules

1. **Error Pages**: Show user-friendly message with retry button
2. **Snackbars**: Only for non-critical, transient errors (avoid duplication with error pages)
3. **Form Validation**: Show specific field errors inline
4. **Critical Errors**: Use red color (AppColors.error) with bold icon
5. **Non-Critical Errors**: Use orange/warning color (AppColors.alertWarning)

## Never Show to Users

- Stack traces
- Database errors
- File paths
- Raw API responses
- Technical exception names
- Internal system details
