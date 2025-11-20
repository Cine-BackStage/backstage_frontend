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
      print('📚 Sessions Repository: Getting sessions (date: $date, movieId: $movieId, roomId: $roomId)');
      final sessions = await remoteDataSource.getSessions(
        date: date,
        movieId: movieId,
        roomId: roomId,
      );
      print('✅ Sessions Repository: Fetched ${sessions.length} sessions');
      return Right(sessions.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      print('❌ Sessions Repository: DioException getting sessions - ${e.message}');
      print('❌ Sessions Repository: Status code: ${e.response?.statusCode}');
      print('❌ Sessions Repository: Response data: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e, stackTrace) {
      print('❌ Sessions Repository: Exception getting sessions - $e');
      print('❌ Sessions Repository: StackTrace: $stackTrace');
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Session>> getSessionDetails(String sessionId) async {
    try {
      print('📚 Sessions Repository: Getting session details: $sessionId');
      final session = await remoteDataSource.getSessionDetails(sessionId);
      print('✅ Sessions Repository: Session details fetched successfully');
      return Right(session.toEntity());
    } on DioException catch (e) {
      print('❌ Sessions Repository: DioException getting session details - ${e.message}');
      print('❌ Sessions Repository: Status code: ${e.response?.statusCode}');
      print('❌ Sessions Repository: Response data: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e, stackTrace) {
      print('❌ Sessions Repository: Exception getting session details - $e');
      print('❌ Sessions Repository: StackTrace: $stackTrace');
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Seat>>> getSessionSeats(String sessionId) async {
    try {
      print('📚 Sessions Repository: Getting seats for session: $sessionId');
      final seats = await remoteDataSource.getSessionSeats(sessionId);
      print('✅ Sessions Repository: Fetched ${seats.length} seats');
      return Right(seats.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      print('❌ Sessions Repository: DioException getting session seats - ${e.message}');
      print('❌ Sessions Repository: Status code: ${e.response?.statusCode}');
      print('❌ Sessions Repository: Response data: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e, stackTrace) {
      print('❌ Sessions Repository: Exception getting session seats - $e');
      print('❌ Sessions Repository: StackTrace: $stackTrace');
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
      print('📚 Sessions Repository: Purchasing tickets for session $sessionId');
      print('📚 Sessions Repository: Seats: ${seatIds.length}, Customer CPF: $customerCpf');
      final tickets = await remoteDataSource.purchaseTickets(
        sessionId: sessionId,
        seatIds: seatIds,
        customerCpf: customerCpf,
        customerName: customerName,
      );
      print('✅ Sessions Repository: ${tickets.length} tickets purchased successfully');
      return Right(tickets.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      print('❌ Sessions Repository: DioException purchasing tickets - ${e.message}');
      print('❌ Sessions Repository: Status code: ${e.response?.statusCode}');
      print('❌ Sessions Repository: Response data: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e, stackTrace) {
      print('❌ Sessions Repository: Exception purchasing tickets - $e');
      print('❌ Sessions Repository: StackTrace: $stackTrace');
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Ticket>> cancelTicket(String ticketId) async {
    try {
      print('📚 Sessions Repository: Cancelling ticket: $ticketId');
      final ticket = await remoteDataSource.cancelTicket(ticketId);
      print('✅ Sessions Repository: Ticket cancelled successfully');
      return Right(ticket.toEntity());
    } on DioException catch (e) {
      print('❌ Sessions Repository: DioException cancelling ticket - ${e.message}');
      print('❌ Sessions Repository: Status code: ${e.response?.statusCode}');
      print('❌ Sessions Repository: Response data: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e, stackTrace) {
      print('❌ Sessions Repository: Exception cancelling ticket - $e');
      print('❌ Sessions Repository: StackTrace: $stackTrace');
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Ticket>> validateTicket(String ticketId) async {
    try {
      print('📚 Sessions Repository: Validating ticket: $ticketId');
      final ticket = await remoteDataSource.validateTicket(ticketId);
      print('✅ Sessions Repository: Ticket validated successfully');
      return Right(ticket.toEntity());
    } on DioException catch (e) {
      print('❌ Sessions Repository: DioException validating ticket - ${e.message}');
      print('❌ Sessions Repository: Status code: ${e.response?.statusCode}');
      print('❌ Sessions Repository: Response data: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e, stackTrace) {
      print('❌ Sessions Repository: Exception validating ticket - $e');
      print('❌ Sessions Repository: StackTrace: $stackTrace');
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Ticket>>> getTicketsBySession(
      String sessionId) async {
    try {
      print('📚 Sessions Repository: Getting tickets for session: $sessionId');
      final tickets = await remoteDataSource.getTicketsBySession(sessionId);
      print('✅ Sessions Repository: Fetched ${tickets.length} tickets');
      return Right(tickets.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      print('❌ Sessions Repository: DioException getting tickets - ${e.message}');
      print('❌ Sessions Repository: Status code: ${e.response?.statusCode}');
      print('❌ Sessions Repository: Response data: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e, stackTrace) {
      print('❌ Sessions Repository: Exception getting tickets - $e');
      print('❌ Sessions Repository: StackTrace: $stackTrace');
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
      print('📚 Sessions Repository: Creating session');
      print('📚 Sessions Repository: Movie: $movieId, Room: $roomId, StartTime: $startTime, BasePrice: $basePrice');
      final session = await remoteDataSource.createSession(
        movieId: movieId,
        roomId: roomId,
        startTime: startTime,
        basePrice: basePrice,
      );
      print('✅ Sessions Repository: Session created successfully: ${session.id}');
      return Right(session.toEntity());
    } on DioException catch (e) {
      print('❌ Sessions Repository: DioException creating session - ${e.message}');
      print('❌ Sessions Repository: Status code: ${e.response?.statusCode}');
      print('❌ Sessions Repository: Response data: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e, stackTrace) {
      print('❌ Sessions Repository: Exception creating session - $e');
      print('❌ Sessions Repository: StackTrace: $stackTrace');
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
      print('📚 Sessions Repository: Updating session $sessionId');
      print('📚 Sessions Repository: Update data - movieId: $movieId, roomId: $roomId, startTime: $startTime, basePrice: $basePrice, status: $status');
      final session = await remoteDataSource.updateSession(
        sessionId: sessionId,
        movieId: movieId,
        roomId: roomId,
        startTime: startTime,
        basePrice: basePrice,
        status: status,
      );
      print('✅ Sessions Repository: Session updated successfully');
      return Right(session.toEntity());
    } on DioException catch (e) {
      print('❌ Sessions Repository: DioException updating session - ${e.message}');
      print('❌ Sessions Repository: Status code: ${e.response?.statusCode}');
      print('❌ Sessions Repository: Response data: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e, stackTrace) {
      print('❌ Sessions Repository: Exception updating session - $e');
      print('❌ Sessions Repository: StackTrace: $stackTrace');
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      print('📚 Sessions Repository: Deleting session $sessionId');
      await remoteDataSource.deleteSession(sessionId);
      print('✅ Sessions Repository: Session deleted successfully');
      return const Right(null);
    } on DioException catch (e) {
      print('❌ Sessions Repository: DioException deleting session - ${e.message}');
      print('❌ Sessions Repository: Status code: ${e.response?.statusCode}');
      print('❌ Sessions Repository: Response data: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e, stackTrace) {
      print('❌ Sessions Repository: Exception deleting session - $e');
      print('❌ Sessions Repository: StackTrace: $stackTrace');
      return Left(ErrorMapper.fromException(e));
    }
  }
}
