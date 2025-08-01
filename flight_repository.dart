import '../data/database.dart';
import '../models/flight.dart';

class FlightRepository {
  Future<List<Flight>> getAll() async {
    final db = await $FloorAppDatabase.databaseBuilder('flight_manager.db').build();
    return db.flightDao.findAllFlights();
  }

  Future<void> insert(Flight f) async {
    final db = await $FloorAppDatabase.databaseBuilder('flight_manager.db').build();
    return db.flightDao.insertFlight(f);
  }

  Future<void> update(Flight f) async {
    final db = await $FloorAppDatabase.databaseBuilder('flight_manager.db').build();
    return db.flightDao.updateFlight(f);
  }

  Future<void> delete(Flight f) async {
    final db = await $FloorAppDatabase.databaseBuilder('flight_manager.db').build();
    return db.flightDao.deleteFlight(f);
  }
}
