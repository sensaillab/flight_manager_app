import 'package:flutter/foundation.dart';
import '../data/database.dart';
import '../dao/reservation_dao.dart';
import '../models/reservation.dart';

/// ViewModel for managing Reservation CRUD + loading/error state.
class ReservationModel extends ChangeNotifier {
  late final ReservationDao _dao;
  List<Reservation> reservations = [];
  bool loading = false;
  String? error;

  ReservationModel() {
    _init();
  }

  /// Initialize the DB & DAO, then load all reservations.
  Future<void> _init() async {
    final db = await $FloorAppDatabase
        .databaseBuilder('flight_manager.db')
        .build();
    _dao = db.reservationDao;
    await loadAll();
  }

  /// Load all reservations from the database.
  Future<void> loadAll() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      reservations = await _dao.findAllReservations();
    } catch (e) {
      error = 'Failed to load reservations: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Add a reservation and refresh.
  Future<void> add(Reservation r) async =>
      _wrap(() => _dao.insertReservation(r));

  /// Update a reservation and refresh.
  Future<void> update(Reservation r) async =>
      _wrap(() => _dao.updateReservation(r));

  /// Delete a reservation and refresh.
  Future<void> delete(Reservation r) async =>
      _wrap(() => _dao.deleteReservation(r));

  /// Helper to perform [action], refresh list, and catch errors.
  Future<void> _wrap(Future<void> Function() action) async {
    try {
      await action();
      await loadAll();
    } catch (e) {
      error = 'Database error: $e';
      notifyListeners();
    }
  }
}
