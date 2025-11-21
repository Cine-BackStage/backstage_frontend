import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/pos/domain/entities/sale_item.dart';
import 'package:backstage_frontend/features/pos/domain/repositories/pos_repository.dart';
import 'package:backstage_frontend/features/pos/domain/usecases/pos_usecases.dart';

class MockPosRepository extends Mock implements PosRepository {}

void main() {
  late AddItemToSaleUseCaseImpl useCase;
  late MockPosRepository mockRepository;

  setUp(() {
    mockRepository = MockPosRepository();
    useCase = AddItemToSaleUseCaseImpl(mockRepository);
  });

  final tSaleItem = SaleItem(
    id: 'ITEM001',
    saleId: 'SALE001',
    sku: 'SKU001',
    description: 'Popcorn',
    quantity: 2,
    unitPrice: 15.0,
    totalPrice: 30.0,
    createdAt: DateTime(2024, 1, 1),
  );

  test('should call repository.addItemToSale with correct parameters', () async {
    // Arrange
    final params = AddItemParams(
      saleId: 'SALE001',
      sku: 'SKU001',
      description: 'Popcorn',
      quantity: 2,
      unitPrice: 15.0,
    );

    when(() => mockRepository.addItemToSale(
          saleId: any(named: 'saleId'),
          sku: any(named: 'sku'),
          sessionId: any(named: 'sessionId'),
          seatId: any(named: 'seatId'),
          description: any(named: 'description'),
          quantity: any(named: 'quantity'),
          unitPrice: any(named: 'unitPrice'),
        )).thenAnswer((_) async => Right(tSaleItem));

    // Act
    await useCase.call(params);

    // Assert
    verify(() => mockRepository.addItemToSale(
          saleId: 'SALE001',
          sku: 'SKU001',
          sessionId: null,
          seatId: null,
          description: 'Popcorn',
          quantity: 2,
          unitPrice: 15.0,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call repository with session and seat ids for ticket items', () async {
    // Arrange
    final params = AddItemParams(
      saleId: 'SALE001',
      sessionId: 'SESSION001',
      seatId: 'SEAT001',
      description: 'Movie Ticket',
      quantity: 1,
      unitPrice: 25.0,
    );

    when(() => mockRepository.addItemToSale(
          saleId: any(named: 'saleId'),
          sku: any(named: 'sku'),
          sessionId: any(named: 'sessionId'),
          seatId: any(named: 'seatId'),
          description: any(named: 'description'),
          quantity: any(named: 'quantity'),
          unitPrice: any(named: 'unitPrice'),
        )).thenAnswer((_) async => Right(tSaleItem));

    // Act
    await useCase.call(params);

    // Assert
    verify(() => mockRepository.addItemToSale(
          saleId: 'SALE001',
          sku: null,
          sessionId: 'SESSION001',
          seatId: 'SEAT001',
          description: 'Movie Ticket',
          quantity: 1,
          unitPrice: 25.0,
        )).called(1);
  });

  test('should return SaleItem when addition is successful', () async {
    // Arrange
    final params = AddItemParams(
      saleId: 'SALE001',
      sku: 'SKU001',
      description: 'Popcorn',
      quantity: 2,
      unitPrice: 15.0,
    );

    when(() => mockRepository.addItemToSale(
          saleId: any(named: 'saleId'),
          sku: any(named: 'sku'),
          sessionId: any(named: 'sessionId'),
          seatId: any(named: 'seatId'),
          description: any(named: 'description'),
          quantity: any(named: 'quantity'),
          unitPrice: any(named: 'unitPrice'),
        )).thenAnswer((_) async => Right(tSaleItem));

    // Act
    final result = await useCase.call(params);

    // Assert
    expect(result, Right(tSaleItem));
  });

  test('should return Failure when addition fails', () async {
    // Arrange
    final params = AddItemParams(
      saleId: 'SALE001',
      sku: 'SKU001',
      description: 'Popcorn',
      quantity: 2,
      unitPrice: 15.0,
    );

    const tFailure = GenericFailure(message: 'Failed to add item');
    when(() => mockRepository.addItemToSale(
          saleId: any(named: 'saleId'),
          sku: any(named: 'sku'),
          sessionId: any(named: 'sessionId'),
          seatId: any(named: 'seatId'),
          description: any(named: 'description'),
          quantity: any(named: 'quantity'),
          unitPrice: any(named: 'unitPrice'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(params);

    // Assert
    expect(result, const Left(tFailure));
  });
}
