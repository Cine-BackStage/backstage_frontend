import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/session.dart';
import '../repositories/sessions_repository.dart';

abstract class GetSessionDetailsUseCase {
  Future<Either<Failure, Session>> call(GetSessionDetailsParams params);
}

class GetSessionDetailsUseCaseImpl implements GetSessionDetailsUseCase {
  final SessionsRepository repository;

  GetSessionDetailsUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Session>> call(GetSessionDetailsParams params) async {
    return await repository.getSessionDetails(params.sessionId);
  }
}

class GetSessionDetailsParams {
  final String sessionId;

  GetSessionDetailsParams({required this.sessionId});
}
