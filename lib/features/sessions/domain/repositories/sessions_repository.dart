import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/session.dart';
import '../entities/seat.dart';
import '../entities/ticket.dart';

abstract class SessionsRepository {
  Future<Either<Failure, List<Session>>> getSessions({
    DateTime? date,
    int? movieId,
    int? roomId,
  });

  Future<Either<Failure, Session>> getSessionDetails(String sessionId);

  Future<Either<Failure, List<Seat>>> getSessionSeats(String sessionId);

  Future<Either<Failure, List<Ticket>>> purchaseTickets({
    required String sessionId,
    required List<String> seatIds,
    required String customerCpf,
    String? customerName,
  });

  Future<Either<Failure, Ticket>> cancelTicket(String ticketId);

  Future<Either<Failure, Ticket>> validateTicket(String ticketId);

  Future<Either<Failure, List<Ticket>>> getTicketsBySession(String sessionId);

  // Session Management (CRUD)
  Future<Either<Failure, Session>> createSession({
    required String movieId,
    required String roomId,
    required DateTime startTime,
    double? basePrice,
  });

  Future<Either<Failure, Session>> updateSession({
    required String sessionId,
    String? movieId,
    String? roomId,
    DateTime? startTime,
    double? basePrice,
    String? status,
  });

  Future<Either<Failure, void>> deleteSession(String sessionId);
}
