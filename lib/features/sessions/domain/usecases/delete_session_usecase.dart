import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/sessions_repository.dart';

abstract class DeleteSessionUseCase {
  Future<Either<Failure, void>> call(DeleteSessionParams params);
}

class DeleteSessionUseCaseImpl implements DeleteSessionUseCase {
  final SessionsRepository repository;

  DeleteSessionUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteSessionParams params) async {
    return await repository.deleteSession(params.sessionId);
  }
}

class DeleteSessionParams {
  final String sessionId;

  DeleteSessionParams({required this.sessionId});
}
