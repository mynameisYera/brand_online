import 'package:flutter/material.dart';

class ButtonWidget extends StatefulWidget {
  final Widget widget;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;
  final Color? borderColor;
  final bool isLoading;
  const ButtonWidget({super.key, required this.widget, required this.color, required this.textColor, required this.onPressed, this.borderColor, this.isLoading = false});

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.borderColor ?? Colors.transparent),
        ),
        child: Center(child: widget.isLoading ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: widget.textColor,)) : widget.widget),
      ),
    );
  }
}