import '../dao/customer_dao.dart';
import '../models/customer.dart';

class CustomerRepository {
  final CustomerDao dao;

  CustomerRepository(this.dao);

  Future<List<Customer>> getAllCustomers() => dao.findAllCustomers();
  Future<void> addCustomer(Customer customer) => dao.insertCustomer(customer);
  Future<void> updateCustomer(Customer customer) => dao.updateCustomer(customer);
  Future<void> deleteCustomer(Customer customer) => dao.deleteCustomer(customer);
}
