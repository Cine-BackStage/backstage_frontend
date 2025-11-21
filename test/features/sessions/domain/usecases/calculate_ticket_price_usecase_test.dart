import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/sessions/domain/entities/seat.dart';
import 'package:backstage_frontend/features/sessions/domain/usecases/calculate_ticket_price_usecase.dart';

void main() {
  late CalculateTicketPriceUseCaseImpl useCase;

  setUp(() {
    useCase = CalculateTicketPriceUseCaseImpl();
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

  const tVipSeat = Seat(
    id: 'seat-3',
    seatNumber: 'V1',
    row: 'V',
    column: 1,
    type: 'VIP',
    status: 'AVAILABLE',
    price: 40.0,
  );

  test('should return 0.0 when no seats are selected', () {
    // Arrange
    final selectedSeats = <Seat>[];

    // Act
    final result = useCase.call(CalculateTicketPriceParams(
      selectedSeats: selectedSeats,
    ));

    // Assert
    expect(result, Right(0.0));
  });

  test('should return correct price for single seat', () {
    // Arrange
    final selectedSeats = [tSeat1];

    // Act
    final result = useCase.call(CalculateTicketPriceParams(
      selectedSeats: selectedSeats,
    ));

    // Assert
    expect(result, Right(25.0));
  });

  test('should return correct total price for multiple seats', () {
    // Arrange
    final selectedSeats = [tSeat1, tSeat2];

    // Act
    final result = useCase.call(CalculateTicketPriceParams(
      selectedSeats: selectedSeats,
    ));

    // Assert
    expect(result, Right(50.0));
  });

  test('should calculate correct price for mixed seat types', () {
    // Arrange
    final selectedSeats = [tSeat1, tSeat2, tVipSeat];

    // Act
    final result = useCase.call(CalculateTicketPriceParams(
      selectedSeats: selectedSeats,
    ));

    // Assert
    expect(result, Right(90.0)); // 25 + 25 + 40
  });

  test('should handle seats with different prices correctly', () {
    // Arrange
    const customPriceSeat = Seat(
      id: 'seat-4',
      seatNumber: 'B1',
      row: 'B',
      column: 1,
      type: 'STANDARD',
      status: 'AVAILABLE',
      price: 15.5,
    );
    final selectedSeats = [tSeat1, customPriceSeat];

    // Act
    final result = useCase.call(CalculateTicketPriceParams(
      selectedSeats: selectedSeats,
    ));

    // Assert
    expect(result, Right(40.5)); // 25 + 15.5
  });
}
