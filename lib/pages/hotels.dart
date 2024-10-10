import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_care/constants/color.dart';
import 'package:travel_care/pages/gradient_button.dart';
import 'package:travel_care/pages/homescreen.dart';

final pallatte = Pallatte();
class HotelScreen extends StatefulWidget {
  const HotelScreen({super.key});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();

  bool _isLoading = false;
  bool _hasGenerated = false;
  List<Map<String, dynamic>> _hotelDetails = [];
  // Map<String, dynamic> userPreferences = {}; // Store user preferences here

  

  // Future<void> _fetchUserPreferences() async {
  //   // Fetch user responses from Firestore or other local storage
  //   DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('user_responses').doc(userId).get();
  //   setState(() {
  //     userPreferences = snapshot.data() as Map<String, dynamic>;
  //   });
  // }

  // void _fetchHotelData() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final hotelService = HotelService('your_api_key_here');
  //     _hotelDetails = await hotelService.generateHotelsBasedOnPreferences(userPreferences);
  //     _isLoading = false;
  //     _hasGenerated = true;
  //   } catch (e) {
  //     _showErrorDialog('Failed to fetch hotel data: ${e.toString()}');
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }


  @override
  void initState() {
      // _fetchUserPreferences();
    super.initState();
      _controller = AnimationController(vsync: this,duration: const Duration(seconds: 6));
    _topAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topLeft, end:Alignment.topRight), 
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topLeft, end:Alignment.bottomRight), 
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
        weight: 1,
        )
      ],
      ).animate(_controller);

      _controller.repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime currentDate = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  void _fetchHotelData() {
    List<Map<String, dynamic>> randomHotels = [
      {
        'name': 'Sunrise Resort',
        'rating': 4.5,
        'facilities': ['Free WiFi', 'Swimming Pool', 'Breakfast Included'],
        'phone': '+1 234 567 890',
        'type': 'Resort',
      },
      {
        'name': 'City Center Hotel',
        'rating': 4.0,
        'facilities': ['Gym', 'Airport Shuttle', 'Restaurant'],
        'phone': '+1 987 654 321',
        'type': 'Hotel',
      },
      {
        'name': 'Mountain View Hostel',
        'rating': 3.8,
        'facilities': ['Shared Kitchen', 'Free Parking', 'Lounge'],
        'phone': '+1 555 123 456',
        'type': 'Hostel',
      },
      {
        'name': 'Heritage Inn',
        'rating': 4.2,
        'facilities': ['Gym', 'Spa', 'Free Breakfast'],
        'phone': '+1 444 789 101',
        'type': 'Resort',
      },
      {
        'name': 'Lakeside Bungalows',
        'rating': 4.3,
        'facilities': ['Lake View', 'Free Breakfast', 'Outdoor Sports'],
        'phone': '+1 123 456 789',
        'type': 'Resort',
      },
      {
        'name': 'Downtown Hostel',
        'rating': 3.6,
        'facilities': ['Free WiFi', 'Shared Kitchen', 'Lounge Area'],
        'phone': '+1 987 123 654',
        'type': 'Hostel',
      },
      {
        'name': 'Green Valley Lodge',
        'rating': 4.7,
        'facilities': ['Mountain View', 'Spa', 'Restaurant'],
        'phone': '+1 789 456 321',
        'type': 'Hotel',
      },
      {
        'name': 'Seaside Retreat',
        'rating': 4.8,
        'facilities': ['Private Beach', 'Spa', 'Free Breakfast'],
        'phone': '+1 654 321 987',
        'type': 'Resort',
      },
      {
        'name': 'Budget Inn',
        'rating': 3.9,
        'facilities': ['Free WiFi', 'Parking', 'Free Breakfast'],
        'phone': '+1 456 789 123',
        'type': 'Hotel',
      },
      {
        'name': 'Luxury Palace',
        'rating': 5.0,
        'facilities': ['Private Pool', 'Butler Service', 'Spa'],
        'phone': '+1 321 654 987',
        'type': 'Resort',
      },
    ];

    setState(() {
      _hotelDetails = List.generate(4, (index) => randomHotels[Random().nextInt(randomHotels.length)]);
      _isLoading = false;
      _hasGenerated = true;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Widget _buildStars(double rating) {
    int fullStars = rating.floor(); 
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    List<Widget> stars = [];

    // Add full stars
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber));
    }

    // Add half star if applicable
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber));
    }

    // Add empty stars to complete 5 stars
    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber));
    }

    return Row(
      children: stars,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _topAlignmentAnimation.value,
                end: _bottomAlignmentAnimation.value,
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
                    'Stay Search',
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
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: const Color(0xFFFFE4B5),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const Homescreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: <Widget>[
                      _buildLocationField(),
                      const SizedBox(height: 10),
                      _buildCheckInField(),
                      const SizedBox(height: 10),
                      _buildCheckOutField(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: GradientButton(
                    buttonText: 'Search',
                    onPressed: () {
                      if (_locationController.text.isEmpty ||
                          _checkInController.text.isEmpty ||
                          _checkOutController.text.isEmpty) {
                        _showErrorDialog('Please fill in all required fields.');
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      _fetchHotelData();
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? Center(
                      child: Lottie.asset(
                                    'assets/animation/loading1.json',
                                    height: 80,
                                    width: 80,
                                  ),
                    )
                    : _hasGenerated
                        ? Expanded(
                            child: ListView.builder(
                              itemCount: _hotelDetails.length,
                              itemBuilder: (context, index) {
                                final hotel = _hotelDetails[index];
                                return buildHotelCard(hotel);
                              },
                            ),
                          )
                        : const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationField() {
    return Container(
      decoration: _inputDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location*',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInField() {
    return Container(
      decoration: _inputDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _checkInController,
          readOnly: true,
          onTap: () => _selectDate(context, _checkInController),
          decoration: const InputDecoration(
            labelText: 'Check-in Date*',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckOutField() {
    return Container(
      decoration: _inputDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _checkOutController,
          readOnly: true,
          onTap: () => _selectDate(context, _checkOutController),
          decoration: const InputDecoration(
            border: InputBorder.none,
            labelText: 'Check-out Date*',
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: const Color.fromARGB(255, 247, 240, 229),
      border: Border.all(),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.zero,
        bottomRight: Radius.circular(20),
        topLeft: Radius.circular(20),
        topRight: Radius.zero,
      ),
    );
  }

  Widget buildHotelCard(Map<String, dynamic> hotel) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${hotel['name']} (${hotel['type']})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildStars(hotel['rating']),
            const SizedBox(height: 10),
            Text(
              'Facilities: ${hotel['facilities'].join(', ')}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              'Phone: ${hotel['phone']}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
  
}
// class HotelService {
//   final GenerativeModel _model;

//   HotelService(String apiKey)
//       : _model = GenerativeModel(
//           model: 'gemini-1.5-flash',
//           apiKey: apiKey,
//         );

//   Future<List<Map<String, dynamic>>> generateHotelsBasedOnPreferences(Map<String, dynamic> userPreferences) async {
//     String preferencesDescription = userPreferences.entries.map((e) => '${e.key}: ${e.value}').join(', ');

//     final prompt = "Generate hotel data based on the following user preferences: $preferencesDescription. Provide a list of hotels with names, ratings, types, facilities, and contact numbers.";

//     final response = await _model.generateContent([Content.text(prompt)]);

//     if (response.error != null) {
//       throw Exception('Failed to generate hotel data: ${response.error!.message}');
//     }

//     final hotelData = response.text; // Expecting a JSON formatted response
//     print("Raw hotel data response: $hotelData"); // Debugging line
//     return parseHotelData(hotelData);
//   }

//   List<Map<String, dynamic>> parseHotelData(String hotelData) {
//     try {
//       // Parse the generated hotel data (JSON string) into a List<Map<String, dynamic>>
//       return List<Map<String, dynamic>>.from(jsonDecode(hotelData));
//     } catch (e) {
//       throw Exception('Failed to parse hotel data: $e');
//     }
//   }
// }
