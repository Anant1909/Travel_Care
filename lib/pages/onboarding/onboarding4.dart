import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_care/constants/color.dart';
import 'package:travel_care/pages/gradient_button.dart';
import 'package:travel_care/pages/onboarding/onboarding5.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Get the user ID from Firebase Authentication
String? userId = FirebaseAuth.instance.currentUser?.uid; // Ensure the user is logged in


final pallatte = Pallatte();
class Onboarding4 extends StatefulWidget {
  const Onboarding4({super.key});

  @override
  _Onboarding4State createState() => _Onboarding4State();
}

class _Onboarding4State extends State<Onboarding4> {
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
                        'Which type of accommodation do you prefer during your travels?',
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
                            _buildOptionTile('5-Star'),
                            _buildOptionTile('4-Star'),
                            _buildOptionTile('3-Star'),
                            _buildOptionTile('Below 3-Star'),
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
                    _saveResponsesToFirestore('Onboarding4'); // Call the function to save responses
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Onboarding5(),
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
  Future<void> _saveResponsesToFirestore(String screenName) async {
  if (userId == null) {
    print("User is not authenticated");
    return;
  }

  // Create a reference to the Firestore collection and document based on user ID
  DocumentReference userDoc = _firestore.collection('user_responses').doc(userId);

  // Save or update the selected options for a particular screen
  try {
    await userDoc.set({
      screenName: _selectedOptions.toList(), // Save the current screen's options
      'timestamp': FieldValue.serverTimestamp(), // Optionally, store the timestamp
    }, SetOptions(merge: true)); // Merge with existing data to avoid overwriting other screen responses
    print("Responses saved successfully");
  } catch (e) {
    print("Error saving responses: $e");
  }
}
}
