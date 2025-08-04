import 'package:floor/floor.dart';

@entity
class Customer {
  @primaryKey
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final String dateOfBirth;

  static int ID = 1;

  Customer(this.id, this.firstName, this.lastName, this.address, this.dateOfBirth) {
    if (id >= ID) {
      ID = id + 1;
    }
  }
}
