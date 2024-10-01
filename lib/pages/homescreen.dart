import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_care/constants/color.dart';
import 'package:travel_care/pages/bottomnavigation.dart';
import 'package:travel_care/pages/first.dart';
import 'package:travel_care/pages/flightstatus.dart';
import 'package:travel_care/pages/history.dart';
import 'package:travel_care/pages/hotels.dart';
import 'package:travel_care/pages/itinerary.dart';
import 'package:travel_care/pages/translation_screen.dart';
import 'package:url_launcher/url_launcher.dart';

final pallatte = Pallatte();

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;
  String userName = '';
  String userEmail = '';
  bool hasSpoken = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _checkFirstVisit();
    _controller = AnimationController(vsync: this,duration: const Duration(seconds: 4));
    _topAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topLeft, end:Alignment.topRight), 
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topRight, end:Alignment.bottomRight), 
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomRight, end:Alignment.bottomLeft), 
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomLeft, end:Alignment.topLeft), 
        weight: 1,
        )
      ],
      ).animate(_controller);

  _bottomAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomRight, end:Alignment.bottomLeft),
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomLeft, end:Alignment.topLeft),
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topLeft, end:Alignment.topRight),
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topRight, end:Alignment.bottomRight),
        weight: 1
        )
      ],
      ).animate(_controller);

      _controller.repeat();
  }
Future<void> _launchURL() async {
  final Uri url = Uri.parse('https://docs.google.com/forms/d/e/1FAIpQLSc1mOlVkQpKXBT-5Bs6M2IkNTclsi5rt3IuKiuvKl4N001jQg/viewform?usp=sf_link');
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}


  Future<void> _checkFirstVisit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasVisited = prefs.getBool('hasVisitedHomeScreen') ?? false;

  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data();
      if (userData != null) {
        setState(() {
          userName = userData['name'] ?? 'User';
          userEmail = userData['email'] ?? 'user@example.com';
        });
      }
    }
  }

  

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context,_) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin:_bottomAlignmentAnimation.value,
                end: _topAlignmentAnimation.value,
                colors: [pallatte.backgroundColor1, pallatte.backgroundColor2],
              ),
            ),
            child: Column(
              children: <Widget>[
                AppBar(
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text(
                    'Travel Care',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFE4B5),
                    ),
                  ),
                  leading: Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: const Icon(Icons.menu),
                        color: const Color(0xFFFFE4B5),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 205, 226, 226),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.zero,
                            bottomRight: Radius.circular(40),
                            topLeft: Radius.circular(40),
                            topRight: Radius.zero,
                          ),
                        ),
                        child: Text(
                          "Welcome, $userName! Fasten your seatbelt for an amazing journey with our AI-powered app. Whether it's about flight status, finding hotels, creating itineraries, or translating languages, we've got you covered. Enjoy your flight and let AI guide your way!",
                          style: const TextStyle(
                              fontFamily: 'OpenSans',
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: CarouselSlider(
                          items: <Widget>[
                            _buildCard('Flight Status', 'assets/images/logo2.jpeg'),
                            _buildCard('Itinerary Generator', 'assets/images/i.jpg'),
                            _buildCard('Language Translator', 'assets/images/l.jpg'),
                            _buildCard('Stays', 'assets/images/h.jpg'),
                          ],
                          options: CarouselOptions(
                            height: 400,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            autoPlay: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
            gradient: LinearGradient(
              begin:Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [pallatte.backgroundColor1, pallatte.backgroundColor2],
            ),
                        ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings_suggest, color: pallatte.drawerlogo),
              title: const Text('Suggestions'),
              onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const HistoryScreen(),
        ));
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: pallatte.drawerlogo),
              title: const Text('Help & Feedback'),
              onTap: () {
                      _launchURL();
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: pallatte.drawerlogo),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const First(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        if (title == 'Flight Status') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FlightStatus()),
          );
        } else if (title == 'Itinerary Generator') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ItineraryScreen()),
          );
        } else if (title == 'Language Translator') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TranslationScreen()),
          );
        } else if (title == 'Stays') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  HotelScreen()),
          );
        }
      },
      child: Card(
        color: const Color.fromARGB(255, 205, 226, 226),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
