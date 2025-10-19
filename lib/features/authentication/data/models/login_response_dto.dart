import 'user_dto.dart';

/// Login response Data Transfer Object
class LoginResponseDto {
  final String token;
  final UserDto user;
  final int expiresIn; // Token expiry in seconds

  const LoginResponseDto({
    required this.token,
    required this.user,
    this.expiresIn = 86400, // Default: 24 hours
  });

  /// Create DTO from JSON
  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      token: json['token'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      expiresIn: json['expires_in'] as int? ?? 86400,
    );
  }

  /// Convert DTO to JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'expires_in': expiresIn,
    };
  }

  /// Get token expiry date
  DateTime get expiryDate {
    return DateTime.now().add(Duration(seconds: expiresIn));
  }
}
