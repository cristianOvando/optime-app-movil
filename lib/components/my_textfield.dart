import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Function(String)? onChanged;
  final double? width; 
  final double? height; 
  final double borderRadius; 

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.onChanged,
    this.width, 
    this.height, 
    this.borderRadius = 10.0, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, 
      height: height, 
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius), 
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius), 
            borderSide: const BorderSide(color: Colors.black),
          ),
          fillColor: const Color.fromARGB(255, 248, 248, 248),
          filled: true,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color.fromARGB(255, 58, 58, 58)),
        ),
      ),
    );
  }
}
