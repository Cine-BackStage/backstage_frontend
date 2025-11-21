import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/adjust_stock_usecase.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late AdjustStockUseCaseImpl useCase;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = AdjustStockUseCaseImpl(mockRepository);
  });

  const tSku = 'SKU001';
  const tQuantity = 10;
  const tReason = 'Reestoque';
  const tNotes = 'Adding stock from new shipment';

  test('should call repository.adjustStock with correct parameters', () async {
    // Arrange
    when(() => mockRepository.adjustStock(
          sku: any(named: 'sku'),
          quantity: any(named: 'quantity'),
          reason: any(named: 'reason'),
          notes: any(named: 'notes'),
        )).thenAnswer((_) async => const Right(null));

    // Act
    await useCase.call(AdjustStockParams(
      sku: tSku,
      quantity: tQuantity,
      reason: tReason,
      notes: tNotes,
    ));

    // Assert
    verify(() => mockRepository.adjustStock(
          sku: tSku,
          quantity: tQuantity,
          reason: tReason,
          notes: tNotes,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return success when adjustment is successful', () async {
    // Arrange
    when(() => mockRepository.adjustStock(
          sku: any(named: 'sku'),
          quantity: any(named: 'quantity'),
          reason: any(named: 'reason'),
          notes: any(named: 'notes'),
        )).thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase.call(AdjustStockParams(
      sku: tSku,
      quantity: tQuantity,
      reason: tReason,
      notes: tNotes,
    ));

    // Assert
    expect(result, const Right(null));
  });

  test('should call adjustStock without notes when not provided', () async {
    // Arrange
    when(() => mockRepository.adjustStock(
          sku: any(named: 'sku'),
          quantity: any(named: 'quantity'),
          reason: any(named: 'reason'),
          notes: any(named: 'notes'),
        )).thenAnswer((_) async => const Right(null));

    // Act
    await useCase.call(AdjustStockParams(
      sku: tSku,
      quantity: tQuantity,
      reason: tReason,
    ));

    // Assert
    verify(() => mockRepository.adjustStock(
          sku: tSku,
          quantity: tQuantity,
          reason: tReason,
          notes: null,
        )).called(1);
  });

  test('should return Failure when adjustment fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to adjust stock');
    when(() => mockRepository.adjustStock(
          sku: any(named: 'sku'),
          quantity: any(named: 'quantity'),
          reason: any(named: 'reason'),
          notes: any(named: 'notes'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(AdjustStockParams(
      sku: tSku,
      quantity: tQuantity,
      reason: tReason,
      notes: tNotes,
    ));

    // Assert
    expect(result, const Left(tFailure));
  });
}
