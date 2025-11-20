import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../datasources/sessions_remote_datasource.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  final SessionsRemoteDataSource remoteDataSource;

  SessionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Session>>> getSessions({
    DateTime? date,
    int? movieId,
    int? roomId,
  }) async {
    try {
      final sessions = await remoteDataSource.getSessions(
        date: date,
        movieId: movieId,
        roomId: roomId,
      );
      return Right(sessions.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Session>> getSessionDetails(String sessionId) async {
    try {
      final session = await remoteDataSource.getSessionDetails(sessionId);
      return Right(session.toEntity());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Seat>>> getSessionSeats(String sessionId) async {
    try {
      final seats = await remoteDataSource.getSessionSeats(sessionId);
      return Right(seats.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Ticket>>> purchaseTickets({
    required String sessionId,
    required List<String> seatIds,
    required String customerCpf,
    String? customerName,
  }) async {
    try {
      final tickets = await remoteDataSource.purchaseTickets(
        sessionId: sessionId,
        seatIds: seatIds,
        customerCpf: customerCpf,
        customerName: customerName,
      );
      return Right(tickets.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Ticket>> cancelTicket(String ticketId) async {
    try {
      final ticket = await remoteDataSource.cancelTicket(ticketId);
      return Right(ticket.toEntity());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Ticket>> validateTicket(String ticketId) async {
    try {
      final ticket = await remoteDataSource.validateTicket(ticketId);
      return Right(ticket.toEntity());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Ticket>>> getTicketsBySession(
      String sessionId) async {
    try {
      final tickets = await remoteDataSource.getTicketsBySession(sessionId);
      return Right(tickets.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Session>> createSession({
    required String movieId,
    required String roomId,
    required DateTime startTime,
    double? basePrice,
  }) async {
    try {
      final session = await remoteDataSource.createSession(
        movieId: movieId,
        roomId: roomId,
        startTime: startTime,
        basePrice: basePrice,
      );
      return Right(session.toEntity());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Session>> updateSession({
    required String sessionId,
    String? movieId,
    String? roomId,
    DateTime? startTime,
    double? basePrice,
    String? status,
  }) async {
    try {
      final session = await remoteDataSource.updateSession(
        sessionId: sessionId,
        movieId: movieId,
        roomId: roomId,
        startTime: startTime,
        basePrice: basePrice,
        status: status,
      );
      return Right(session.toEntity());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      await remoteDataSource.deleteSession(sessionId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }
}
