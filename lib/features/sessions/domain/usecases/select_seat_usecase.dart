import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/seat.dart';

/// UseCase for selecting a seat (local state management)
/// This doesn't call the backend, just validates selection
abstract class SelectSeatUseCase {
  Either<Failure, List<Seat>> call(SelectSeatParams params);
}

class SelectSeatUseCaseImpl implements SelectSeatUseCase {
  @override
  Either<Failure, List<Seat>> call(SelectSeatParams params) {
    final seat = params.seat;
    final selectedSeats = List<Seat>.from(params.currentSelection);

    // Validate seat can be selected
    if (!seat.isSelectable) {
      return Left(GenericFailure(
        message: 'Este assento não está disponível para seleção',
      ));
    }

    // Check if already selected
    if (selectedSeats.any((s) => s.id == seat.id)) {
      return Left(GenericFailure(
        message: 'Assento já selecionado',
      ));
    }

    // Add to selection
    selectedSeats.add(seat);
    return Right(selectedSeats);
  }
}

class SelectSeatParams {
  final Seat seat;
  final List<Seat> currentSelection;

  SelectSeatParams({
    required this.seat,
    required this.currentSelection,
  });
}
