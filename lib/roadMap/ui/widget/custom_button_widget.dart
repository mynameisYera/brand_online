import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final Color color;
  final String text;
  final Color? textColor;
  final VoidCallback onTap;
  const CustomButtonWidget({super.key, required this.color, required this.text, this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: textColor ?? Colors.white),
          color: color
        ),
        child: Center(
          child: Text(text, style: TextStyle(fontSize: 24, color: textColor ?? Colors.white),)
        ),
      )
    );
  }
}