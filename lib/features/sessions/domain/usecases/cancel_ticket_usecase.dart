import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ticket.dart';
import '../repositories/sessions_repository.dart';

abstract class CancelTicketUseCase {
  Future<Either<Failure, Ticket>> call(CancelTicketParams params);
}

class CancelTicketUseCaseImpl implements CancelTicketUseCase {
  final SessionsRepository repository;

  CancelTicketUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Ticket>> call(CancelTicketParams params) async {
    return await repository.cancelTicket(params.ticketId);
  }
}

class CancelTicketParams {
  final String ticketId;

  CancelTicketParams({required this.ticketId});
}
