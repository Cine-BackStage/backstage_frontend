import 'package:equatable/equatable.dart';

/// Authentication token
class AuthToken extends Equatable {
  final String token;
  final DateTime expiresAt;

  const AuthToken({
    required this.token,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object> get props => [token, expiresAt];
}
