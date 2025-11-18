import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/seat.dart';

/// UseCase for calculating total ticket price
abstract class CalculateTicketPriceUseCase {
  Either<Failure, double> call(CalculateTicketPriceParams params);
}

class CalculateTicketPriceUseCaseImpl implements CalculateTicketPriceUseCase {
  @override
  Either<Failure, double> call(CalculateTicketPriceParams params) {
    if (params.selectedSeats.isEmpty) {
      return const Right(0.0);
    }

    final total = params.selectedSeats.fold<double>(
      0.0,
      (sum, seat) => sum + seat.price,
    );

    return Right(total);
  }
}

class CalculateTicketPriceParams {
  final List<Seat> selectedSeats;

  CalculateTicketPriceParams({required this.selectedSeats});
}
