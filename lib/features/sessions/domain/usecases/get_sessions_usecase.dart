import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/session.dart';
import '../repositories/sessions_repository.dart';

abstract class GetSessionsUseCase {
  Future<Either<Failure, List<Session>>> call(GetSessionsParams params);
}

class GetSessionsUseCaseImpl implements GetSessionsUseCase {
  final SessionsRepository repository;

  GetSessionsUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, List<Session>>> call(GetSessionsParams params) async {
    return await repository.getSessions(
      date: params.date,
      movieId: params.movieId,
      roomId: params.roomId,
    );
  }
}

class GetSessionsParams {
  final DateTime? date;
  final int? movieId;
  final int? roomId;

  GetSessionsParams({
    this.date,
    this.movieId,
    this.roomId,
  });
}
