import 'package:floor/floor.dart';
import '../models/airplane.dart';

@dao
abstract class AirplaneDao {
  @Query('SELECT * FROM Airplane ORDER BY id DESC')
  Future<List<Airplane>> findAllAirplanes();

  @insert
  Future<void> insertAirplane(Airplane airplane);

  @update
  Future<void> updateAirplane(Airplane airplane);

  @delete
  Future<void> deleteAirplane(Airplane airplane);
}
