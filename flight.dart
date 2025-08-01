import 'package:floor/floor.dart';

@entity
class Flight {
  @primaryKey
  final int id;
  final String departureCity;
  final String destinationCity;
  final String departTime;
  final String arriveTime;

  static int ID = 1;

  Flight(this.id, this.departureCity, this.destinationCity, this.departTime, this.arriveTime)
  {
    if (id >= ID) ID = id + 1;
  }
}
