import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/sessions/domain/entities/ticket.dart';
import 'package:backstage_frontend/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:backstage_frontend/features/sessions/domain/usecases/cancel_ticket_usecase.dart';

class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late CancelTicketUseCaseImpl useCase;
  late MockSessionsRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionsRepository();
    useCase = CancelTicketUseCaseImpl(mockRepository);
  });

  final tDateTime = DateTime(2024, 1, 15, 10, 0);
  const tTicketId = 'ticket-1';
  final tTicket = Ticket(
    id: tTicketId,
    ticketNumber: 'TKT-001',
    sessionId: 'session-1',
    seatId: 'seat-1',
    seatNumber: 'A1',
    customerCpf: '12345678901',
    price: 25.0,
    status: 'CANCELED',
    purchasedAt: tDateTime,
    canceledAt: tDateTime.add(Duration(minutes: 30)),
  );

  test('should call repository.cancelTicket with correct ticketId', () async {
    // Arrange
    when(() => mockRepository.cancelTicket(any()))
        .thenAnswer((_) async => Right(tTicket));

    // Act
    await useCase.call(CancelTicketParams(ticketId: tTicketId));

    // Assert
    verify(() => mockRepository.cancelTicket(tTicketId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return canceled Ticket when call is successful', () async {
    // Arrange
    when(() => mockRepository.cancelTicket(any()))
        .thenAnswer((_) async => Right(tTicket));

    // Act
    final result = await useCase.call(CancelTicketParams(ticketId: tTicketId));

    // Assert
    expect(result, Right(tTicket));
  });

  test('should return Failure when repository call fails', () async {
    // Arrange
    final tFailure = GenericFailure(message: 'Failed to cancel ticket');
    when(() => mockRepository.cancelTicket(any()))
        .thenAnswer((_) async => Left(tFailure));

    // Act
    final result = await useCase.call(CancelTicketParams(ticketId: tTicketId));

    // Assert
    expect(result, Left(tFailure));
  });
}
