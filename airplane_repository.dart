import '../dao/airplane_dao.dart';
import '../models/airplane.dart';

class AirplaneRepository {
  final AirplaneDao _dao;

  AirplaneRepository(this._dao);

  Future<List<Airplane>> getAllAirplanes() => _dao.findAllAirplanes();
  Future<void> addAirplane(Airplane airplane) => _dao.insertAirplane(airplane);
  Future<void> updateAirplane(Airplane airplane) => _dao.updateAirplane(airplane);
  Future<void> deleteAirplane(Airplane airplane) => _dao.deleteAirplane(airplane);
}
