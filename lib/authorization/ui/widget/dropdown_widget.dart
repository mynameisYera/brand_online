import 'package:flutter/material.dart';
import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.labelText,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.prefixIcon,
    this.errorText,
    this.enabled = true,
  });

  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final IconData? prefixIcon;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the dropdown
        if (labelText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              labelText,
              style: TextStyles.regular(AppColors.black),
            ),
          ),
        // Dropdown field
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? AppColors.errorRed : Colors.grey[300]!,
              width: hasError ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                if (prefixIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(
                      prefixIcon,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                Expanded(
                  child: DropdownButton<T>(
                    value: value,
                    onChanged: enabled ? onChanged : null,
                    items: items,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: AppColors.primaryBlue,
                    ),
                    hint: hintText != null
                        ? Text(
                            hintText!,
                            style: TextStyles.regular(AppColors.grey),
                          )
                        : null,
                    style: TextStyles.medium(AppColors.black),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    menuMaxHeight: 200,
                    iconSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Error message below the dropdown
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Text(
              errorText!,
              style: TextStyles.regular(AppColors.errorRed),
            ),
          ),
      ],
    );
  }
}
