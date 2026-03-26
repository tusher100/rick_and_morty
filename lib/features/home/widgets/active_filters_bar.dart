import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';

class ActiveFiltersBar extends StatelessWidget {
  final String? statusFilter;
  final String? speciesFilter;
  final VoidCallback onClearStatus;
  final VoidCallback onClearSpecies;
  final VoidCallback onClearAll;

  const ActiveFiltersBar({
    super.key,
    this.statusFilter,
    this.speciesFilter,
    required this.onClearStatus,
    required this.onClearSpecies,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (statusFilter != null)
              _buildFilterChip(
                context, 
                'Status: $statusFilter', 
                ValueKey('status_$statusFilter'),
                onClearStatus,
              ),
            if (speciesFilter != null)
              _buildFilterChip(
                context, 
                'Species: $speciesFilter', 
                ValueKey('species_$speciesFilter'),
                onClearSpecies,
              ),
            if (statusFilter != null || speciesFilter != null)
              TextButton(
                onPressed: onClearAll,
                child: AppText.bodySmall('Clear All', color: AppColors.secondary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, Key key, VoidCallback onDeleted) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Chip(
        key: key,
        label: AppText.bodySmall(label, color: AppColors.cardBackground),
        backgroundColor: AppColors.secondary,
        deleteIcon: Icon(Icons.close, size: 16.w, color: AppColors.cardBackground),
        onDeleted: onDeleted,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}
