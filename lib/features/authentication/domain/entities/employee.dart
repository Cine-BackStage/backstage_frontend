import 'package:equatable/equatable.dart';

/// Employee domain entity (immutable)
class Employee extends Equatable {
  final String cpf;
  final String companyId;
  final String employeeId;
  final String role;
  final String fullName;
  final String email;
  final bool isActive;

  const Employee({
    required this.cpf,
    required this.companyId,
    required this.employeeId,
    required this.role,
    required this.fullName,
    required this.email,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        cpf,
        companyId,
        employeeId,
        role,
        fullName,
        email,
        isActive,
      ];
}
