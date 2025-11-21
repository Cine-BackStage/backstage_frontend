import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/create_product_usecase.dart';
import 'package:backstage_frontend/features/pos/domain/entities/product.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late CreateProductUseCaseImpl useCase;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = CreateProductUseCaseImpl(mockRepository);
  });

  const tSku = 'SKU001';
  const tName = 'Popcorn';
  const tUnitPrice = 15.0;
  const tCategory = 'Snacks';
  const tInitialStock = 100;
  const tBarcode = '1234567890';

  const tProduct = Product(
    sku: tSku,
    name: tName,
    unitPrice: tUnitPrice,
    category: tCategory,
    qtyOnHand: tInitialStock,
    reorderLevel: 20,
    barcode: tBarcode,
    isActive: true,
  );

  test('should call repository.createProduct with correct parameters', () async {
    // Arrange
    when(() => mockRepository.createProduct(
          sku: any(named: 'sku'),
          name: any(named: 'name'),
          unitPrice: any(named: 'unitPrice'),
          category: any(named: 'category'),
          initialStock: any(named: 'initialStock'),
          barcode: any(named: 'barcode'),
        )).thenAnswer((_) async => const Right(tProduct));

    // Act
    await useCase.call(CreateProductParams(
      sku: tSku,
      name: tName,
      unitPrice: tUnitPrice,
      category: tCategory,
      initialStock: tInitialStock,
      barcode: tBarcode,
    ));

    // Assert
    verify(() => mockRepository.createProduct(
          sku: tSku,
          name: tName,
          unitPrice: tUnitPrice,
          category: tCategory,
          initialStock: tInitialStock,
          barcode: tBarcode,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Product when creation is successful', () async {
    // Arrange
    when(() => mockRepository.createProduct(
          sku: any(named: 'sku'),
          name: any(named: 'name'),
          unitPrice: any(named: 'unitPrice'),
          category: any(named: 'category'),
          initialStock: any(named: 'initialStock'),
          barcode: any(named: 'barcode'),
        )).thenAnswer((_) async => const Right(tProduct));

    // Act
    final result = await useCase.call(CreateProductParams(
      sku: tSku,
      name: tName,
      unitPrice: tUnitPrice,
      category: tCategory,
      initialStock: tInitialStock,
      barcode: tBarcode,
    ));

    // Assert
    expect(result, const Right(tProduct));
  });

  test('should call createProduct without barcode when not provided', () async {
    // Arrange
    when(() => mockRepository.createProduct(
          sku: any(named: 'sku'),
          name: any(named: 'name'),
          unitPrice: any(named: 'unitPrice'),
          category: any(named: 'category'),
          initialStock: any(named: 'initialStock'),
          barcode: any(named: 'barcode'),
        )).thenAnswer((_) async => const Right(tProduct));

    // Act
    await useCase.call(CreateProductParams(
      sku: tSku,
      name: tName,
      unitPrice: tUnitPrice,
      category: tCategory,
      initialStock: tInitialStock,
    ));

    // Assert
    verify(() => mockRepository.createProduct(
          sku: tSku,
          name: tName,
          unitPrice: tUnitPrice,
          category: tCategory,
          initialStock: tInitialStock,
          barcode: null,
        )).called(1);
  });

  test('should return Failure when creation fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to create product');
    when(() => mockRepository.createProduct(
          sku: any(named: 'sku'),
          name: any(named: 'name'),
          unitPrice: any(named: 'unitPrice'),
          category: any(named: 'category'),
          initialStock: any(named: 'initialStock'),
          barcode: any(named: 'barcode'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(CreateProductParams(
      sku: tSku,
      name: tName,
      unitPrice: tUnitPrice,
      category: tCategory,
      initialStock: tInitialStock,
      barcode: tBarcode,
    ));

    // Assert
    expect(result, const Left(tFailure));
  });
}
