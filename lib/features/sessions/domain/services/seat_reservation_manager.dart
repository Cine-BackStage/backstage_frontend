/// Local seat reservation manager
/// Manages temporary seat reservations during the checkout process
class SeatReservationManager {
  static final SeatReservationManager _instance = SeatReservationManager._internal();
  factory SeatReservationManager() => _instance;
  SeatReservationManager._internal();

  // Map of sessionId -> Set of reserved seatIds
  final Map<String, Set<String>> _reservations = {};

  // Map of saleId -> Map of sessionId -> Set of seatIds
  // Tracks which seats belong to which sale
  final Map<String, Map<String, Set<String>>> _saleReservations = {};

  /// Reserve seats for a sale
  void reserveSeats(String saleId, String sessionId, List<String> seatIds) {
    // Add to session reservations
    if (!_reservations.containsKey(sessionId)) {
      _reservations[sessionId] = {};
    }
    _reservations[sessionId]!.addAll(seatIds);

    // Add to sale reservations
    if (!_saleReservations.containsKey(saleId)) {
      _saleReservations[saleId] = {};
    }
    if (!_saleReservations[saleId]!.containsKey(sessionId)) {
      _saleReservations[saleId]![sessionId] = {};
    }
    _saleReservations[saleId]![sessionId]!.addAll(seatIds);

    print('[SeatReservationManager] Reserved seats $seatIds for sale $saleId in session $sessionId');
  }

  /// Release seats for a specific sale
  void releaseSaleReservations(String saleId) {
    if (_saleReservations.containsKey(saleId)) {
      final saleSeats = _saleReservations[saleId]!;

      // Remove from session reservations
      saleSeats.forEach((sessionId, seatIds) {
        if (_reservations.containsKey(sessionId)) {
          _reservations[sessionId]!.removeAll(seatIds);
          if (_reservations[sessionId]!.isEmpty) {
            _reservations.remove(sessionId);
          }
        }
      });

      // Remove sale reservations
      _saleReservations.remove(saleId);
      print('[SeatReservationManager] Released all reservations for sale $saleId');
    }
  }

  /// Release specific seats
  void releaseSeats(String saleId, String sessionId, List<String> seatIds) {
    if (_reservations.containsKey(sessionId)) {
      _reservations[sessionId]!.removeAll(seatIds);
      if (_reservations[sessionId]!.isEmpty) {
        _reservations.remove(sessionId);
      }
    }

    if (_saleReservations.containsKey(saleId) &&
        _saleReservations[saleId]!.containsKey(sessionId)) {
      _saleReservations[saleId]![sessionId]!.removeAll(seatIds);
      if (_saleReservations[saleId]![sessionId]!.isEmpty) {
        _saleReservations[saleId]!.remove(sessionId);
      }
      if (_saleReservations[saleId]!.isEmpty) {
        _saleReservations.remove(saleId);
      }
    }

    print('[SeatReservationManager] Released seats $seatIds for sale $saleId in session $sessionId');
  }

  /// Check if a seat is reserved
  bool isSeatReserved(String sessionId, String seatId) {
    return _reservations[sessionId]?.contains(seatId) ?? false;
  }

  /// Get all reserved seat IDs for a session
  Set<String> getReservedSeats(String sessionId) {
    return _reservations[sessionId] ?? {};
  }

  /// Get all reservations for a sale
  Map<String, Set<String>>? getSaleReservations(String saleId) {
    return _saleReservations[saleId];
  }

  /// Clear all reservations (use with caution)
  void clearAll() {
    _reservations.clear();
    _saleReservations.clear();
    print('[SeatReservationManager] Cleared all reservations');
  }
}
