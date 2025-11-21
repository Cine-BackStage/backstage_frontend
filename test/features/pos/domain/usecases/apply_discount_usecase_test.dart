import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/pos/domain/entities/sale.dart';
import 'package:backstage_frontend/features/pos/domain/repositories/pos_repository.dart';
import 'package:backstage_frontend/features/pos/domain/usecases/pos_usecases.dart';

class MockPosRepository extends Mock implements PosRepository {}

void main() {
  late ApplyDiscountUseCaseImpl useCase;
  late MockPosRepository mockRepository;

  setUp(() {
    mockRepository = MockPosRepository();
    useCase = ApplyDiscountUseCaseImpl(mockRepository);
  });

  const tSaleId = 'SALE001';
  const tCode = 'DISCOUNT10';
  final tSale = Sale(
    id: tSaleId,
    companyId: 'COMP001',
    cashierCpf: '123.456.789-00',
    createdAt: DateTime(2024, 1, 1),
    status: 'OPEN',
    subtotal: 100.0,
    discountAmount: 10.0,
    grandTotal: 90.0,
    items: [],
    payments: [],
    discountCode: tCode,
  );

  test('should call repository.applyDiscount with correct parameters', () async {
    // Arrange
    when(() => mockRepository.applyDiscount(
          saleId: any(named: 'saleId'),
          code: any(named: 'code'),
        )).thenAnswer((_) async => Right(tSale));

    // Act
    await useCase.call(ApplyDiscountParams(
      saleId: tSaleId,
      code: tCode,
    ));

    // Assert
    verify(() => mockRepository.applyDiscount(
          saleId: tSaleId,
          code: tCode,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return updated Sale when discount is applied successfully', () async {
    // Arrange
    when(() => mockRepository.applyDiscount(
          saleId: any(named: 'saleId'),
          code: any(named: 'code'),
        )).thenAnswer((_) async => Right(tSale));

    // Act
    final result = await useCase.call(ApplyDiscountParams(
      saleId: tSaleId,
      code: tCode,
    ));

    // Assert
    expect(result, Right(tSale));
    result.fold(
      (failure) => fail('Should not return failure'),
      (sale) {
        expect(sale.discountAmount, 10.0);
        expect(sale.discountCode, tCode);
        expect(sale.grandTotal, 90.0);
      },
    );
  });

  test('should return Failure when applying discount fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to apply discount');
    when(() => mockRepository.applyDiscount(
          saleId: any(named: 'saleId'),
          code: any(named: 'code'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(ApplyDiscountParams(
      saleId: tSaleId,
      code: tCode,
    ));

    // Assert
    expect(result, const Left(tFailure));
  });
}
