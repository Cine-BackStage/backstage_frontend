import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/pos/domain/entities/sale.dart';
import 'package:backstage_frontend/features/pos/domain/repositories/pos_repository.dart';
import 'package:backstage_frontend/features/pos/domain/usecases/pos_usecases.dart';

class MockPosRepository extends Mock implements PosRepository {}

void main() {
  late GetSaleUseCaseImpl useCase;
  late MockPosRepository mockRepository;

  setUp(() {
    mockRepository = MockPosRepository();
    useCase = GetSaleUseCaseImpl(mockRepository);
  });

  const tSaleId = 'SALE001';
  final tSale = Sale(
    id: tSaleId,
    companyId: 'COMP001',
    cashierCpf: '123.456.789-00',
    createdAt: DateTime(2024, 1, 1),
    status: 'OPEN',
    subtotal: 50.0,
    discountAmount: 0.0,
    grandTotal: 50.0,
    items: [],
    payments: [],
  );

  test('should call repository.getSaleById with correct saleId', () async {
    // Arrange
    when(() => mockRepository.getSaleById(any()))
        .thenAnswer((_) async => Right(tSale));

    // Act
    await useCase.call(GetSaleParams(saleId: tSaleId));

    // Assert
    verify(() => mockRepository.getSaleById(tSaleId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Sale when call is successful', () async {
    // Arrange
    when(() => mockRepository.getSaleById(any()))
        .thenAnswer((_) async => Right(tSale));

    // Act
    final result = await useCase.call(GetSaleParams(saleId: tSaleId));

    // Assert
    expect(result, Right(tSale));
  });

  test('should return Failure when sale not found', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Sale not found');
    when(() => mockRepository.getSaleById(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(GetSaleParams(saleId: tSaleId));

    // Assert
    expect(result, const Left(tFailure));
  });
}
