import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/sessions/data/models/ticket_model.dart';
import 'package:backstage_frontend/features/sessions/domain/entities/ticket.dart';

void main() {
  final tDateTime = DateTime(2024, 1, 15, 10, 0);
  final tTicketModel = TicketModel(
    id: 'ticket-1',
    ticketNumber: 'TKT-001',
    sessionId: 'session-1',
    seatId: 'seat-1',
    seatNumber: 'A1',
    customerCpf: '12345678901',
    price: 25.0,
    status: 'ACTIVE',
    purchasedAt: tDateTime,
    customerName: 'John Doe',
    validatedAt: tDateTime.add(Duration(hours: 1)),
    qrCode: 'QR123456',
  );

  test('should be a subclass of Ticket entity', () {
    // Assert
    expect(tTicketModel, isA<Ticket>());
  });

  group('fromJson', () {
    test('should return a valid TicketModel from JSON', () {
      // Arrange
      final json = {
        'id': 'ticket-1',
        'ticketNumber': 'TKT-001',
        'sessionId': 'session-1',
        'seatId': 'seat-1',
        'seatNumber': 'A1',
        'customerCpf': '12345678901',
        'price': 25.0,
        'status': 'ACTIVE',
        'purchasedAt': tDateTime.toIso8601String(),
        'customerName': 'John Doe',
        'validatedAt': tDateTime.add(Duration(hours: 1)).toIso8601String(),
        'qrCode': 'QR123456',
      };

      // Act
      final result = TicketModel.fromJson(json);

      // Assert
      expect(result, isA<TicketModel>());
      expect(result.id, 'ticket-1');
      expect(result.ticketNumber, 'TKT-001');
      expect(result.sessionId, 'session-1');
      expect(result.seatId, 'seat-1');
      expect(result.seatNumber, 'A1');
      expect(result.customerCpf, '12345678901');
      expect(result.price, 25.0);
      expect(result.status, 'ACTIVE');
      expect(result.customerName, 'John Doe');
      expect(result.qrCode, 'QR123456');
    });

    test('should use seatId as seatNumber when seatNumber is missing', () {
      // Arrange
      final json = {
        'id': 'ticket-2',
        'ticketNumber': 'TKT-002',
        'sessionId': 'session-1',
        'seatId': 'seat-2',
        'customerCpf': '12345678901',
        'price': 25.0,
        'status': 'ACTIVE',
        'purchasedAt': tDateTime.toIso8601String(),
      };

      // Act
      final result = TicketModel.fromJson(json);

      // Assert
      expect(result.seatNumber, 'seat-2');
    });

    test('should handle nullable fields', () {
      // Arrange
      final json = {
        'id': 'ticket-3',
        'ticketNumber': 'TKT-003',
        'sessionId': 'session-1',
        'seatId': 'seat-3',
        'seatNumber': 'C3',
        'customerCpf': '12345678901',
        'price': 25.0,
        'status': 'ACTIVE',
        'purchasedAt': tDateTime.toIso8601String(),
      };

      // Act
      final result = TicketModel.fromJson(json);

      // Assert
      expect(result.customerName, isNull);
      expect(result.validatedAt, isNull);
      expect(result.canceledAt, isNull);
      expect(result.refundedAt, isNull);
      expect(result.qrCode, isNull);
    });

    test('should parse all datetime fields correctly', () {
      // Arrange
      final validatedTime = tDateTime.add(Duration(hours: 1));
      final canceledTime = tDateTime.add(Duration(hours: 2));
      final refundedTime = tDateTime.add(Duration(hours: 3));
      final json = {
        'id': 'ticket-4',
        'ticketNumber': 'TKT-004',
        'sessionId': 'session-1',
        'seatId': 'seat-4',
        'seatNumber': 'D4',
        'customerCpf': '12345678901',
        'price': 25.0,
        'status': 'REFUNDED',
        'purchasedAt': tDateTime.toIso8601String(),
        'validatedAt': validatedTime.toIso8601String(),
        'canceledAt': canceledTime.toIso8601String(),
        'refundedAt': refundedTime.toIso8601String(),
      };

      // Act
      final result = TicketModel.fromJson(json);

      // Assert
      expect(result.purchasedAt, tDateTime);
      expect(result.validatedAt, validatedTime);
      expect(result.canceledAt, canceledTime);
      expect(result.refundedAt, refundedTime);
    });

    test('should parse price from integer', () {
      // Arrange
      final json = {
        'id': 'ticket-5',
        'ticketNumber': 'TKT-005',
        'sessionId': 'session-1',
        'seatId': 'seat-5',
        'seatNumber': 'E5',
        'customerCpf': '12345678901',
        'price': 40,
        'status': 'ACTIVE',
        'purchasedAt': tDateTime.toIso8601String(),
      };

      // Act
      final result = TicketModel.fromJson(json);

      // Assert
      expect(result.price, 40.0);
    });

    test('should parse price from string', () {
      // Arrange
      final json = {
        'id': 'ticket-6',
        'ticketNumber': 'TKT-006',
        'sessionId': 'session-1',
        'seatId': 'seat-6',
        'seatNumber': 'F6',
        'customerCpf': '12345678901',
        'price': '35.50',
        'status': 'ACTIVE',
        'purchasedAt': tDateTime.toIso8601String(),
      };

      // Act
      final result = TicketModel.fromJson(json);

      // Assert
      expect(result.price, 35.50);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // Act
      final result = tTicketModel.toJson();

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], 'ticket-1');
      expect(result['ticketNumber'], 'TKT-001');
      expect(result['sessionId'], 'session-1');
      expect(result['seatId'], 'seat-1');
      expect(result['seatNumber'], 'A1');
      expect(result['customerCpf'], '12345678901');
      expect(result['price'], 25.0);
      expect(result['status'], 'ACTIVE');
      expect(result['customerName'], 'John Doe');
      expect(result['qrCode'], 'QR123456');
    });

    test('should handle nullable fields in JSON output', () {
      // Arrange
      final ticketWithNulls = TicketModel(
        id: 'ticket-7',
        ticketNumber: 'TKT-007',
        sessionId: 'session-1',
        seatId: 'seat-7',
        seatNumber: 'G7',
        customerCpf: '12345678901',
        price: 25.0,
        status: 'ACTIVE',
        purchasedAt: tDateTime,
      );

      // Act
      final result = ticketWithNulls.toJson();

      // Assert
      expect(result['customerName'], isNull);
      expect(result['validatedAt'], isNull);
      expect(result['canceledAt'], isNull);
      expect(result['refundedAt'], isNull);
      expect(result['qrCode'], isNull);
    });
  });

  group('toEntity', () {
    test('should return a Ticket entity with the same data', () {
      // Act
      final result = tTicketModel.toEntity();

      // Assert
      expect(result, isA<Ticket>());
      expect(result.id, tTicketModel.id);
      expect(result.ticketNumber, tTicketModel.ticketNumber);
      expect(result.sessionId, tTicketModel.sessionId);
      expect(result.seatId, tTicketModel.seatId);
      expect(result.seatNumber, tTicketModel.seatNumber);
      expect(result.customerCpf, tTicketModel.customerCpf);
      expect(result.price, tTicketModel.price);
      expect(result.status, tTicketModel.status);
      expect(result.purchasedAt, tTicketModel.purchasedAt);
      expect(result.customerName, tTicketModel.customerName);
      expect(result.validatedAt, tTicketModel.validatedAt);
      expect(result.qrCode, tTicketModel.qrCode);
    });
  });
}
