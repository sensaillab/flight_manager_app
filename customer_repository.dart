import '../dao/customer_dao.dart';
import '../models/customer.dart';

class CustomerRepository {
  final CustomerDao _dao;

  CustomerRepository(this._dao);

  Future<List<Customer>> getAllCustomers() => _dao.findAllCustomers();
  Future<void> addCustomer(Customer customer) => _dao.insertCustomer(customer);
  Future<void> updateCustomer(Customer customer) => _dao.updateCustomer(customer);
  Future<void> deleteCustomer(Customer customer) => _dao.deleteCustomer(customer);
}
