import 'package:flutter/material.dart';
import '../data/database.dart';
import '../models/airplane.dart';
import '../repositories/airplane_repository.dart';
import '../utils/encrypted_prefs_helper.dart';
import '../widgets/confirmation_dialog.dart';
import '../constants/strings.dart';

class AirplaneListPage extends StatefulWidget {
  const AirplaneListPage({Key? key}) : super(key: key);

  @override
  State<AirplaneListPage> createState() => _AirplaneListPageState();
}

class _AirplaneListPageState extends State<AirplaneListPage> {
  late AirplaneRepository _repository;
  List<Airplane> _airplanes = [];
  final _prefs = EncryptedPrefsHelper();

  final _typeController = TextEditingController();
  final _passengersController = TextEditingController();
  final _maxSpeedController = TextEditingController();
  final _rangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final db = await $FloorAppDatabase.databaseBuilder('app.db').build();
    _repository = AirplaneRepository(db.airplaneDao);
    _loadAirplanes();
  }

  Future<void> _loadAirplanes() async {
    final list = await _repository.getAllAirplanes();
    setState(() => _airplanes = list);
  }

  void _showForm({Airplane? existing}) async {
    final pageContext = context;

    if (existing != null) {
      _typeController.text = existing.type;
      _passengersController.text = existing.passengers.toString();
      _maxSpeedController.text = existing.maxSpeed.toString();
      _rangeController.text = existing.range.toString();
    } else {
      // ✅ Clear all fields for a new record
      _typeController.clear();
      _passengersController.clear();
      _maxSpeedController.clear();
      _rangeController.clear();
    }

    showDialog(
      context: pageContext,
      builder: (_) => AlertDialog(
        title: Text(Strings.of(pageContext,
            existing == null ? 'addAirplane' : 'editAirplane')),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _typeController,
                decoration:
                InputDecoration(labelText: Strings.of(pageContext, 'type')),
              ),
              TextField(
                controller: _passengersController,
                decoration: InputDecoration(
                    labelText: Strings.of(pageContext, 'passengers')),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _maxSpeedController,
                decoration: InputDecoration(
                    labelText: Strings.of(pageContext, 'maxSpeed')),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _rangeController,
                decoration: InputDecoration(
                    labelText: Strings.of(pageContext, 'range')),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(pageContext),
            child: Text(Strings.of(pageContext, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_typeController.text.isEmpty ||
                  _passengersController.text.isEmpty ||
                  _maxSpeedController.text.isEmpty ||
                  _rangeController.text.isEmpty) {
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(content: Text(Strings.of(pageContext, 'fillAllFields'))),
                );
                return;
              }

              final airplane = Airplane(
                existing?.id ?? Airplane.ID++,
                _typeController.text,
                int.tryParse(_passengersController.text) ?? 0,
                double.tryParse(_maxSpeedController.text) ?? 0,
                double.tryParse(_rangeController.text) ?? 0,
              );

              if (existing == null) {
                await _repository.addAirplane(airplane);
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(content: Text(Strings.of(pageContext, 'airplaneAdded'))),
                );
              } else {
                await _repository.updateAirplane(airplane);
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(content: Text(Strings.of(pageContext, 'airplaneUpdated'))),
                );
              }

              await _loadAirplanes(); // ✅ Refresh list immediately
              Navigator.pop(pageContext);
            },
            child: Text(Strings.of(pageContext,
                existing == null ? 'addAirplane' : 'editAirplane')),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Airplane airplane) async {
    final confirm = await showConfirmationDialog(
      context,
      Strings.of(context, 'deleteAirplaneConfirm'),
    );
    if (confirm) {
      await _repository.deleteAirplane(airplane);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.of(context, 'airplaneDeleted'))),
      );
      _loadAirplanes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context, 'airplanesTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(Strings.of(context, 'airplanesTitle')),
                  content: Text(Strings.of(context, 'airplanesHelp')),
                ),
              );
            },
          ),
        ],
      ),
      body: _airplanes.isEmpty
          ? Center(child: Text(Strings.of(context, 'noAirplanes')))
          : RefreshIndicator(
        onRefresh: _loadAirplanes,
        child: ListView.builder(
          itemCount: _airplanes.length,
          itemBuilder: (context, index) {
            final a = _airplanes[index];
            return ListTile(
              title: Text(a.type),
              subtitle: Text(
                '${Strings.of(context, 'passengers')}: ${a.passengers} • '
                    '${Strings.of(context, 'maxSpeed')}: ${a.maxSpeed} • '
                    '${Strings.of(context, 'range')}: ${a.range}',
              ),
              onTap: () => _showForm(existing: a),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(a),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
