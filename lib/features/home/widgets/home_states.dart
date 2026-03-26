import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';
import 'package:rickandmorty/core/widgets/app_button.dart';
import 'package:rickandmorty/features/home/widgets/shimmer_character_card.dart';

class HomeLoadingState extends StatelessWidget {
  const HomeLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemBuilder: (context, index) => const ShimmerCharacterCard(),
    );
  }
}

class HomeEmptyState extends StatelessWidget {
  final String? searchQuery;
  final String? statusFilter;
  final String? speciesFilter;

  const HomeEmptyState({
    super.key,
    this.searchQuery,
    this.statusFilter,
    this.speciesFilter,
  });

  bool get isFiltered => searchQuery != null || statusFilter != null || speciesFilter != null;

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
            _getMessage(),
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
          if (isFiltered) ...[
            SizedBox(height: 12.h),
            _buildFilterSummary(context),
            SizedBox(height: 16.h),
            AppText.bodySmall('Try adjusting or clearing your filters', color: AppColors.textTertiary),
          ],
        ],
      ),
    );
  }

  String _getMessage() {
    if (searchQuery != null) return 'No characters matching "$searchQuery"';
    if (isFiltered) return 'No matching characters found';
    return 'No characters found';
  }

  Widget _buildFilterSummary(BuildContext context) {
    final filters = <String>[];
    if (statusFilter != null) filters.add('Status: $statusFilter');
    if (speciesFilter != null) filters.add('Species: $speciesFilter');

    if (filters.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      alignment: WrapAlignment.center,
      children: filters.map((f) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        ),
        child: AppText.bodySmall(f, color: AppColors.secondary, fontWeight: FontWeight.bold),
      )).toList(),
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
