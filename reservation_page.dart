import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/strings.dart';
import '../viewmodels/reservation_model.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/list_tile_with_actions.dart';
import '../utils/encrypted_prefs_helper.dart';
import '../models/reservation.dart';

class ReservationPage extends StatelessWidget {
  const ReservationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReservationModel()..loadAll(),
      child: Consumer<ReservationModel>(
        builder: (ctx, model, _) {
          Widget content;
          if (model.loading) {
            content = const Center(child: CircularProgressIndicator());
          } else if (model.error != null) {
            content = Center(
                child:
                Text(model.error!, style: const TextStyle(color: Colors.red)));
          } else if (model.reservations.isEmpty) {
            content = Center(child: Text(Strings.of(ctx, 'noReservations')));
          } else {
            content = ListView.builder(
              itemCount: model.reservations.length,
              itemBuilder: (_, i) {
                final r = model.reservations[i];
                return ListTileWithActions(
                  title:
                  '${r.name} — ${DateFormat.yMd().format(DateTime.parse(r.date))}',
                  subtitle: 'C:${r.customerId}  F:${r.flightId}',
                  onEdit: () => _showForm(ctx, model, r),
                  onDelete: () async {
                    final ok = await showConfirmationDialog(
                        ctx, Strings.of(ctx, 'deleteReservationConfirm'));
                    if (ok) {
                      await model.delete(r);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                            content: Text(
                                Strings.of(ctx, 'reservationDeleted'))),
                      );
                    }
                  },
                );
              },
            );
          }

          return BaseScaffold(
            title: Strings.of(ctx, 'reservationsTitle'),
            body: content,
            onFab: () => _showForm(ctx, model, null),
            helpAction: () => showDialog(
              context: ctx,
              builder: (_) => AlertDialog(
                content: Text(Strings.of(ctx, 'reservationHelp')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK'))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showForm(
      BuildContext ctx, ReservationModel model, Reservation? r) async {
    final isNew = r == null;
    final prefs = EncryptedPrefsHelper();

    final nameCtl = TextEditingController(text: isNew ? '' : r!.name);
    final custCtl = TextEditingController(
        text: isNew ? '' : r!.customerId.toString());
    final flightCtl = TextEditingController(
        text: isNew ? '' : r!.flightId.toString());

    DateTime date = isNew ? DateTime.now() : DateTime.parse(r!.date);
    final formKey = GlobalKey<FormState>();

    Future<void> copyLast() async {
      final saved = await prefs
          .loadLast('reservation', ['name', 'customerId', 'flightId']);
      nameCtl.text = saved['name']!;
      custCtl.text = saved['customerId']!;
      flightCtl.text = saved['flightId']!;
      (ctx as Element).markNeedsBuild();
    }

    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(isNew
                  ? Strings.of(ctx, 'addReservation')
                  : Strings.of(ctx, 'editReservation')),
            ),
            if (isNew)
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Copy Last',
                onPressed: copyLast,
              ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: custCtl,
              decoration:
              InputDecoration(labelText: Strings.of(ctx, 'customerId')),
              keyboardType: TextInputType.number,
              validator: (v) =>
              v!.isEmpty ? Strings.of(ctx, 'requiredField') : null,
            ),
            TextFormField(
              controller: flightCtl,
              decoration:
              InputDecoration(labelText: Strings.of(ctx, 'flightId')),
              keyboardType: TextInputType.number,
              validator: (v) =>
              v!.isEmpty ? Strings.of(ctx, 'requiredField') : null,
            ),
            TextFormField(
              controller: nameCtl,
              decoration: InputDecoration(
                  labelText: Strings.of(ctx, 'reservationName')),
              validator: (v) =>
              v!.isEmpty ? Strings.of(ctx, 'requiredField') : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                      '${Strings.of(ctx, 'reservationDate')}: ${DateFormat.yMd().format(date)}'),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final d = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100));
                    if (d != null) {
                      date = d;
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
              if (!formKey.currentState!.validate()) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(Strings.of(ctx, 'fillAllFields'))),
                );
                return;
              }
              final newRes = Reservation(
                isNew ? Reservation.ID++ : r!.id,
                nameCtl.text,
                int.parse(custCtl.text),
                int.parse(flightCtl.text),
                date.toIso8601String(),
              );
              await (isNew ? model.add(newRes) : model.update(newRes));
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(isNew
                      ? Strings.of(ctx, 'reservationAdded')
                      : Strings.of(ctx, 'reservationUpdated')),
                ),
              );
              Navigator.pop(ctx);
            },
            child: Text(isNew
                ? Strings.of(ctx, 'addReservation')
                : Strings.of(ctx, 'editReservation')),
          ),
        ],
      ),
    );
  }
}
