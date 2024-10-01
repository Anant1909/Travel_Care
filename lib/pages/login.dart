// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:travel_care/constants/color.dart';
import 'package:travel_care/firebase_auth.dart';
import 'package:travel_care/pages/gradient_button.dart';
import 'package:travel_care/pages/onboarding/onboarding1.dart';
import 'package:travel_care/pages/signup.dart';
import 'package:travel_care/pages/textfields.dart';

final pallatte = Pallatte();

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscure = true;

  // Login function
  Future<void> _logIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      User? user = await _auth.signInWithEmailAndPassword( email,password);
print('Email: $email, Password: $password');

      if (user != null) {
        Fluttertoast.showToast(
          msg: 'Login Successful',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Onboarding1()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid email or password',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      } else {
        errorMessage = 'Error: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.white,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during login: $e'),
          backgroundColor: Colors.white,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  void dispose(){
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }


  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              pallatte.backgroundColor1,
              pallatte.backgroundColor2,
            ],
          ),
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
                    'Log In',
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
                  controller: _emailController,
                  errorText: 'Please enter the correct email',
                  suffixIcon: null,
                ),
                const SizedBox(height: 15),
                Textfield(
                  hintText: 'Password',
                  controller: _passwordController,
                  errorText: 'Please enter the correct password',
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
                GradientButton(
                  buttonText: _isLoading ? 'Logging in...' : 'Log In',
                  onPressed: _isLoading ? null : logIn,
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SignUp(),
                    ));
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color.fromARGB(255, 252, 206, 127),
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFFFE4B5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
Future<void> logIn() async {
String email = _emailController.text;
String password = _passwordController.text;  

  User? user = await _auth.signInWithEmailAndPassword(email, password);

  if (user != null) {
    if (kDebugMode) {
      print('User Login Successfully');
    }
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const Onboarding1())
    );
  } else {
    if (kDebugMode) {
      print('Some Error Occurred');
    }
  }
}
}