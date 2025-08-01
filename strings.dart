import 'package:flutter/widgets.dart';

class Strings {
  static const Map<String, String> _enUS = {
    // Flight
    'addFlight': 'Add Flight',
    'editFlight': 'Edit Flight',
    'departureCity': 'Departure City',
    'destinationCity': 'Destination City',
    'departureTime': 'Departure Time',
    'arrivalTime': 'Arrival Time',
    'flightHelp':
    'Enter departure & destination cities, pick times, then press Add.',
    'noFlights': 'No flights yet.',
    'flightsTitle': 'Flights',
    'flightAdded': 'Flight added',
    'flightUpdated': 'Flight updated',
    'flightDeleted': 'Flight deleted',
    'deleteFlightConfirm': 'Delete this flight?',

    // Reservation
    'addReservation': 'Add Reservation',
    'editReservation': 'Edit Reservation',
    'reservationName': 'Reservation Name',
    'customerId': 'Customer ID',
    'flightId': 'Flight ID',
    'reservationDate': 'Date',
    'reservationHelp':
    'Enter customer ID, flight ID, date and name, then press Add.',
    'reservationsTitle': 'Reservations',
    'noReservations': 'No reservations yet.',
    'reservationAdded': 'Reservation added',
    'reservationUpdated': 'Reservation updated',
    'reservationDeleted': 'Reservation deleted',
    'deleteReservationConfirm': 'Delete this reservation?',

    // Customers
    'addCustomer': 'Add Customer',
    'editCustomer': 'Edit Customer',
    'firstName': 'First Name',
    'lastName': 'Last Name',
    'address': 'Address',
    'dob': 'Date of Birth',
    'customersHelp':
    'This page lets you manage customers.\n\nTap the + button to add a new customer.\nTap a customer to edit.\nTap the trash icon to delete.',
    'customersTitle': 'Customers',
    'noCustomers': 'No customers yet.',
    'customerAdded': 'Customer added',
    'customerUpdated': 'Customer updated',
    'customerDeleted': 'Customer deleted',
    'deleteCustomerConfirm': 'Delete this customer?',

    // Airplanes
    'addAirplane': 'Add Airplane',
    'editAirplane': 'Edit Airplane',
    'type': 'Type (e.g., Boeing 747)',
    'passengers': 'Passengers',
    'maxSpeed': 'Max Speed (km/h)',
    'range': 'Range (km)',
    'airplanesHelp':
    'This page lets you manage airplanes.\n\nTap the + button to add a new airplane.\nTap an airplane to edit.\nTap the trash icon to delete.',
    'airplanesTitle': 'Airplanes',
    'noAirplanes': 'No airplanes yet.',
    'airplaneAdded': 'Airplane added',
    'airplaneUpdated': 'Airplane updated',
    'airplaneDeleted': 'Airplane deleted',
    'deleteAirplaneConfirm': 'Delete this airplane?',

    // General
    'fillAllFields': 'Please fill all fields',
    'requiredField': 'Required',
    'cancel': 'Cancel',
    'history': 'View History',
  };

  static const Map<String, String> _enGB = {
    ..._enUS,
  };

  static Map<String, String> localizedMap(Locale locale) {
    if (locale.countryCode == 'GB') return _enGB;
    return _enUS;
  }

  static String of(BuildContext ctx, String key) {
    final locale = Localizations.localeOf(ctx);
    return localizedMap(locale)[key] ?? key;
  }
}
