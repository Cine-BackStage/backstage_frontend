import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/get_inventory_usecase.dart';
import 'package:backstage_frontend/features/pos/domain/entities/product.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late GetInventoryUseCaseImpl useCase;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = GetInventoryUseCaseImpl(mockRepository);
  });

  const tProduct1 = Product(
    sku: 'SKU001',
    name: 'Popcorn',
    unitPrice: 15.0,
    category: 'Snacks',
    qtyOnHand: 100,
    reorderLevel: 20,
    barcode: '1234567890',
    isActive: true,
  );

  const tProduct2 = Product(
    sku: 'SKU002',
    name: 'Soda',
    unitPrice: 8.0,
    category: 'Beverages',
    qtyOnHand: 50,
    reorderLevel: 10,
    isActive: true,
  );

  const tProducts = [tProduct1, tProduct2];

  test('should call repository.getInventory', () async {
    // Arrange
    when(() => mockRepository.getInventory())
        .thenAnswer((_) async => const Right(tProducts));

    // Act
    await useCase.call(const NoParams());

    // Assert
    verify(() => mockRepository.getInventory()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return list of Products when successful', () async {
    // Arrange
    when(() => mockRepository.getInventory())
        .thenAnswer((_) async => const Right(tProducts));

    // Act
    final result = await useCase.call(const NoParams());

    // Assert
    expect(result, const Right(tProducts));
  });

  test('should return Failure when repository fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to fetch inventory');
    when(() => mockRepository.getInventory())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(const NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}
