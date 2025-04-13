import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum LoadingSize {
  small,
  medium,
  large,
}

class LoadingIndicator extends StatelessWidget {
  final LoadingSize size;
  final Color color;
  final String? message;
  
  const LoadingIndicator({
    Key? key,
    this.size = LoadingSize.medium,
    this.color = AppColors.primary,
    this.message,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: _getSize(),
            height: _getSize(),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: _getStrokeWidth(),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
  
  double _getSize() {
    switch (size) {
      case LoadingSize.small:
        return 24.0;
      case LoadingSize.medium:
        return 40.0;
      case LoadingSize.large:
        return 56.0;
    }
  }
  
  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2.0;
      case LoadingSize.medium:
        return 3.0;
      case LoadingSize.large:
        return 4.0;
    }
  }
}

class FullScreenLoading extends StatelessWidget {
  final String? message;
  final Color backgroundColor;
  
  const FullScreenLoading({
    Key? key,
    this.message,
    this.backgroundColor = Colors.white70,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: LoadingIndicator(
        size: LoadingSize.large,
        message: message,
      ),
    );
  }
}