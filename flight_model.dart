import 'package:flutter/foundation.dart';
import '../data/database.dart';
import '../dao/flight_dao.dart';
import '../models/flight.dart';

/// ViewModel for managing Flight CRUD + loading/error state.
class FlightModel extends ChangeNotifier {
  late final FlightDao _dao;
  List<Flight> flights = [];
  bool loading = false;
  String? error;

  FlightModel() {
    _init();
  }

  /// Initialize the database and DAO, then load all flights.
  Future<void> _init() async {
    final db = await $FloorAppDatabase
        .databaseBuilder('flight_manager.db')
        .build();
    _dao = db.flightDao;
    await loadAll();
  }

  /// Load all flights from the database.
  Future<void> loadAll() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      flights = await _dao.findAllFlights();
    } catch (e) {
      error = 'Failed to load flights: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Add a new flight and refresh.
  Future<void> add(Flight f) async =>
      _wrap(() => _dao.insertFlight(f));

  /// Update an existing flight and refresh.
  Future<void> update(Flight f) async =>
      _wrap(() => _dao.updateFlight(f));

  /// Delete a flight and refresh.
  Future<void> delete(Flight f) async =>
      _wrap(() => _dao.deleteFlight(f));

  /// Helper to perform [op], refresh list, and catch errors.
  Future<void> _wrap(Future<void> Function() op) async {
    try {
      await op();
      await loadAll();
    } catch (e) {
      error = 'Database error: $e';
      notifyListeners();
    }
  }
}
