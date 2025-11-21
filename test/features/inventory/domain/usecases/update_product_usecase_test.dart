import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/update_product_usecase.dart';
import 'package:backstage_frontend/features/pos/domain/entities/product.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late UpdateProductUseCaseImpl useCase;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = UpdateProductUseCaseImpl(mockRepository);
  });

  const tSku = 'SKU001';
  const tName = 'Updated Popcorn';
  const tUnitPrice = 18.0;
  const tCategory = 'Snacks';
  const tBarcode = '9876543210';

  const tProduct = Product(
    sku: tSku,
    name: tName,
    unitPrice: tUnitPrice,
    category: tCategory,
    qtyOnHand: 100,
    reorderLevel: 20,
    barcode: tBarcode,
    isActive: true,
  );

  test('should call repository.updateProduct with correct parameters', () async {
    // Arrange
    when(() => mockRepository.updateProduct(
          sku: any(named: 'sku'),
          name: any(named: 'name'),
          unitPrice: any(named: 'unitPrice'),
          category: any(named: 'category'),
          barcode: any(named: 'barcode'),
        )).thenAnswer((_) async => const Right(tProduct));

    // Act
    await useCase.call(UpdateProductParams(
      sku: tSku,
      name: tName,
      unitPrice: tUnitPrice,
      category: tCategory,
      barcode: tBarcode,
    ));

    // Assert
    verify(() => mockRepository.updateProduct(
          sku: tSku,
          name: tName,
          unitPrice: tUnitPrice,
          category: tCategory,
          barcode: tBarcode,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Product when update is successful', () async {
    // Arrange
    when(() => mockRepository.updateProduct(
          sku: any(named: 'sku'),
          name: any(named: 'name'),
          unitPrice: any(named: 'unitPrice'),
          category: any(named: 'category'),
          barcode: any(named: 'barcode'),
        )).thenAnswer((_) async => const Right(tProduct));

    // Act
    final result = await useCase.call(UpdateProductParams(
      sku: tSku,
      name: tName,
      unitPrice: tUnitPrice,
      category: tCategory,
      barcode: tBarcode,
    ));

    // Assert
    expect(result, const Right(tProduct));
  });

  test('should call updateProduct with only sku when no fields provided', () async {
    // Arrange
    when(() => mockRepository.updateProduct(
          sku: any(named: 'sku'),
          name: any(named: 'name'),
          unitPrice: any(named: 'unitPrice'),
          category: any(named: 'category'),
          barcode: any(named: 'barcode'),
        )).thenAnswer((_) async => const Right(tProduct));

    // Act
    await useCase.call(UpdateProductParams(sku: tSku));

    // Assert
    verify(() => mockRepository.updateProduct(
          sku: tSku,
          name: null,
          unitPrice: null,
          category: null,
          barcode: null,
        )).called(1);
  });

  test('should call updateProduct with only name when only name provided', () async {
    // Arrange
    when(() => mockRepository.updateProduct(
          sku: any(named: 'sku'),
          name: any(named: 'name'),
          unitPrice: any(named: 'unitPrice'),
          category: any(named: 'category'),
          barcode: any(named: 'barcode'),
        )).thenAnswer((_) async => const Right(tProduct));

    // Act
    await useCase.call(UpdateProductParams(
      sku: tSku,
      name: tName,
    ));

    // Assert
    verify(() => mockRepository.updateProduct(
          sku: tSku,
          name: tName,
          unitPrice: null,
          category: null,
          barcode: null,
        )).called(1);
  });

  test('should return Failure when update fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to update product');
    when(() => mockRepository.updateProduct(
          sku: any(named: 'sku'),
          name: any(named: 'name'),
          unitPrice: any(named: 'unitPrice'),
          category: any(named: 'category'),
          barcode: any(named: 'barcode'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(UpdateProductParams(
      sku: tSku,
      name: tName,
      unitPrice: tUnitPrice,
    ));

    // Assert
    expect(result, const Left(tFailure));
  });
}
