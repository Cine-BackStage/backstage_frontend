import '../../domain/entities/company.dart';

/// Company data model (extends domain entity)
class CompanyModel extends Company {
  const CompanyModel({
    required super.id,
    required super.name,
    super.tradeName,
  });

  /// Create model from JSON (backend response)
  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      tradeName: json['tradeName'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tradeName': tradeName,
    };
  }
}
