import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/pos/domain/entities/payment.dart';
import 'package:backstage_frontend/features/pos/domain/repositories/pos_repository.dart';
import 'package:backstage_frontend/features/pos/domain/usecases/pos_usecases.dart';

class MockPosRepository extends Mock implements PosRepository {}

void main() {
  late AddPaymentUseCaseImpl useCase;
  late MockPosRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(PaymentMethod.cash);
  });

  setUp(() {
    mockRepository = MockPosRepository();
    useCase = AddPaymentUseCaseImpl(mockRepository);
  });

  const tSaleId = 'SALE001';
  final tPayment = Payment(
    id: 'PAY001',
    saleId: tSaleId,
    method: PaymentMethod.cash,
    amount: 50.0,
    createdAt: DateTime(2024, 1, 1),
  );

  test('should call repository.addPayment with correct parameters', () async {
    // Arrange
    when(() => mockRepository.addPayment(
          saleId: any(named: 'saleId'),
          method: any(named: 'method'),
          amount: any(named: 'amount'),
          authCode: any(named: 'authCode'),
        )).thenAnswer((_) async => Right(tPayment));

    // Act
    await useCase.call(AddPaymentParams(
      saleId: tSaleId,
      method: PaymentMethod.cash,
      amount: 50.0,
    ));

    // Assert
    verify(() => mockRepository.addPayment(
          saleId: tSaleId,
          method: PaymentMethod.cash,
          amount: 50.0,
          authCode: null,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call repository with authCode for card payments', () async {
    // Arrange
    const authCode = 'AUTH123456';
    final tCardPayment = Payment(
      id: 'PAY002',
      saleId: tSaleId,
      method: PaymentMethod.card,
      amount: 100.0,
      authCode: authCode,
      createdAt: DateTime(2024, 1, 1),
    );

    when(() => mockRepository.addPayment(
          saleId: any(named: 'saleId'),
          method: any(named: 'method'),
          amount: any(named: 'amount'),
          authCode: any(named: 'authCode'),
        )).thenAnswer((_) async => Right(tCardPayment));

    // Act
    await useCase.call(AddPaymentParams(
      saleId: tSaleId,
      method: PaymentMethod.card,
      amount: 100.0,
      authCode: authCode,
    ));

    // Assert
    verify(() => mockRepository.addPayment(
          saleId: tSaleId,
          method: PaymentMethod.card,
          amount: 100.0,
          authCode: authCode,
        )).called(1);
  });

  test('should return Payment when addition is successful', () async {
    // Arrange
    when(() => mockRepository.addPayment(
          saleId: any(named: 'saleId'),
          method: any(named: 'method'),
          amount: any(named: 'amount'),
          authCode: any(named: 'authCode'),
        )).thenAnswer((_) async => Right(tPayment));

    // Act
    final result = await useCase.call(AddPaymentParams(
      saleId: tSaleId,
      method: PaymentMethod.cash,
      amount: 50.0,
    ));

    // Assert
    expect(result, Right(tPayment));
  });

  test('should return Failure when addition fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to add payment');
    when(() => mockRepository.addPayment(
          saleId: any(named: 'saleId'),
          method: any(named: 'method'),
          amount: any(named: 'amount'),
          authCode: any(named: 'authCode'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(AddPaymentParams(
      saleId: tSaleId,
      method: PaymentMethod.cash,
      amount: 50.0,
    ));

    // Assert
    expect(result, const Left(tFailure));
  });
}
