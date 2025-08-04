import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/strings.dart';
import '../viewmodels/customer_model.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/list_tile_with_actions.dart';
import '../models/customer.dart';
import '../utils/encrypted_prefs_helper.dart';
import '../constants/themes.dart';

class CustomerListPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  const CustomerListPage({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerModel(),
      child: Consumer<CustomerModel>(
        builder: (ctx, model, _) {
          Widget content;
          if (model.loading) {
            content = const Center(child: CircularProgressIndicator());
          } else if (model.error != null) {
            content = Center(
              child: Text(
                model.error!,
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            );
          } else if (model.customers.isEmpty) {
            content = const Center(
              child: Text(
                'No customers yet.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          } else {
            content = ListView.builder(
              itemCount: model.customers.length,
              itemBuilder: (_, i) {
                final c = model.customers[i];
                return Card(
                  color: isDarkMode
                      ? AppThemes.darkBrown.withOpacity(0.85)
                      : Colors.white,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTileWithActions(
                    title: '${c.firstName} ${c.lastName}',
                    subtitle:
                    '${c.address} • ${DateFormat.yMMMd().format(DateTime.parse(c.dateOfBirth))}',
                    onEdit: () => _showForm(context, model, c),
                    onDelete: () async {
                      final ok = await showConfirmationDialog(
                          ctx, 'Delete this customer?');
                      if (ok) {
                        await model.delete(c);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: const Text('Customer deleted'),
                            backgroundColor: AppThemes.darkYellow,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          }

          return BaseScaffold(
            title: 'Customers',
            body: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/customers.png', // your customer-themed background
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.4), // dark overlay for text readability
                ),
                content,
              ],
            ),
            onFab: () => _showForm(context, model, null),
            helpAction: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                    '${Strings.of(context, 'customersTitle')} Help',
                    style: TextStyle(
                      color: AppThemes.darkYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(Strings.of(context, 'customerHelp')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        Strings.of(context, 'ok'),
                        style: TextStyle(color: AppThemes.darkYellow),
                      ),
                    ),
                  ],
                ),
              );
            },
            toggleTheme: toggleTheme,
            isDarkMode: isDarkMode,
          );
        },
      ),
    );
  }

  Future<void> _showForm(
      BuildContext ctx, CustomerModel model, Customer? c) async {
    final isNew = c == null;
    final prefs = EncryptedPrefsHelper();
    final firstCtl = TextEditingController(text: isNew ? '' : c!.firstName);
    final lastCtl = TextEditingController(text: isNew ? '' : c!.lastName);
    final addrCtl = TextEditingController(text: isNew ? '' : c!.address);
    DateTime dob =
    isNew ? DateTime.now() : DateTime.tryParse(c!.dateOfBirth) ?? DateTime.now();
    final key = GlobalKey<FormState>();

    await showDialog(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
        title: Row(
          children: [
            Expanded(
              child: Text(
                isNew ? 'Add Customer' : 'Edit Customer',
                style: TextStyle(
                  color: AppThemes.darkYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isNew)
              IconButton(
                icon: Icon(Icons.copy, color: AppThemes.darkYellow),
                tooltip: 'Copy Last',
                onPressed: () async {
                  final lastData = await prefs.loadLast(
                    'last_customer',
                    ['firstName', 'lastName', 'address', 'dateOfBirth'],
                  );
                  firstCtl.text = lastData['firstName'] ?? '';
                  lastCtl.text = lastData['lastName'] ?? '';
                  addrCtl.text = lastData['address'] ?? '';
                  if (lastData['dateOfBirth'] != null) {
                    dob = DateTime.tryParse(lastData['dateOfBirth']!) ?? dob;
                  }
                  (ctx as Element).markNeedsBuild();
                },
              ),
          ],
        ),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: firstCtl,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(v)) {
                    return 'Only letters allowed';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: lastCtl,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(v)) {
                    return 'Only letters allowed';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: addrCtl,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text('Date of Birth: ${DateFormat.yMd().format(dob)}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today,
                        color: AppThemes.darkYellow),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: dob,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        dob = picked;
                        (ctx as Element).markNeedsBuild();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: AppThemes.darkYellow)),
          ),
          TextButton(
            onPressed: () async {
              if (!key.currentState!.validate()) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Fill all fields')),
                );
                return;
              }
              final newCustomer = Customer(
                isNew ? Customer.ID++ : c!.id,
                firstCtl.text,
                lastCtl.text,
                addrCtl.text,
                dob.toIso8601String(),
              );
              if (isNew) {
                await model.add(newCustomer);
                await prefs.saveLast('last_customer', {
                  'firstName': firstCtl.text,
                  'lastName': lastCtl.text,
                  'address': addrCtl.text,
                  'dateOfBirth': dob.toIso8601String(),
                });
              } else {
                await model.update(newCustomer);
              }
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content:
                  Text(isNew ? 'Customer added' : 'Customer updated'),
                  backgroundColor: AppThemes.darkYellow,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: Text(
              isNew ? 'Add Customer' : 'Edit Customer',
              style: TextStyle(color: AppThemes.darkYellow),
            ),
          ),
        ],
      ),
    );
  }
}
