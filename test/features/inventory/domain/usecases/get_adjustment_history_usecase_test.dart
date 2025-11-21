import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:backstage_frontend/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/get_adjustment_history_usecase.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late GetAdjustmentHistoryUseCaseImpl useCase;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = GetAdjustmentHistoryUseCaseImpl(mockRepository);
  });

  final tAdjustment = StockAdjustment(
    id: 'adj-1',
    sku: 'SKU001',
    productName: 'Popcorn',
    type: AdjustmentType.addition,
    quantityBefore: 100,
    quantityAfter: 110,
    quantityChanged: 10,
    reason: 'Restock',
    notes: 'New shipment arrived',
    employeeName: 'John Doe',
    timestamp: DateTime(2024, 1, 1, 10, 0),
  );
  final tAdjustments = [tAdjustment];

  const tSku = 'SKU001';
  const tLimit = 20;

  test('should call repository.getAdjustmentHistory with correct parameters', () async {
    // Arrange
    when(() => mockRepository.getAdjustmentHistory(
          sku: any(named: 'sku'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => Right(tAdjustments));

    // Act
    await useCase.call(GetAdjustmentHistoryParams(
      sku: tSku,
      limit: tLimit,
    ));

    // Assert
    verify(() => mockRepository.getAdjustmentHistory(
          sku: tSku,
          limit: tLimit,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return list of StockAdjustments when successful', () async {
    // Arrange
    when(() => mockRepository.getAdjustmentHistory(
          sku: any(named: 'sku'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => Right(tAdjustments));

    // Act
    final result = await useCase.call(GetAdjustmentHistoryParams(
      sku: tSku,
      limit: tLimit,
    ));

    // Assert
    expect(result, Right(tAdjustments));
  });

  test('should call getAdjustmentHistory with default limit when not provided', () async {
    // Arrange
    when(() => mockRepository.getAdjustmentHistory(
          sku: any(named: 'sku'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => Right(tAdjustments));

    // Act
    await useCase.call(GetAdjustmentHistoryParams(sku: tSku));

    // Assert
    verify(() => mockRepository.getAdjustmentHistory(
          sku: tSku,
          limit: 50,
        )).called(1);
  });

  test('should call getAdjustmentHistory with null sku for all products', () async {
    // Arrange
    when(() => mockRepository.getAdjustmentHistory(
          sku: any(named: 'sku'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => Right(tAdjustments));

    // Act
    await useCase.call(GetAdjustmentHistoryParams(limit: 30));

    // Assert
    verify(() => mockRepository.getAdjustmentHistory(
          sku: null,
          limit: 30,
        )).called(1);
  });

  test('should return Failure when repository fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to fetch adjustment history');
    when(() => mockRepository.getAdjustmentHistory(
          sku: any(named: 'sku'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(GetAdjustmentHistoryParams(
      sku: tSku,
      limit: tLimit,
    ));

    // Assert
    expect(result, const Left(tFailure));
  });
}
