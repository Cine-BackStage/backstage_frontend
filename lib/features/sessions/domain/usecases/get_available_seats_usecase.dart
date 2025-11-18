import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/seat.dart';
import '../repositories/sessions_repository.dart';

abstract class GetAvailableSeatsUseCase {
  Future<Either<Failure, List<Seat>>> call(GetAvailableSeatsParams params);
}

class GetAvailableSeatsUseCaseImpl implements GetAvailableSeatsUseCase {
  final SessionsRepository repository;

  GetAvailableSeatsUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, List<Seat>>> call(
      GetAvailableSeatsParams params) async {
    return await repository.getSessionSeats(params.sessionId);
  }
}

class GetAvailableSeatsParams {
  final String sessionId;

  GetAvailableSeatsParams({required this.sessionId});
}
