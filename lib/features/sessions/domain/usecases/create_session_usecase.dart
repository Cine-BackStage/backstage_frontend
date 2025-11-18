import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/session.dart';
import '../repositories/sessions_repository.dart';

abstract class CreateSessionUseCase {
  Future<Either<Failure, Session>> call(CreateSessionParams params);
}

class CreateSessionUseCaseImpl implements CreateSessionUseCase {
  final SessionsRepository repository;

  CreateSessionUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Session>> call(CreateSessionParams params) async {
    return await repository.createSession(
      movieId: params.movieId,
      roomId: params.roomId,
      startTime: params.startTime,
      basePrice: params.basePrice,
    );
  }
}

class CreateSessionParams {
  final String movieId;
  final String roomId;
  final DateTime startTime;
  final double? basePrice;

  CreateSessionParams({
    required this.movieId,
    required this.roomId,
    required this.startTime,
    this.basePrice,
  });
}
