import '../../domain/entities/ticket.dart';

class TicketModel extends Ticket {
  const TicketModel({
    required super.id,
    required super.ticketNumber,
    required super.sessionId,
    required super.seatId,
    required super.seatNumber,
    required super.customerCpf,
    required super.price,
    required super.status,
    required super.purchasedAt,
    super.customerName,
    super.validatedAt,
    super.canceledAt,
    super.refundedAt,
    super.qrCode,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String,
      sessionId: json['sessionId'] as String,
      seatId: json['seatId'] as String,
      seatNumber: json['seatNumber'] as String? ?? json['seatId'] as String,
      customerCpf: json['customerCpf'] as String,
      price: double.parse(json['price']?.toString() ?? '0'),
      status: json['status'] as String,
      purchasedAt: DateTime.parse(json['purchasedAt'] as String),
      customerName: json['customerName'] as String?,
      validatedAt: json['validatedAt'] != null
          ? DateTime.parse(json['validatedAt'] as String)
          : null,
      canceledAt: json['canceledAt'] != null
          ? DateTime.parse(json['canceledAt'] as String)
          : null,
      refundedAt: json['refundedAt'] != null
          ? DateTime.parse(json['refundedAt'] as String)
          : null,
      qrCode: json['qrCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      'sessionId': sessionId,
      'seatId': seatId,
      'seatNumber': seatNumber,
      'customerCpf': customerCpf,
      'price': price,
      'status': status,
      'purchasedAt': purchasedAt.toIso8601String(),
      'customerName': customerName,
      'validatedAt': validatedAt?.toIso8601String(),
      'canceledAt': canceledAt?.toIso8601String(),
      'refundedAt': refundedAt?.toIso8601String(),
      'qrCode': qrCode,
    };
  }

  Ticket toEntity() {
    return Ticket(
      id: id,
      ticketNumber: ticketNumber,
      sessionId: sessionId,
      seatId: seatId,
      seatNumber: seatNumber,
      customerCpf: customerCpf,
      price: price,
      status: status,
      purchasedAt: purchasedAt,
      customerName: customerName,
      validatedAt: validatedAt,
      canceledAt: canceledAt,
      refundedAt: refundedAt,
      qrCode: qrCode,
    );
  }
}
