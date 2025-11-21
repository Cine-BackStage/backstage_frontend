import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/pos/domain/repositories/pos_repository.dart';
import 'package:backstage_frontend/features/pos/domain/usecases/pos_usecases.dart';

class MockPosRepository extends Mock implements PosRepository {}

void main() {
  late ValidateDiscountUseCaseImpl useCase;
  late MockPosRepository mockRepository;

  setUp(() {
    mockRepository = MockPosRepository();
    useCase = ValidateDiscountUseCaseImpl(mockRepository);
  });

  const tCode = 'DISCOUNT10';
  const tSubtotal = 100.0;
  final tDiscountData = {
    'code': tCode,
    'discountAmount': 10.0,
    'type': 'PERCENTAGE',
    'value': 10.0,
  };

  test('should call repository.validateDiscount with correct parameters', () async {
    // Arrange
    when(() => mockRepository.validateDiscount(
          code: any(named: 'code'),
          subtotal: any(named: 'subtotal'),
        )).thenAnswer((_) async => Right(tDiscountData));

    // Act
    await useCase.call(ValidateDiscountParams(
      code: tCode,
      subtotal: tSubtotal,
    ));

    // Assert
    verify(() => mockRepository.validateDiscount(
          code: tCode,
          subtotal: tSubtotal,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return discount data when validation is successful', () async {
    // Arrange
    when(() => mockRepository.validateDiscount(
          code: any(named: 'code'),
          subtotal: any(named: 'subtotal'),
        )).thenAnswer((_) async => Right(tDiscountData));

    // Act
    final result = await useCase.call(ValidateDiscountParams(
      code: tCode,
      subtotal: tSubtotal,
    ));

    // Assert
    expect(result, Right(tDiscountData));
  });

  test('should return Failure when discount code is invalid', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Invalid discount code');
    when(() => mockRepository.validateDiscount(
          code: any(named: 'code'),
          subtotal: any(named: 'subtotal'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(ValidateDiscountParams(
      code: tCode,
      subtotal: tSubtotal,
    ));

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should return Failure when discount code is expired', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Discount code expired');
    when(() => mockRepository.validateDiscount(
          code: any(named: 'code'),
          subtotal: any(named: 'subtotal'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(ValidateDiscountParams(
      code: 'EXPIRED',
      subtotal: tSubtotal,
    ));

    // Assert
    expect(result, const Left(tFailure));
  });
}
