import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ticket.dart';
import '../repositories/sessions_repository.dart';

abstract class ValidateTicketUseCase {
  Future<Either<Failure, Ticket>> call(ValidateTicketParams params);
}

class ValidateTicketUseCaseImpl implements ValidateTicketUseCase {
  final SessionsRepository repository;

  ValidateTicketUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Ticket>> call(ValidateTicketParams params) async {
    return await repository.validateTicket(params.ticketId);
  }
}

class ValidateTicketParams {
  final String ticketId;

  ValidateTicketParams({required this.ticketId});
}
