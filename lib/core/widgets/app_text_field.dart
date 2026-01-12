import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.prefixText,
    this.suffixText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLength,
  });

  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final String? prefixText;
  final String? suffixText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int? maxLength;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the field
        if (widget.labelText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.labelText,
              style: TextStyles.regular(AppColors.black),
            ),
          ),
        // Text field
        TextField(
          controller: widget.controller,
          obscureText: widget.obscureText ? _obscureText : false,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          enabled: widget.enabled,
          maxLength: widget.maxLength,
          style: TextStyles.regular(AppColors.black),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyles.regular(AppColors.grey),
            prefixText: widget.prefixText,
            suffixText: widget.suffixText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: Colors.grey[600],
                    size: 20,
                  )
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon != null
                    ? IconButton(
                        icon: Icon(
                          widget.suffixIcon,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: widget.onSuffixIconTap,
                      )
                    : null,
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey[300]!,
                width: hasError ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey[300]!,
                width: hasError ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.blue,
                width: hasError ? 2 : 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            counterText: widget.maxLength != null ? '' : null,
          ),
        ),
        // Error message below the field
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Text(
              widget.errorText!,
              style: TextStyles.regular(AppColors.errorRed),
            ),
          ),
      ],
    );
  }
}