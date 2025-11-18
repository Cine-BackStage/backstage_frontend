import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/session.dart';
import '../repositories/sessions_repository.dart';

abstract class UpdateSessionUseCase {
  Future<Either<Failure, Session>> call(UpdateSessionParams params);
}

class UpdateSessionUseCaseImpl implements UpdateSessionUseCase {
  final SessionsRepository repository;

  UpdateSessionUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Session>> call(UpdateSessionParams params) async {
    return await repository.updateSession(
      sessionId: params.sessionId,
      movieId: params.movieId,
      roomId: params.roomId,
      startTime: params.startTime,
      basePrice: params.basePrice,
      status: params.status,
    );
  }
}

class UpdateSessionParams {
  final String sessionId;
  final String? movieId;
  final String? roomId;
  final DateTime? startTime;
  final double? basePrice;
  final String? status;

  UpdateSessionParams({
    required this.sessionId,
    this.movieId,
    this.roomId,
    this.startTime,
    this.basePrice,
    this.status,
  });
}
