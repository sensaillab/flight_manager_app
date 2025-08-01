import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/strings.dart';
import '../viewmodels/flight_model.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/list_tile_with_actions.dart';
import '../models/flight.dart';

class FlightsListPage extends StatelessWidget {
  const FlightsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FlightModel(),
      child: Consumer<FlightModel>(
        builder: (ctx, model, _) {
          Widget content;
          if (model.loading) {
            content = const Center(child: CircularProgressIndicator());
          } else if (model.error != null) {
            content = Center(
              child: Text(model.error!, style: const TextStyle(color: Colors.red)),
            );
          } else if (model.flights.isEmpty) {
            content = Center(child: Text(Strings.of(ctx, 'noFlights')));
          } else {
            content = ListView.builder(
              itemCount: model.flights.length,
              itemBuilder: (_, i) {
                final f = model.flights[i];
                return ListTileWithActions(
                  title: '${f.departureCity} → ${f.destinationCity}',
                  subtitle:
                  '${DateFormat.jm().format(DateTime.parse(f.departTime))} - ${DateFormat.jm().format(DateTime.parse(f.arriveTime))}',
                  onEdit: () => _showForm(context, model, f),
                  onDelete: () async {
                    final ok = await showConfirmationDialog(
                        ctx, Strings.of(ctx, 'deleteFlightConfirm'));
                    if (ok) {
                      await model.delete(f);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(Strings.of(ctx, 'flightDeleted'))),
                      );
                    }
                  },
                );
              },
            );
          }

          return BaseScaffold(
            title: Strings.of(ctx, 'flightsTitle'),
            body: content,
            onFab: () => _showForm(context, model, null),
            helpAction: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                content: Text(Strings.of(context, 'flightHelp')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showForm(BuildContext ctx, FlightModel model, Flight? f) async {
    final isNew = f == null;
    final depCtl = TextEditingController(text: isNew ? '' : f!.departureCity);
    final dstCtl = TextEditingController(text: isNew ? '' : f!.destinationCity);
    DateTime depTime = isNew ? DateTime.now() : DateTime.parse(f.departTime);
    DateTime arrTime = isNew
        ? DateTime.now().add(const Duration(hours: 2))
        : DateTime.parse(f.arriveTime);
    final key = GlobalKey<FormState>();

    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title:
        Text(isNew ? Strings.of(ctx, 'addFlight') : Strings.of(ctx, 'editFlight')),
        content: Form(
          key: key,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: depCtl,
              decoration:
              InputDecoration(labelText: Strings.of(ctx, 'departureCity')),
              validator: (v) =>
              v!.isEmpty ? Strings.of(ctx, 'requiredField') : null,
            ),
            TextFormField(
              controller: dstCtl,
              decoration:
              InputDecoration(labelText: Strings.of(ctx, 'destinationCity')),
              validator: (v) =>
              v!.isEmpty ? Strings.of(ctx, 'requiredField') : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                      '${Strings.of(ctx, 'departureTime')}: ${DateFormat.jm().format(depTime)}'),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(depTime),
                    );
                    if (t != null) {
                      depTime = DateTime(depTime.year, depTime.month, depTime.day,
                          t.hour, t.minute);
                      (ctx as Element).markNeedsBuild();
                    }
                  },
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                      '${Strings.of(ctx, 'arrivalTime')}: ${DateFormat.jm().format(arrTime)}'),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(arrTime),
                    );
                    if (t != null) {
                      arrTime = DateTime(arrTime.year, arrTime.month, arrTime.day,
                          t.hour, t.minute);
                      (ctx as Element).markNeedsBuild();
                    }
                  },
                )
              ],
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(Strings.of(ctx, 'cancel'))),
          TextButton(
            onPressed: () async {
              if (!key.currentState!.validate()) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(Strings.of(ctx, 'fillAllFields'))));
                return;
              }
              final fNew = Flight(
                isNew ? Flight.ID++ : f!.id,
                depCtl.text,
                dstCtl.text,
                depTime.toIso8601String(),
                arrTime.toIso8601String(),
              );
              await (isNew ? model.add(fNew) : model.update(fNew));
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(isNew
                    ? Strings.of(ctx, 'flightAdded')
                    : Strings.of(ctx, 'flightUpdated')),
              ));
              Navigator.pop(ctx);
            },
            child: Text(
                isNew ? Strings.of(ctx, 'addFlight') : Strings.of(ctx, 'editFlight')),
          ),
        ],
      ),
    );
  }
}
