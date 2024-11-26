import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Function(String)? onChanged;
  final double? width;
  final double? height;
  final double borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool toggleVisibility; 
  final String? Function(String?)? validator;
  final TextStyle? hintTextStyle;
  final TextStyle? textStyle;
  final BorderSide? enabledBorderSide;
  final BorderSide? focusedBorderSide;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputType? keyboardType; // NUEVO
  final List<TextInputFormatter>? inputFormatters; // NUEVO

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.onChanged,
    this.width,
    this.height,
    this.borderRadius = 10.0,
    this.prefixIcon,
    this.suffixIcon,
    this.toggleVisibility = false,
    this.validator,
    this.hintTextStyle,
    this.textStyle,
    this.enabledBorderSide,
    this.focusedBorderSide,
    this.fillColor = const Color.fromARGB(255, 248, 248, 248),
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 25.0),
    this.keyboardType, // NUEVO
    this.inputFormatters, // NUEVO
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured = widget.obscureText;
  }

  void togglePasswordVisibility() {
    setState(() {
      isObscured = !isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: widget.contentPadding,
      child: TextField(
        controller: widget.controller,
        obscureText: isObscured,
        onChanged: widget.onChanged,
        style: widget.textStyle,
        keyboardType: widget.keyboardType, // Configura el tipo de teclado
        inputFormatters: widget.inputFormatters, // Configura los inputFormatters
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: widget.enabledBorderSide ??
                const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: widget.focusedBorderSide ??
                const BorderSide(color: Colors.blue),
          ),
          fillColor: widget.fillColor,
          filled: true,
          hintText: widget.hintText,
          hintStyle: widget.hintTextStyle ??
              const TextStyle(color: Color.fromARGB(255, 58, 58, 58)),
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.toggleVisibility
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: togglePasswordVisibility,
                )
              : widget.suffixIcon,
        ),
      ),
    );
  }
}
