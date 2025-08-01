import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/flight.dart';
import '../models/reservation.dart';
import '../models/customer.dart';
import '../models/airplane.dart';

import '../dao/flight_dao.dart';
import '../dao/reservation_dao.dart';
import '../dao/customer_dao.dart';
import '../dao/airplane_dao.dart';

part 'database.g.dart';

@Database(
    version: 1,
    entities: [Flight, Reservation, Customer, Airplane]
)
abstract class AppDatabase extends FloorDatabase {
  FlightDao get flightDao;
  ReservationDao get reservationDao;
  CustomerDao get customerDao;
  AirplaneDao get airplaneDao;
}
