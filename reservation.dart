import 'package:floor/floor.dart';

@entity
class Reservation {
  @primaryKey
  final int id;
  final String name;
  final int customerId;
  final int flightId;
  final String date;

  static int ID = 1;

  Reservation(this.id, this.name, this.customerId, this.flightId, this.date) {
    if (id >= ID) ID = id + 1;
  }
}
