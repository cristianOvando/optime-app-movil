import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color color;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final BorderSide? borderSide;
  final List<BoxShadow>? boxShadow;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const MyButton({
    super.key,
    required this.onTap,
    required this.buttonText,
    this.width,
    this.height,
    this.borderRadius = 10.0,
    this.color = const Color.fromARGB(255, 22, 123, 206),
    this.textColor = Colors.white,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.bold,
    this.borderSide,
    this.boxShadow,
    this.textStyle,
    this.padding = const EdgeInsets.all(13),
    this.margin = const EdgeInsets.symmetric(horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderSide != null
              ? Border.fromBorderSide(borderSide!)
              : null,
          boxShadow: boxShadow,
        ),
        child: Center(
          child: Text(
            buttonText,
            style: textStyle ??
                TextStyle(
                  color: textColor,
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                ),
          ),
        ),
      ),
    );
  }
}
