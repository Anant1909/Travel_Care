import 'package:flutter/material.dart';
import 'package:travel_care/constants/color.dart';

class GradientButton extends StatelessWidget {
GradientButton({super.key, required this.buttonText, this.onPressed});
  final String buttonText;
  final VoidCallback? onPressed;
  final pallatte = Pallatte();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:  LinearGradient(
          colors: [
            pallatte.buttonColor1,
            pallatte.buttonColor2
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(395, 55),
          backgroundColor: Colors.transparent,
          elevation: 0, // Remove default elevation
          shadowColor: Colors.transparent, // Remove shadow color
          surfaceTintColor: Colors.transparent, // Ensure no shadow on press
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Color.fromARGB(255, 1, 0, 66),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
