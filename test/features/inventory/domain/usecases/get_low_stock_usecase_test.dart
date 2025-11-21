import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/get_low_stock_usecase.dart';
import 'package:backstage_frontend/features/pos/domain/entities/product.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late GetLowStockUseCaseImpl useCase;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = GetLowStockUseCaseImpl(mockRepository);
  });

  const tLowStockProduct = Product(
    sku: 'SKU001',
    name: 'Popcorn',
    unitPrice: 15.0,
    category: 'Snacks',
    qtyOnHand: 5,
    reorderLevel: 20,
    isActive: true,
  );
  const tLowStockProducts = [tLowStockProduct];

  test('should call repository.getLowStockProducts', () async {
    // Arrange
    when(() => mockRepository.getLowStockProducts())
        .thenAnswer((_) async => const Right(tLowStockProducts));

    // Act
    await useCase.call(const NoParams());

    // Assert
    verify(() => mockRepository.getLowStockProducts()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return list of low stock Products when successful', () async {
    // Arrange
    when(() => mockRepository.getLowStockProducts())
        .thenAnswer((_) async => const Right(tLowStockProducts));

    // Act
    final result = await useCase.call(const NoParams());

    // Assert
    expect(result, const Right(tLowStockProducts));
  });

  test('should return Failure when repository fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to fetch low stock products');
    when(() => mockRepository.getLowStockProducts())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(const NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}
