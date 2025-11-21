import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/pos/domain/repositories/pos_repository.dart';
import 'package:backstage_frontend/features/pos/domain/usecases/pos_usecases.dart';

class MockPosRepository extends Mock implements PosRepository {}

void main() {
  late RemovePaymentUseCaseImpl useCase;
  late MockPosRepository mockRepository;

  setUp(() {
    mockRepository = MockPosRepository();
    useCase = RemovePaymentUseCaseImpl(mockRepository);
  });

  const tSaleId = 'SALE001';
  const tPaymentId = 'PAY001';

  test('should call repository.removePayment with correct parameters', () async {
    // Arrange
    when(() => mockRepository.removePayment(
          saleId: any(named: 'saleId'),
          paymentId: any(named: 'paymentId'),
        )).thenAnswer((_) async => const Right(null));

    // Act
    await useCase.call(RemovePaymentParams(
      saleId: tSaleId,
      paymentId: tPaymentId,
    ));

    // Assert
    verify(() => mockRepository.removePayment(
          saleId: tSaleId,
          paymentId: tPaymentId,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Right(null) when removal is successful', () async {
    // Arrange
    when(() => mockRepository.removePayment(
          saleId: any(named: 'saleId'),
          paymentId: any(named: 'paymentId'),
        )).thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase.call(RemovePaymentParams(
      saleId: tSaleId,
      paymentId: tPaymentId,
    ));

    // Assert
    expect(result, const Right(null));
  });

  test('should return Failure when removal fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to remove payment');
    when(() => mockRepository.removePayment(
          saleId: any(named: 'saleId'),
          paymentId: any(named: 'paymentId'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(RemovePaymentParams(
      saleId: tSaleId,
      paymentId: tPaymentId,
    ));

    // Assert
    expect(result, const Left(tFailure));
  });
}
