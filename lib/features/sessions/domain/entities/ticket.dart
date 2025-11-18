import 'package:equatable/equatable.dart';

class Ticket extends Equatable {
  final String id;
  final String ticketNumber;
  final String sessionId;
  final String seatId;
  final String seatNumber;
  final String customerCpf;
  final double price;
  final String status; // ACTIVE, VALIDATED, CANCELED, REFUNDED
  final DateTime purchasedAt;
  final String? customerName;
  final DateTime? validatedAt;
  final DateTime? canceledAt;
  final DateTime? refundedAt;
  final String? qrCode;

  const Ticket({
    required this.id,
    required this.ticketNumber,
    required this.sessionId,
    required this.seatId,
    required this.seatNumber,
    required this.customerCpf,
    required this.price,
    required this.status,
    required this.purchasedAt,
    this.customerName,
    this.validatedAt,
    this.canceledAt,
    this.refundedAt,
    this.qrCode,
  });

  bool get isActive => status == 'ACTIVE';
  bool get isValidated => status == 'VALIDATED';
  bool get isCanceled => status == 'CANCELED';
  bool get isRefunded => status == 'REFUNDED';
  bool get canBeCanceled => isActive && DateTime.now().isBefore(purchasedAt.add(const Duration(hours: 24)));

  @override
  List<Object?> get props => [
        id,
        ticketNumber,
        sessionId,
        seatId,
        seatNumber,
        customerCpf,
        price,
        status,
        purchasedAt,
        customerName,
        validatedAt,
        canceledAt,
        refundedAt,
        qrCode,
      ];
}
