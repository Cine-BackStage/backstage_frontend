import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user
class User extends Equatable {
  final String id;
  final String cpf;
  final String name;
  final String role; // 'admin' or 'employee'
  final String? cinemaId;
  final String? cinemaName;

  const User({
    required this.id,
    required this.cpf,
    required this.name,
    required this.role,
    this.cinemaId,
    this.cinemaName,
  });

  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';

  @override
  List<Object?> get props => [id, cpf, name, role, cinemaId, cinemaName];
}
