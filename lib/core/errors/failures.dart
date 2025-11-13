import 'package:equatable/equatable.dart';

/// Base Failure class for all errors in the app
/// Use this single class for all failure types
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() => 'Failure: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Generic failure implementation
class GenericFailure extends Failure {
  const GenericFailure({
    required super.message,
    super.statusCode,
  });
}
