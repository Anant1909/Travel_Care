import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_care/constants/color.dart';
import 'package:travel_care/pages/gradient_button.dart';
import 'package:travel_care/pages/onboarding/onboarding2.dart';

final pallatte = Pallatte();
class Onboarding1 extends StatefulWidget {
  const Onboarding1({super.key});

  @override
  _Onboarding1State createState() => _Onboarding1State();
}

class _Onboarding1State extends State<Onboarding1> {
  // Variable to track the selected options
  final Set<String> _selectedOptions = {};

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              pallatte.backgroundColor1,
              pallatte.backgroundColor2
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
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
                leading: null,
              ),
              const SizedBox(height: 40),
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
                      child: const Text(
                        'What’s your primary goal for using our travel app?',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: <Widget>[
                            _buildOptionTile('Find the best flight deals'),
                            _buildOptionTile('Generate customized travel itineraries'),
                            _buildOptionTile('Get real-time flight updates and delays'),
                            _buildOptionTile('Translate travel-related text and conversations'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: GradientButton(
                  buttonText: 'Next',
                  onPressed: () {
                    _saveResponsesToFirestore();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Onboarding2(),
                    ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title) {
    bool isSelected = _selectedOptions.contains(title);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.teal.shade100 : const Color.fromARGB(255, 247, 240, 229),
        border: Border.all(color: Colors.teal, width: 2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.zero,
          bottomRight: Radius.circular(20),
          topLeft: Radius.circular(20),
          topRight: Radius.zero,
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedOptions.remove(title);
            } else {
              _selectedOptions.add(title);
            }
          });
        },
      ),
    );
  }

  // Function to save responses to Firestore
  Future<void> _saveResponsesToFirestore() async {
    // Create a reference to the Firestore collection
    CollectionReference responses = _firestore.collection('user_responses');

    // Save the selected options
    try {
      await responses.add({
        'selected_options': _selectedOptions.toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Responses saved successfully");
    } catch (e) {
      print("Error saving responses: $e");
    }
  }
}
