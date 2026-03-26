import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';
import 'package:rickandmorty/core/widgets/app_button.dart';

class HomeEmptyState extends StatelessWidget {
  final bool isFiltered;

  const HomeEmptyState({super.key, required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.5,
            child: Icon(
              isFiltered ? Icons.search_off : Icons.group_off,
              size: 80.w,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          AppText.h3(
            isFiltered ? 'No matching characters' : 'No characters found',
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textSecondary,
          ),
          if (isFiltered) ...[
            SizedBox(height: 8.h),
            AppText.bodySmall('Try adjusting your filters'),
          ],
        ],
      ),
    );
  }
}

class HomeErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const HomeErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 50.w,
                color: AppColors.danger,
              ),
            ),
            SizedBox(height: 24.h),
            AppText.h2('Connection Error'),
            SizedBox(height: 8.h),
            AppText.bodySmall(
              'We had trouble fetching the character data. Please check your internet connection and try again.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            AppButton(onPressed: onRetry, label: 'Retry'),
          ],
        ),
      ),
    );
  }
}
