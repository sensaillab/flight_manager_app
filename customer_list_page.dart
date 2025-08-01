import 'package:flutter/material.dart';
import '../data/database.dart';
import '../models/customer.dart';
import '../repositories/customer_repository.dart';
import '../utils/encrypted_prefs_helper.dart';
import '../widgets/confirmation_dialog.dart';
import '../constants/strings.dart';
import 'package:intl/intl.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({Key? key}) : super(key: key);

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  late CustomerRepository _repository;
  List<Customer> _customers = [];
  final _prefs = EncryptedPrefsHelper();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final db = await $FloorAppDatabase.databaseBuilder('app.db').build();
    _repository = CustomerRepository(db.customerDao);
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final list = await _repository.getAllCustomers();
    setState(() => _customers = list);
  }

  void _showForm({Customer? existing}) async {
    final pageContext = context;

    if (existing != null) {
      _firstNameController.text = existing.firstName;
      _lastNameController.text = existing.lastName;
      _addressController.text = existing.address;
      _dobController.text = existing.dateOfBirth;
    } else {
      // ✅ Clear all fields for new record
      _firstNameController.clear();
      _lastNameController.clear();
      _addressController.clear();
      _dobController.clear();
    }

    showDialog(
      context: pageContext,
      builder: (_) => AlertDialog(
        title: Text(Strings.of(pageContext,
            existing == null ? 'addCustomer' : 'editCustomer')),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration:
                InputDecoration(labelText: Strings.of(pageContext, 'firstName')),
              ),
              TextField(
                controller: _lastNameController,
                decoration:
                InputDecoration(labelText: Strings.of(pageContext, 'lastName')),
              ),
              TextField(
                controller: _addressController,
                decoration:
                InputDecoration(labelText: Strings.of(pageContext, 'address')),
              ),
              TextField(
                controller: _dobController,
                readOnly: true,
                decoration:
                InputDecoration(labelText: Strings.of(pageContext, 'dob')),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: pageContext,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
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
              if (_firstNameController.text.isEmpty ||
                  _lastNameController.text.isEmpty ||
                  _addressController.text.isEmpty ||
                  _dobController.text.isEmpty) {
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(content: Text(Strings.of(pageContext, 'fillAllFields'))),
                );
                return;
              }

              final customer = Customer(
                existing?.id ?? Customer.ID++,
                _firstNameController.text,
                _lastNameController.text,
                _addressController.text,
                _dobController.text,
              );

              if (existing == null) {
                await _repository.addCustomer(customer);
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(content: Text(Strings.of(pageContext, 'customerAdded'))),
                );
              } else {
                await _repository.updateCustomer(customer);
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(content: Text(Strings.of(pageContext, 'customerUpdated'))),
                );
              }

              await _loadCustomers(); // ✅ Refresh list immediately
              Navigator.pop(pageContext);
            },
            child: Text(Strings.of(pageContext,
                existing == null ? 'addCustomer' : 'editCustomer')),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Customer customer) async {
    final confirm = await showConfirmationDialog(
      context,
      Strings.of(context, 'deleteCustomerConfirm'),
    );
    if (confirm) {
      await _repository.deleteCustomer(customer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.of(context, 'customerDeleted'))),
      );
      _loadCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context, 'customersTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(Strings.of(context, 'customersTitle')),
                  content: Text(Strings.of(context, 'customersHelp')),
                ),
              );
            },
          ),
        ],
      ),
      body: _customers.isEmpty
          ? Center(child: Text(Strings.of(context, 'noCustomers')))
          : RefreshIndicator(
        onRefresh: _loadCustomers,
        child: ListView.builder(
          itemCount: _customers.length,
          itemBuilder: (context, index) {
            final c = _customers[index];
            return ListTile(
              title: Text('${c.firstName} ${c.lastName}'),
              subtitle: Text(
                  '${c.address} • ${Strings.of(context, 'dob')}: ${c.dateOfBirth}'),
              onTap: () => _showForm(existing: c),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(c),
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
