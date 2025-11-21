import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/sessions/domain/entities/ticket.dart';
import 'package:backstage_frontend/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:backstage_frontend/features/sessions/domain/usecases/purchase_tickets_usecase.dart';

class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late PurchaseTicketsUseCaseImpl useCase;
  late MockSessionsRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionsRepository();
    useCase = PurchaseTicketsUseCaseImpl(mockRepository);
  });

  final tDateTime = DateTime(2024, 1, 15, 10, 0);
  const tSessionId = 'session-1';
  const tSeatIds = ['seat-1', 'seat-2'];
  const tCustomerCpf = '12345678901';
  const tCustomerName = 'John Doe';
  final tTicket = Ticket(
    id: 'ticket-1',
    ticketNumber: 'TKT-001',
    sessionId: tSessionId,
    seatId: 'seat-1',
    seatNumber: 'A1',
    customerCpf: tCustomerCpf,
    price: 25.0,
    status: 'ACTIVE',
    purchasedAt: tDateTime,
    customerName: tCustomerName,
  );

  test('should call repository.purchaseTickets with correct parameters', () async {
    // Arrange
    when(() => mockRepository.purchaseTickets(
          sessionId: any(named: 'sessionId'),
          seatIds: any(named: 'seatIds'),
          customerCpf: any(named: 'customerCpf'),
          customerName: any(named: 'customerName'),
        )).thenAnswer((_) async => Right([tTicket]));

    // Act
    await useCase.call(PurchaseTicketsParams(
      sessionId: tSessionId,
      seatIds: tSeatIds,
      customerCpf: tCustomerCpf,
      customerName: tCustomerName,
    ));

    // Assert
    verify(() => mockRepository.purchaseTickets(
          sessionId: tSessionId,
          seatIds: tSeatIds,
          customerCpf: tCustomerCpf,
          customerName: tCustomerName,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return list of tickets when purchase is successful', () async {
    // Arrange
    final tTickets = [tTicket];
    when(() => mockRepository.purchaseTickets(
          sessionId: any(named: 'sessionId'),
          seatIds: any(named: 'seatIds'),
          customerCpf: any(named: 'customerCpf'),
          customerName: any(named: 'customerName'),
        )).thenAnswer((_) async => Right(tTickets));

    // Act
    final result = await useCase.call(PurchaseTicketsParams(
      sessionId: tSessionId,
      seatIds: tSeatIds,
      customerCpf: tCustomerCpf,
      customerName: tCustomerName,
    ));

    // Assert
    expect(result, Right(tTickets));
  });

  test('should return Failure when seatIds is empty', () async {
    // Act
    final result = await useCase.call(PurchaseTicketsParams(
      sessionId: tSessionId,
      seatIds: [],
      customerCpf: tCustomerCpf,
      customerName: tCustomerName,
    ));

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<GenericFailure>());
        expect(failure.message, 'Selecione pelo menos um assento');
      },
      (tickets) => fail('Should not return success'),
    );
    verifyNever(() => mockRepository.purchaseTickets(
          sessionId: any(named: 'sessionId'),
          seatIds: any(named: 'seatIds'),
          customerCpf: any(named: 'customerCpf'),
          customerName: any(named: 'customerName'),
        ));
  });

  test('should return Failure when CPF is invalid (not 11 digits)', () async {
    // Act
    final result = await useCase.call(PurchaseTicketsParams(
      sessionId: tSessionId,
      seatIds: tSeatIds,
      customerCpf: '123456789', // Only 9 digits
      customerName: tCustomerName,
    ));

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<GenericFailure>());
        expect(failure.message, 'CPF inválido');
      },
      (tickets) => fail('Should not return success'),
    );
    verifyNever(() => mockRepository.purchaseTickets(
          sessionId: any(named: 'sessionId'),
          seatIds: any(named: 'seatIds'),
          customerCpf: any(named: 'customerCpf'),
          customerName: any(named: 'customerName'),
        ));
  });

  test('should return Failure when repository call fails', () async {
    // Arrange
    final tFailure = GenericFailure(message: 'Failed to purchase tickets');
    when(() => mockRepository.purchaseTickets(
          sessionId: any(named: 'sessionId'),
          seatIds: any(named: 'seatIds'),
          customerCpf: any(named: 'customerCpf'),
          customerName: any(named: 'customerName'),
        )).thenAnswer((_) async => Left(tFailure));

    // Act
    final result = await useCase.call(PurchaseTicketsParams(
      sessionId: tSessionId,
      seatIds: tSeatIds,
      customerCpf: tCustomerCpf,
      customerName: tCustomerName,
    ));

    // Assert
    expect(result, Left(tFailure));
  });

  test('should call repository with null customerName when not provided', () async {
    // Arrange
    when(() => mockRepository.purchaseTickets(
          sessionId: any(named: 'sessionId'),
          seatIds: any(named: 'seatIds'),
          customerCpf: any(named: 'customerCpf'),
          customerName: any(named: 'customerName'),
        )).thenAnswer((_) async => Right([tTicket]));

    // Act
    await useCase.call(PurchaseTicketsParams(
      sessionId: tSessionId,
      seatIds: tSeatIds,
      customerCpf: tCustomerCpf,
    ));

    // Assert
    verify(() => mockRepository.purchaseTickets(
          sessionId: tSessionId,
          seatIds: tSeatIds,
          customerCpf: tCustomerCpf,
          customerName: null,
        )).called(1);
  });
}
