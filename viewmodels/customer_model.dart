import 'package:flutter/foundation.dart';
import '../data/database.dart';
import '../dao/customer_dao.dart';
import '../models/customer.dart';

class CustomerModel extends ChangeNotifier {
  late final CustomerDao _dao;
  List<Customer> customers = [];
  bool loading = false;
  String? error;
  bool ready = false;

  CustomerModel() {
    _init();
  }

  Future<void> _init() async {
    final db = await $FloorAppDatabase.databaseBuilder('flight_manager.db').build();
    _dao = db.customerDao;
    ready = true;
    await loadAll();
  }

  Future<void> loadAll() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      customers = await _dao.findAllCustomers();
    } catch (e) {
      error = 'Failed to load customers: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Customer?> findById(int id) async {
    try {
      return await _dao.findCustomerById(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(Customer c) async => _wrap(() => _dao.insertCustomer(c));
  Future<void> update(Customer c) async => _wrap(() => _dao.updateCustomer(c));
  Future<void> delete(Customer c) async => _wrap(() => _dao.deleteCustomer(c));

  Future<void> _wrap(Future<void> Function() op) async {
    try {
      await op();
      await loadAll();
    } catch (e) {
      error = 'Database error: $e';
      notifyListeners();
    }
  }
}
