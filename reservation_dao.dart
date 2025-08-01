import 'package:floor/floor.dart';
import '../models/reservation.dart';

@dao
abstract class ReservationDao {
  @Query('SELECT * FROM Reservation')
  Future<List<Reservation>> findAllReservations();

  @insert
  Future<void> insertReservation(Reservation res);

  @update
  Future<void> updateReservation(Reservation res);

  @delete
  Future<void> deleteReservation(Reservation res);
}
