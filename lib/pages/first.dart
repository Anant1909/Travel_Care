// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_care/constants/color.dart';
import 'package:travel_care/pages/gradient_button.dart';
import 'package:travel_care/pages/onboarding/onboarding1.dart';
import 'package:travel_care/pages/textfields.dart';

final pallatte = Pallatte();
class First extends StatefulWidget {
  const First({super.key});

  @override
  State<First> createState() => _FirstState();
}

class _FirstState extends State<First> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  bool _isLogging = false;
  bool _isObscure = true;

  Future<void> _signUp() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }
  setState(() {
    _isLogging = true;
  });

  try {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = userCredential.user;

    if (user != null) {
      // Store user details in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
      });
      // Navigate to Onboarding1 screen after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Onboarding1()),
      );
      if (kDebugMode) {
        print('User created successfully');
      }
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      // Email is already in use, handle it by attempting to link
      try {
        final user = await _auth.signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Onboarding1()),
          );
        }
      } on FirebaseAuthException catch (e) {
        // If sign-in fails, show error message
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
            content: Text(
              'This email is already in use, and the password is incorrect.',
              style:  TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
          ),
        );
      }
    } else if (e.code == 'weak-password') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password should be at least 6 characters long.',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.message}',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ),
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error creating user: $e');
    }
  } finally {
    setState(() {
      _isLogging = false;
    });
  }
}



  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient:  LinearGradient(
            colors: [
              pallatte.backgroundColor1,
              pallatte.backgroundColor2
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Welcome',
                    style: TextStyle(
                      color: Color(0xFFFFE4B5),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Textfield(
                  hintText: 'E-mail',
                  controller: emailController,
                  errorText: 'Please enter your email',
                ),
                const SizedBox(height: 15),
                Textfield(
                  hintText: 'Name',
                  controller: nameController,
                  errorText: 'Please enter your name',
                ),
                const SizedBox(height: 15),
                Textfield(
                  hintText: 'Password',
                  controller: passwordController,
                  errorText: 'Please enter your password',
                  obscureText: _isObscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // Display CircularProgressIndicator instead of the button if _isLogging is true
                _isLogging
                    ? Lottie.asset(
                                  'assets/animation/loading1.json',
                                  height: 80,
                                  width: 80,
                                )
                    : GradientButton(
                        buttonText: 'Launch Adventure',
                        onPressed: _signUp,
                      ),
                const SizedBox(height: 15),
                // GestureDetector(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => const Login()),
                //     );
                //   },
                //   child: RichText(
                //     text: TextSpan(
                //       text: 'Already have an account? ',
                //       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                //         color: const Color.fromARGB(255, 252, 206, 127),
                //       ),
                //       children: [
                //         TextSpan(
                //           text: 'Log In',
                //           style: Theme.of(context)
                //               .textTheme
                //               .titleMedium
                //               ?.copyWith(
                //                 color: const Color(0xFFFFE4B5),
                //                 fontWeight: FontWeight.bold,
                //               ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
