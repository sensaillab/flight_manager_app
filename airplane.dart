import 'package:floor/floor.dart';

@entity
class Airplane {
  @primaryKey
  final int id;
  final String type;
  final int passengers;
  final double maxSpeed;
  final double range;

  static int ID = 1;

  Airplane(this.id, this.type, this.passengers, this.maxSpeed, this.range) {
    if (id >= ID) {
      ID = id + 1;
    }
  }
}
