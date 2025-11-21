import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/get_product_details_usecase.dart';
import 'package:backstage_frontend/features/pos/domain/entities/product.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late GetProductDetailsUseCaseImpl useCase;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = GetProductDetailsUseCaseImpl(mockRepository);
  });

  const tSku = 'SKU001';
  const tProduct = Product(
    sku: tSku,
    name: 'Popcorn',
    unitPrice: 15.0,
    category: 'Snacks',
    qtyOnHand: 100,
    reorderLevel: 20,
    barcode: '1234567890',
    isActive: true,
  );

  test('should call repository.getProductDetails with correct sku', () async {
    // Arrange
    when(() => mockRepository.getProductDetails(any()))
        .thenAnswer((_) async => const Right(tProduct));

    // Act
    await useCase.call(GetProductDetailsParams(sku: tSku));

    // Assert
    verify(() => mockRepository.getProductDetails(tSku)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Product when successful', () async {
    // Arrange
    when(() => mockRepository.getProductDetails(any()))
        .thenAnswer((_) async => const Right(tProduct));

    // Act
    final result = await useCase.call(GetProductDetailsParams(sku: tSku));

    // Assert
    expect(result, const Right(tProduct));
  });

  test('should return Failure when repository fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Product not found');
    when(() => mockRepository.getProductDetails(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(GetProductDetailsParams(sku: tSku));

    // Assert
    expect(result, const Left(tFailure));
  });
}
