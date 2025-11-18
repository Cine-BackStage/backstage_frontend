import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/seat.dart';

/// UseCase for deselecting a seat (local state management)
abstract class DeselectSeatUseCase {
  Either<Failure, List<Seat>> call(DeselectSeatParams params);
}

class DeselectSeatUseCaseImpl implements DeselectSeatUseCase {
  @override
  Either<Failure, List<Seat>> call(DeselectSeatParams params) {
    final selectedSeats = List<Seat>.from(params.currentSelection);

    // Remove from selection
    selectedSeats.removeWhere((s) => s.id == params.seatId);
    return Right(selectedSeats);
  }
}

class DeselectSeatParams {
  final String seatId;
  final List<Seat> currentSelection;

  DeselectSeatParams({
    required this.seatId,
    required this.currentSelection,
  });
}
