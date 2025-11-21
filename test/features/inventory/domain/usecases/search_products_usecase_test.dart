import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/search_products_usecase.dart';
import 'package:backstage_frontend/features/pos/domain/entities/product.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late SearchProductsUseCaseImpl useCase;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = SearchProductsUseCaseImpl(mockRepository);
  });

  const tQuery = 'Popcorn';
  const tProduct = Product(
    sku: 'SKU001',
    name: 'Popcorn',
    unitPrice: 15.0,
    category: 'Snacks',
    qtyOnHand: 100,
    reorderLevel: 20,
    isActive: true,
  );
  const tProducts = [tProduct];

  test('should call repository.searchProducts with correct query', () async {
    // Arrange
    when(() => mockRepository.searchProducts(any()))
        .thenAnswer((_) async => const Right(tProducts));

    // Act
    await useCase.call(SearchProductsParams(query: tQuery));

    // Assert
    verify(() => mockRepository.searchProducts(tQuery)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return list of Products when search is successful', () async {
    // Arrange
    when(() => mockRepository.searchProducts(any()))
        .thenAnswer((_) async => const Right(tProducts));

    // Act
    final result = await useCase.call(SearchProductsParams(query: tQuery));

    // Assert
    expect(result, const Right(tProducts));
  });

  test('should return Failure when search fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Search failed');
    when(() => mockRepository.searchProducts(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(SearchProductsParams(query: tQuery));

    // Assert
    expect(result, const Left(tFailure));
  });
}
