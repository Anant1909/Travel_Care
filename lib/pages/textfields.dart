import 'package:flutter/material.dart';

class Textfield extends StatelessWidget {
  const Textfield({
    super.key,
    required this.hintText,
    required this.controller,
    required this.errorText,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final String errorText;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 247, 240, 229),
        border: Border.all(),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.zero,
          bottomRight: Radius.circular(20),
          topLeft: Radius.circular(20),
          topRight: Radius.zero,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorText;
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.all(27),
          border: InputBorder.none,
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.zero,
              bottomRight: Radius.circular(20),
              topLeft: Radius.circular(20),
              topRight: Radius.zero,
            ),
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.zero,
              bottomRight: Radius.circular(20),
              topLeft: Radius.circular(20),
              topRight: Radius.zero,
            ),
            borderSide: BorderSide(color: Colors.teal, width: 2.0),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
