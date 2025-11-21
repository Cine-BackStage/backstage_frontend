import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/sessions/domain/entities/seat.dart';
import 'package:backstage_frontend/features/sessions/domain/usecases/deselect_seat_usecase.dart';

void main() {
  late DeselectSeatUseCaseImpl useCase;

  setUp(() {
    useCase = DeselectSeatUseCaseImpl();
  });

  const tSeat1 = Seat(
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

  const tSeat3 = Seat(
    id: 'seat-3',
    seatNumber: 'A3',
    row: 'A',
    column: 3,
    type: 'STANDARD',
    status: 'AVAILABLE',
    price: 25.0,
  );

  test('should remove seat from selection', () {
    // Arrange
    final currentSelection = [tSeat1, tSeat2];

    // Act
    final result = useCase.call(DeselectSeatParams(
      seatId: tSeat1.id,
      currentSelection: currentSelection,
    ));

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not return failure'),
      (seats) {
        expect(seats.length, 1);
        expect(seats, contains(tSeat2));
      },
    );
  });

  test('should remove correct seat from multiple selections', () {
    // Arrange
    final currentSelection = [tSeat1, tSeat2, tSeat3];

    // Act
    final result = useCase.call(DeselectSeatParams(
      seatId: tSeat2.id,
      currentSelection: currentSelection,
    ));

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not return failure'),
      (seats) {
        expect(seats.length, 2);
        expect(seats, contains(tSeat1));
        expect(seats, contains(tSeat3));
        expect(seats, isNot(contains(tSeat2)));
      },
    );
  });

  test('should return empty list when removing last seat', () {
    // Arrange
    final currentSelection = [tSeat1];

    // Act
    final result = useCase.call(DeselectSeatParams(
      seatId: tSeat1.id,
      currentSelection: currentSelection,
    ));

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not return failure'),
      (seats) {
        expect(seats.length, 0);
        expect(seats, isEmpty);
      },
    );
  });

  test('should return same list when seat is not in selection', () {
    // Arrange
    final currentSelection = [tSeat1, tSeat2];

    // Act
    final result = useCase.call(DeselectSeatParams(
      seatId: tSeat3.id,
      currentSelection: currentSelection,
    ));

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not return failure'),
      (seats) {
        expect(seats.length, 2);
        expect(seats, contains(tSeat1));
        expect(seats, contains(tSeat2));
      },
    );
  });

  test('should not modify original selection list', () {
    // Arrange
    final currentSelection = [tSeat1, tSeat2];
    final originalLength = currentSelection.length;

    // Act
    useCase.call(DeselectSeatParams(
      seatId: tSeat1.id,
      currentSelection: currentSelection,
    ));

    // Assert
    expect(currentSelection.length, originalLength);
  });
}
