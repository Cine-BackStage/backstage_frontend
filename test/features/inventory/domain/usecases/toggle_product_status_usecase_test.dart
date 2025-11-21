import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/toggle_product_status_usecase.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late ToggleProductStatusUseCaseImpl useCase;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    useCase = ToggleProductStatusUseCaseImpl(mockRepository);
  });

  const tSku = 'SKU001';
  const tIsActive = false;

  test('should call repository.toggleProductStatus with correct parameters', () async {
    // Arrange
    when(() => mockRepository.toggleProductStatus(any(), any()))
        .thenAnswer((_) async => const Right(null));

    // Act
    await useCase.call(ToggleProductStatusParams(
      sku: tSku,
      isActive: tIsActive,
    ));

    // Assert
    verify(() => mockRepository.toggleProductStatus(tSku, tIsActive)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return success when toggle is successful', () async {
    // Arrange
    when(() => mockRepository.toggleProductStatus(any(), any()))
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase.call(ToggleProductStatusParams(
      sku: tSku,
      isActive: tIsActive,
    ));

    // Assert
    expect(result, const Right(null));
  });

  test('should toggle to active status', () async {
    // Arrange
    when(() => mockRepository.toggleProductStatus(any(), any()))
        .thenAnswer((_) async => const Right(null));

    // Act
    await useCase.call(ToggleProductStatusParams(
      sku: tSku,
      isActive: true,
    ));

    // Assert
    verify(() => mockRepository.toggleProductStatus(tSku, true)).called(1);
  });

  test('should return Failure when toggle fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to toggle product status');
    when(() => mockRepository.toggleProductStatus(any(), any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(ToggleProductStatusParams(
      sku: tSku,
      isActive: tIsActive,
    ));

    // Assert
    expect(result, const Left(tFailure));
  });
}
