import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';

enum AppButtonVariant {
  solid,
  outlined,
}

enum AppButtonColor {
  blue,
  green,
  red,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.solid,
    this.color = AppButtonColor.blue,
    this.isLoading = false,
    this.width,
    this.height,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonColor color;
  final bool isLoading;
  final double? width;
  final double? height;

  Color get _backgroundColor {
    if (variant == AppButtonVariant.outlined) {
      return Colors.white;
    }
    switch (color) {
      case AppButtonColor.blue:
        return AppColors.primaryBlue;
      case AppButtonColor.green:
        return AppColors.trueGreen;
      case AppButtonColor.red:
        return AppColors.errorRed;
    }
  }

  Color get _borderColor {
    switch (color) {
      case AppButtonColor.blue:
        return AppColors.primaryBlue;
      case AppButtonColor.green:
        return AppColors.trueGreen;
      case AppButtonColor.red:
        return AppColors.errorRed;
    }
  }

  Color get _textColor {
    if (variant == AppButtonVariant.outlined) {
      return _borderColor;
    }
    return Colors.white;
  }

  Color get _oyuColor {
    if (variant == AppButtonVariant.outlined) {
      // Light pastel color matching the border
      switch (color) {
        case AppButtonColor.blue:
          return Colors.white;
        case AppButtonColor.green:
          return Colors.white;
        case AppButtonColor.red:
          return Colors.white;
      }
    } else {
      // Darker shade for solid buttons - creates texture effect
      switch (color) {
        case AppButtonColor.blue:
          return const Color(0xFF0066CC); // Darker blue
        case AppButtonColor.green:
          return const Color(0xFF2AA048); // Darker green
        case AppButtonColor.red:
          return const Color(0xFFCC0004); // Darker red
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 56;
    final buttonWidth = width ?? double.infinity;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: buttonWidth,
        height: buttonHeight,
        child: TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: _backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: variant == AppButtonVariant.outlined
                  ? BorderSide(color: _borderColor, width: 2)
                  : BorderSide.none,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Oyu pattern background - larger than button to show edges
              Positioned(
                left: -100,
                top: -100,
                right: -100,
                bottom: -100,
                child: Opacity(
                  opacity: variant == AppButtonVariant.outlined ? 1.0 : 0.6,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    child: SvgPicture.asset(
                      'assets/images/oyu.svg',
                      fit: BoxFit.cover,
                      width: buttonWidth + 200,
                      height: buttonHeight + 200,
                    ),
                  ),
                ),
              ),
              // Button content
              Center(
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                        ),
                      )
                    : Text(
                        text,
                        style: TextStyles.bold(_textColor),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
