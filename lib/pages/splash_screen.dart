// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_care/pages/first.dart';
import 'package:travel_care/pages/signup.dart';


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 5));

    Navigator. pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const First(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,


      body: SafeArea(


        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
      
            Lottie.asset(
              'assets/animation/splash.json',
              height: 400,
            ),
          ],
        ),
      ),
    );
  }
}
