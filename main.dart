import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'constants/themes.dart';
import 'constants/strings.dart';
import 'localization/app_localizations.dart';

// Pages
import 'pages/flights_list_page.dart';
import 'pages/reservation_page.dart';
import 'pages/customer_list_page.dart';
import 'pages/airplane_list_page.dart';

/// Entry point of the application.
void main() {
  runApp(const FlightManagerApp());
}

class FlightManagerApp extends StatelessWidget {
  const FlightManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Manager',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  static const _pages = [
    FlightsListPage(),
    ReservationPage(),
    CustomerListPage(),
    AirplaneListPage(),
  ];

  void _onItemTapped(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.flight),
            label: Strings.of(context, 'flightsTitle'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book_online),
            label: Strings.of(context, 'reservationsTitle'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: Strings.of(context, 'customersTitle'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.airplanemode_active),
            label: Strings.of(context, 'airplanesTitle'),
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
