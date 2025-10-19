import 'package:equatable/equatable.dart';

/// Credentials for login
class Credentials extends Equatable {
  final String cpf;
  final String password;

  const Credentials({
    required this.cpf,
    required this.password,
  });

  @override
  List<Object> get props => [cpf, password];
}
