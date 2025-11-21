import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/pos/domain/entities/product.dart';
import 'package:backstage_frontend/features/pos/domain/repositories/pos_repository.dart';
import 'package:backstage_frontend/features/pos/domain/usecases/pos_usecases.dart';

class MockPosRepository extends Mock implements PosRepository {}

void main() {
  late GetProductsUseCaseImpl useCase;
  late MockPosRepository mockRepository;

  setUp(() {
    mockRepository = MockPosRepository();
    useCase = GetProductsUseCaseImpl(mockRepository);
  });

  final tProducts = [
    Product(
      sku: 'SKU001',
      name: 'Popcorn',
      unitPrice: 15.0,
      category: 'Snacks',
      qtyOnHand: 100,
      reorderLevel: 20,
      isActive: true,
    ),
    Product(
      sku: 'SKU002',
      name: 'Soda',
      unitPrice: 8.0,
      category: 'Beverages',
      qtyOnHand: 50,
      reorderLevel: 10,
      isActive: true,
    ),
  ];

  test('should call repository.getProducts', () async {
    // Arrange
    when(() => mockRepository.getProducts())
        .thenAnswer((_) async => Right(tProducts));

    // Act
    await useCase.call(NoParams());

    // Assert
    verify(() => mockRepository.getProducts()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return List<Product> when call is successful', () async {
    // Arrange
    when(() => mockRepository.getProducts())
        .thenAnswer((_) async => Right(tProducts));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, Right(tProducts));
  });

  test('should return Failure when call fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to get products');
    when(() => mockRepository.getProducts())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}
