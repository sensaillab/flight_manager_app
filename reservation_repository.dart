import '../data/database.dart';
import '../models/reservation.dart';

class ReservationRepository {
  Future<List<Reservation>> getAll() async {
    final db = await $FloorAppDatabase.databaseBuilder('flight_manager.db').build();
    return db.reservationDao.findAllReservations();
  }

  Future<void> insert(Reservation r) async {
    final db = await $FloorAppDatabase.databaseBuilder('flight_manager.db').build();
    return db.reservationDao.insertReservation(r);
  }

  Future<void> update(Reservation r) async {
    final db = await $FloorAppDatabase.databaseBuilder('flight_manager.db').build();
    return db.reservationDao.updateReservation(r);
  }

  Future<void> delete(Reservation r) async {
    final db = await $FloorAppDatabase.databaseBuilder('flight_manager.db').build();
    return db.reservationDao.deleteReservation(r);
  }
}
