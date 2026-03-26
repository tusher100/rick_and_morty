import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';

class StatusIndicator extends StatelessWidget {
  final String status;
  final double? size;

  const StatusIndicator({super.key, required this.status, this.size});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'alive':
        color = AppColors.statusAlive;
        break;
      case 'dead':
        color = AppColors.statusDead;
        break;
      default:
        color = AppColors.statusUnknown;
    }

    final indicatorSize = size ?? 10.w;

    return Container(
      width: indicatorSize,
      height: indicatorSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.statusUnknown.withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
