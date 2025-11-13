import 'package:equatable/equatable.dart';

/// Company domain entity (immutable)
class Company extends Equatable {
  final String id;
  final String name;
  final String? tradeName;

  const Company({
    required this.id,
    required this.name,
    this.tradeName,
  });

  @override
  List<Object?> get props => [id, name, tradeName];
}
