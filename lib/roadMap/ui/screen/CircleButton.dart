import 'package:flutter/material.dart';

class CircularButton extends StatefulWidget {
  final String imagePath;
  final bool checked;
  final int index;
  final ValueChanged<bool> onCheckedChanged;
  final Color customColor;

  const CircularButton({
    Key? key,
    required this.imagePath,
    required this.checked,
    required this.index,
    required this.onCheckedChanged,
    required this.customColor,
  }) : super(key: key);

  @override
  _CircularButtonState createState() => _CircularButtonState();
}

class _CircularButtonState extends State<CircularButton> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.checked;
  }

  @override
  void didUpdateWidget(CircularButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.checked != widget.checked) {
      _isChecked = widget.checked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isChecked ? Colors.grey : widget.customColor,
        boxShadow: [
          BoxShadow(
            color: _isChecked
                ? Colors.grey.withOpacity(0.4)
                : widget.customColor.withOpacity(0.4),
            offset: Offset(0, 10),
            blurRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
          child: Image.asset(
            widget.imagePath,
            width: 40,
            height: 40,
          ),
        ),
      ),
    );
  }
}
