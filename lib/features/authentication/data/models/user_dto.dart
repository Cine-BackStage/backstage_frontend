import '../../domain/entities/user.dart';

/// User Data Transfer Object
class UserDto {
  final String id;
  final String cpf;
  final String name;
  final String role;
  final String? cinemaId;
  final String? cinemaName;

  const UserDto({
    required this.id,
    required this.cpf,
    required this.name,
    required this.role,
    this.cinemaId,
    this.cinemaName,
  });

  /// Convert DTO to domain entity
  User toEntity() {
    return User(
      id: id,
      cpf: cpf,
      name: name,
      role: role,
      cinemaId: cinemaId,
      cinemaName: cinemaName,
    );
  }

  /// Create DTO from JSON
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      cpf: json['cpf'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      cinemaId: json['cinema_id'] as String?,
      cinemaName: json['cinema_name'] as String?,
    );
  }

  /// Convert DTO to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cpf': cpf,
      'name': name,
      'role': role,
      'cinema_id': cinemaId,
      'cinema_name': cinemaName,
    };
  }
}
