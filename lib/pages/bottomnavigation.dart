import 'package:flutter/material.dart';
import 'package:travel_care/pages/flightstatus.dart';
import 'package:travel_care/pages/homescreen.dart';
import 'package:travel_care/pages/hotels.dart';
import 'package:travel_care/pages/itinerary.dart';
import 'package:travel_care/pages/translation_screen.dart';



class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>  const TranslationScreen(),
        ));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const ItineraryScreen(),
        ));
        break;
      case 2:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const Homescreen(),
        ));
        break;
      case 3:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const FlightStatus(),
        ));
      case 4:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>  HotelScreen(),
        ));
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xFF008080), 
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.text_fields),
              label: 'Translation',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Itinerary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
          BottomNavigationBarItem(
              icon: Icon(Icons.flight),
              label: 'Flights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hotel),
              label: 'Stays',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color.fromARGB(255, 255, 24, 3), 
          unselectedItemColor: Colors.black,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedIconTheme: const IconThemeData(
            size: 30, 
          ),
          unselectedIconTheme: const IconThemeData(
            size: 24, 
          ),
        ),
      );
  }
}