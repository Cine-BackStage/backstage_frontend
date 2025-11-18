import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ticket.dart';
import '../repositories/sessions_repository.dart';

abstract class PurchaseTicketsUseCase {
  Future<Either<Failure, List<Ticket>>> call(PurchaseTicketsParams params);
}

class PurchaseTicketsUseCaseImpl implements PurchaseTicketsUseCase {
  final SessionsRepository repository;

  PurchaseTicketsUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, List<Ticket>>> call(
      PurchaseTicketsParams params) async {
    // Validate input
    if (params.seatIds.isEmpty) {
      return Left(GenericFailure(
        message: 'Selecione pelo menos um assento',
      ));
    }

    if (params.customerCpf.length != 11) {
      return Left(GenericFailure(
        message: 'CPF inválido',
      ));
    }

    return await repository.purchaseTickets(
      sessionId: params.sessionId,
      seatIds: params.seatIds,
      customerCpf: params.customerCpf,
      customerName: params.customerName,
    );
  }
}

class PurchaseTicketsParams {
  final String sessionId;
  final List<String> seatIds;
  final String customerCpf;
  final String? customerName;

  PurchaseTicketsParams({
    required this.sessionId,
    required this.seatIds,
    required this.customerCpf,
    this.customerName,
  });
}
