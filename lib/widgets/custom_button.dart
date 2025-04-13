import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  error,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height = 50,
    this.borderRadius = AppConstants.defaultRadius,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppConstants.defaultPadding,
      vertical: AppConstants.defaultPadding / 2,
    ),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: _buildButton(),
    );
  }
  
  Widget _buildButton() {
    switch (type) {
      case ButtonType.primary:
        return _buildElevatedButton(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        );
      case ButtonType.secondary:
        return _buildElevatedButton(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
        );
      case ButtonType.outline:
        return _buildOutlinedButton(
          foregroundColor: AppColors.primary,
          borderColor: AppColors.primary,
        );
      case ButtonType.text:
        return _buildTextButton(
          foregroundColor: AppColors.primary,
        );
      case ButtonType.error:
        return _buildElevatedButton(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.onError,
        );
    }
  }
  
  Widget _buildElevatedButton({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: AppConstants.defaultElevation,
      ),
      child: _buildButtonContent(foregroundColor),
    );
  }
  
  Widget _buildOutlinedButton({
    required Color foregroundColor,
    required Color borderColor,
  }) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        padding: padding,
        side: BorderSide(
          color: borderColor,
          width: AppConstants.defaultBorderWidth,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _buildButtonContent(foregroundColor),
    );
  }
  
  Widget _buildTextButton({
    required Color foregroundColor,
  }) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _buildButtonContent(foregroundColor),
    );
  }
  
  Widget _buildButtonContent(Color foregroundColor) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}