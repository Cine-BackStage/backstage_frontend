import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/sessions/data/models/seat_model.dart';
import 'package:backstage_frontend/features/sessions/domain/entities/seat.dart';

void main() {
  const tSeatModel = SeatModel(
    id: 'seat-1',
    seatNumber: 'A1',
    row: 'A',
    column: 1,
    type: 'STANDARD',
    status: 'AVAILABLE',
    price: 25.0,
    isAccessible: false,
  );

  test('should be a subclass of Seat entity', () {
    // Assert
    expect(tSeatModel, isA<Seat>());
  });

  group('fromJson', () {
    test('should return a valid SeatModel from JSON', () {
      // Arrange
      final json = {
        'id': 'seat-1',
        'seatNumber': 'A1',
        'row': 'A',
        'column': 1,
        'type': 'STANDARD',
        'status': 'AVAILABLE',
        'price': 25.0,
        'isAccessible': false,
      };

      // Act
      final result = SeatModel.fromJson(json);

      // Assert
      expect(result, isA<SeatModel>());
      expect(result.id, 'seat-1');
      expect(result.seatNumber, 'A1');
      expect(result.row, 'A');
      expect(result.column, 1);
      expect(result.type, 'STANDARD');
      expect(result.status, 'AVAILABLE');
      expect(result.price, 25.0);
      expect(result.isAccessible, false);
    });

    test('should handle alternative field names for row and column', () {
      // Arrange
      final json = {
        'id': 'seat-1',
        'rowLabel': 'B',
        'number': 5,
        'status': 'AVAILABLE',
        'price': 30.0,
      };

      // Act
      final result = SeatModel.fromJson(json);

      // Assert
      expect(result.row, 'B');
      expect(result.column, 5);
      expect(result.seatNumber, 'seat-1'); // Falls back to id
    });

    test('should use id as seatNumber when seatNumber is missing', () {
      // Arrange
      final json = {
        'id': 'seat-2',
        'row': 'C',
        'column': 3,
        'status': 'SOLD',
        'price': 25.0,
      };

      // Act
      final result = SeatModel.fromJson(json);

      // Assert
      expect(result.seatNumber, 'seat-2');
    });

    test('should handle missing optional fields with defaults', () {
      // Arrange
      final json = {
        'id': 'seat-3',
        'status': 'AVAILABLE',
        'price': 25,
      };

      // Act
      final result = SeatModel.fromJson(json);

      // Assert
      expect(result.type, 'STANDARD');
      expect(result.row, 'A');
      expect(result.column, 1);
      expect(result.isAccessible, false);
    });

    test('should parse price from integer', () {
      // Arrange
      final json = {
        'id': 'seat-4',
        'seatNumber': 'D4',
        'row': 'D',
        'column': 4,
        'type': 'VIP',
        'status': 'AVAILABLE',
        'price': 40,
      };

      // Act
      final result = SeatModel.fromJson(json);

      // Assert
      expect(result.price, 40.0);
    });

    test('should parse price from string', () {
      // Arrange
      final json = {
        'id': 'seat-5',
        'seatNumber': 'E5',
        'row': 'E',
        'column': 5,
        'type': 'STANDARD',
        'status': 'AVAILABLE',
        'price': '35.50',
      };

      // Act
      final result = SeatModel.fromJson(json);

      // Assert
      expect(result.price, 35.50);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // Act
      final result = tSeatModel.toJson();

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], 'seat-1');
      expect(result['seatNumber'], 'A1');
      expect(result['row'], 'A');
      expect(result['column'], 1);
      expect(result['type'], 'STANDARD');
      expect(result['status'], 'AVAILABLE');
      expect(result['price'], 25.0);
      expect(result['isAccessible'], false);
    });
  });

  group('toEntity', () {
    test('should return a Seat entity with the same data', () {
      // Act
      final result = tSeatModel.toEntity();

      // Assert
      expect(result, isA<Seat>());
      expect(result.id, tSeatModel.id);
      expect(result.seatNumber, tSeatModel.seatNumber);
      expect(result.row, tSeatModel.row);
      expect(result.column, tSeatModel.column);
      expect(result.type, tSeatModel.type);
      expect(result.status, tSeatModel.status);
      expect(result.price, tSeatModel.price);
      expect(result.isAccessible, tSeatModel.isAccessible);
    });
  });
}
