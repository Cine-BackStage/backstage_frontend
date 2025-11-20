import '../../../../adapters/http/http_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/logger_service.dart';
import '../models/session_model.dart';
import '../models/seat_model.dart';
import '../models/ticket_model.dart';

abstract class SessionsRemoteDataSource {
  Future<List<SessionModel>> getSessions({
    DateTime? date,
    int? movieId,
    int? roomId,
  });
  Future<SessionModel> getSessionDetails(String sessionId);
  Future<List<SeatModel>> getSessionSeats(String sessionId);
  Future<List<TicketModel>> purchaseTickets({
    required String sessionId,
    required List<String> seatIds,
    required String customerCpf,
    String? customerName,
  });
  Future<TicketModel> cancelTicket(String ticketId);
  Future<TicketModel> validateTicket(String ticketId);
  Future<List<TicketModel>> getTicketsBySession(String sessionId);

  // Session Management (CRUD)
  Future<SessionModel> createSession({
    required String movieId,
    required String roomId,
    required DateTime startTime,
    double? basePrice,
  });
  Future<SessionModel> updateSession({
    required String sessionId,
    String? movieId,
    String? roomId,
    DateTime? startTime,
    double? basePrice,
    String? status,
  });
  Future<void> deleteSession(String sessionId);
}

class SessionsRemoteDataSourceImpl implements SessionsRemoteDataSource {
  final HttpClient client;
  final logger = LoggerService();

  SessionsRemoteDataSourceImpl(this.client);

  @override
  Future<List<SessionModel>> getSessions({
    DateTime? date,
    int? movieId,
    int? roomId,
  }) async {
    final queryParams = <String, dynamic>{};

    // API expects startDate and endDate, not just date
    if (date != null) {
      // Get start of day (00:00:00)
      final startOfDay = DateTime(date.year, date.month, date.day);
      // Get end of day (23:59:59)
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      queryParams['startDate'] = startOfDay.toIso8601String();
      queryParams['endDate'] = endOfDay.toIso8601String();
    }

    if (movieId != null) {
      queryParams['movieId'] = movieId.toString();
    }
    if (roomId != null) {
      queryParams['roomId'] = roomId.toString();
    }

    logger.logDataSourceRequest('SessionsDataSource', 'getSessions', queryParams);
    final response = await client.get(
      ApiConstants.sessions,
      queryParameters: queryParams,
    );

    final data = response.data['data'] as List;
    return data.map((json) => SessionModel.fromJson(json)).toList();
  }

  @override
  Future<SessionModel> getSessionDetails(String sessionId) async {
    final response = await client.get(
      ApiConstants.sessionDetails(sessionId),
    );

    return SessionModel.fromJson(response.data['data']);
  }

  @override
  Future<List<SeatModel>> getSessionSeats(String sessionId) async {
    final response = await client.get(
      ApiConstants.sessionSeats(sessionId),
    );

    final responseData = response.data['data'];

    // Handle different response structures
    List<dynamic> data;
    if (responseData is List) {
      data = responseData;
    } else if (responseData is Map) {
      // If API returns {data: {seats: [...]}}
      if (responseData['seats'] is List) {
        data = responseData['seats'] as List;
      } else {
        // If API returns single seat object, wrap in list
        data = [responseData];
      }
    } else {
      data = [];
    }

    return data.map((json) => SeatModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<TicketModel>> purchaseTickets({
    required String sessionId,
    required List<String> seatIds,
    required String customerCpf,
    String? customerName,
  }) async {
    final requestData = {
      'sessionId': sessionId,
      'seatIds': seatIds,
      'customerCpf': customerCpf,
      if (customerName != null) 'customerName': customerName,
    };

    logger.logDataSourceRequest('SessionsDataSource', 'purchaseTickets', requestData);
    final response = await client.post(
      ApiConstants.ticketsBulk,
      data: requestData,
    );

    final data = response.data['data'] as List;
    return data.map((json) => TicketModel.fromJson(json)).toList();
  }

  @override
  Future<TicketModel> cancelTicket(String ticketId) async {
    final response = await client.post(
      ApiConstants.ticketCancel(ticketId),
    );

    return TicketModel.fromJson(response.data['data']);
  }

  @override
  Future<TicketModel> validateTicket(String ticketId) async {
    final response = await client.post(
      ApiConstants.ticketValidate(ticketId),
    );

    return TicketModel.fromJson(response.data['data']);
  }

  @override
  Future<List<TicketModel>> getTicketsBySession(String sessionId) async {
    final response = await client.get(
      ApiConstants.ticketsBySession(sessionId),
    );

    final data = response.data['data'] as List;
    return data.map((json) => TicketModel.fromJson(json)).toList();
  }

  @override
  Future<SessionModel> createSession({
    required String movieId,
    required String roomId,
    required DateTime startTime,
    double? basePrice,
  }) async {
    final requestData = {
      'movieId': movieId,
      'roomId': roomId,
      'startTime': startTime.toIso8601String(),
      if (basePrice != null) 'basePrice': basePrice,
    };

    logger.logDataSourceRequest('SessionsDataSource', 'createSession', requestData);
    final response = await client.post(
      ApiConstants.sessions,
      data: requestData,
    );

    return SessionModel.fromJson(response.data['data']);
  }

  @override
  Future<SessionModel> updateSession({
    required String sessionId,
    String? movieId,
    String? roomId,
    DateTime? startTime,
    double? basePrice,
    String? status,
  }) async {
    final requestData = {
      if (movieId != null) 'movieId': movieId,
      if (roomId != null) 'roomId': roomId,
      if (startTime != null) 'startTime': startTime.toIso8601String(),
      if (basePrice != null) 'basePrice': basePrice,
      if (status != null) 'status': status,
    };

    logger.logDataSourceRequest('SessionsDataSource', 'updateSession', requestData);
    final response = await client.put(
      ApiConstants.sessionDetails(sessionId),
      data: requestData,
    );

    return SessionModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await client.delete(
      ApiConstants.sessionDetails(sessionId),
    );
  }
}
