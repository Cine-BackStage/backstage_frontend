import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/sessions/domain/entities/seat.dart';
import 'package:backstage_frontend/features/sessions/domain/usecases/select_seat_usecase.dart';

void main() {
  late SelectSeatUseCaseImpl useCase;

  setUp(() {
    useCase = SelectSeatUseCaseImpl();
  });

  const tSeat = Seat(
    id: 'seat-1',
    seatNumber: 'A1',
    row: 'A',
    column: 1,
    type: 'STANDARD',
    status: 'AVAILABLE',
    price: 25.0,
  );

  const tSeat2 = Seat(
    id: 'seat-2',
    seatNumber: 'A2',
    row: 'A',
    column: 2,
    type: 'STANDARD',
    status: 'AVAILABLE',
    price: 25.0,
  );

  const tSoldSeat = Seat(
    id: 'seat-3',
    seatNumber: 'A3',
    row: 'A',
    column: 3,
    type: 'STANDARD',
    status: 'SOLD',
    price: 25.0,
  );

  test('should add seat to selection when seat is available', () {
    // Arrange
    final currentSelection = <Seat>[];

    // Act
    final result = useCase.call(SelectSeatParams(
      seat: tSeat,
      currentSelection: currentSelection,
    ));

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not return failure'),
      (seats) {
        expect(seats.length, 1);
        expect(seats, contains(tSeat));
      },
    );
  });

  test('should add seat to existing selection', () {
    // Arrange
    final currentSelection = [tSeat];

    // Act
    final result = useCase.call(SelectSeatParams(
      seat: tSeat2,
      currentSelection: currentSelection,
    ));

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not return failure'),
      (seats) {
        expect(seats.length, 2);
        expect(seats, contains(tSeat));
        expect(seats, contains(tSeat2));
      },
    );
  });

  test('should return Failure when seat is not selectable', () {
    // Arrange
    final currentSelection = <Seat>[];

    // Act
    final result = useCase.call(SelectSeatParams(
      seat: tSoldSeat,
      currentSelection: currentSelection,
    ));

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<GenericFailure>());
        expect(failure.message, 'Este assento não está disponível para seleção');
      },
      (seats) => fail('Should not return success'),
    );
  });

  test('should return Failure when seat is already selected', () {
    // Arrange
    final currentSelection = [tSeat];

    // Act
    final result = useCase.call(SelectSeatParams(
      seat: tSeat,
      currentSelection: currentSelection,
    ));

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<GenericFailure>());
        expect(failure.message, 'Assento já selecionado');
      },
      (seats) => fail('Should not return success'),
    );
  });

  test('should not modify original selection list', () {
    // Arrange
    final currentSelection = [tSeat];
    final originalLength = currentSelection.length;

    // Act
    useCase.call(SelectSeatParams(
      seat: tSeat2,
      currentSelection: currentSelection,
    ));

    // Assert
    expect(currentSelection.length, originalLength);
  });
}
