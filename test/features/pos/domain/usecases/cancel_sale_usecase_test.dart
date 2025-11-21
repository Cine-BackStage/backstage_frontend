import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/pos/domain/entities/sale.dart';
import 'package:backstage_frontend/features/pos/domain/repositories/pos_repository.dart';
import 'package:backstage_frontend/features/pos/domain/usecases/pos_usecases.dart';

class MockPosRepository extends Mock implements PosRepository {}

void main() {
  late CancelSaleUseCaseImpl useCase;
  late MockPosRepository mockRepository;

  setUp(() {
    mockRepository = MockPosRepository();
    useCase = CancelSaleUseCaseImpl(mockRepository);
  });

  const tSaleId = 'SALE001';
  final tSale = Sale(
    id: tSaleId,
    companyId: 'COMP001',
    cashierCpf: '123.456.789-00',
    createdAt: DateTime(2024, 1, 1),
    status: 'CANCELED',
    subtotal: 100.0,
    discountAmount: 0.0,
    grandTotal: 100.0,
    items: [],
    payments: [],
  );

  test('should call repository.cancelSale with correct saleId', () async {
    // Arrange
    when(() => mockRepository.cancelSale(any()))
        .thenAnswer((_) async => Right(tSale));

    // Act
    await useCase.call(CancelSaleParams(saleId: tSaleId));

    // Assert
    verify(() => mockRepository.cancelSale(tSaleId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return canceled Sale when call is successful', () async {
    // Arrange
    when(() => mockRepository.cancelSale(any()))
        .thenAnswer((_) async => Right(tSale));

    // Act
    final result = await useCase.call(CancelSaleParams(saleId: tSaleId));

    // Assert
    expect(result, Right(tSale));
    result.fold(
      (failure) => fail('Should not return failure'),
      (sale) => expect(sale.status, 'CANCELED'),
    );
  });

  test('should return Failure when cancellation fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to cancel sale');
    when(() => mockRepository.cancelSale(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(CancelSaleParams(saleId: tSaleId));

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should return Failure when sale is already finalized', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Cannot cancel finalized sale');
    when(() => mockRepository.cancelSale(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(CancelSaleParams(saleId: tSaleId));

    // Assert
    expect(result, const Left(tFailure));
  });
}
