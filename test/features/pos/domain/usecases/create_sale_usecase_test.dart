import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/pos/domain/entities/sale.dart';
import 'package:backstage_frontend/features/pos/domain/repositories/pos_repository.dart';
import 'package:backstage_frontend/features/pos/domain/usecases/pos_usecases.dart';

class MockPosRepository extends Mock implements PosRepository {}

void main() {
  late CreateSaleUseCaseImpl useCase;
  late MockPosRepository mockRepository;

  setUp(() {
    mockRepository = MockPosRepository();
    useCase = CreateSaleUseCaseImpl(mockRepository);
  });

  final tSale = Sale(
    id: 'SALE001',
    companyId: 'COMP001',
    cashierCpf: '123.456.789-00',
    buyerCpf: '987.654.321-00',
    createdAt: DateTime(2024, 1, 1),
    status: 'OPEN',
    subtotal: 0.0,
    discountAmount: 0.0,
    grandTotal: 0.0,
    items: [],
    payments: [],
  );

  test('should call repository.createSale with correct parameters', () async {
    // Arrange
    const buyerCpf = '987.654.321-00';
    when(() => mockRepository.createSale(buyerCpf: any(named: 'buyerCpf')))
        .thenAnswer((_) async => Right(tSale));

    // Act
    await useCase.call(CreateSaleParams(buyerCpf: buyerCpf));

    // Assert
    verify(() => mockRepository.createSale(buyerCpf: buyerCpf)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Sale when creation is successful', () async {
    // Arrange
    when(() => mockRepository.createSale(buyerCpf: any(named: 'buyerCpf')))
        .thenAnswer((_) async => Right(tSale));

    // Act
    final result = await useCase.call(CreateSaleParams(buyerCpf: '987.654.321-00'));

    // Assert
    expect(result, Right(tSale));
  });

  test('should return Sale when creation without buyerCpf is successful', () async {
    // Arrange
    when(() => mockRepository.createSale(buyerCpf: any(named: 'buyerCpf')))
        .thenAnswer((_) async => Right(tSale));

    // Act
    final result = await useCase.call(CreateSaleParams());

    // Assert
    expect(result, Right(tSale));
  });

  test('should return Failure when creation fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to create sale');
    when(() => mockRepository.createSale(buyerCpf: any(named: 'buyerCpf')))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(CreateSaleParams(buyerCpf: '987.654.321-00'));

    // Assert
    expect(result, const Left(tFailure));
  });
}
