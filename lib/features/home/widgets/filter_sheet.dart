import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';
import 'package:rickandmorty/core/widgets/app_button.dart';

class FilterSheet extends StatefulWidget {
  final String? initialStatus;
  final String? initialSpecies;
  final Function(String?, String?) onApply;

  const FilterSheet({
    super.key,
    this.initialStatus,
    this.initialSpecies,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? selectedStatus;
  String? selectedSpecies;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.initialStatus;
    selectedSpecies = widget.initialSpecies;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.h3('Filter Characters'),
              if (selectedStatus != null || selectedSpecies != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedStatus = null;
                      selectedSpecies = null;
                    });
                  },
                  child: AppText.bodySmall('Reset', color: AppColors.danger),
                ),
            ],
          ),
          SizedBox(height: 24.h),
          AppText.bodyMedium('Status', fontWeight: FontWeight.bold),
          SizedBox(height: 12.h),
          _buildFilterOptions(['Alive', 'Dead', 'Unknown'], selectedStatus, (
            val,
          ) {
            setState(() => selectedStatus = val);
          }),
          SizedBox(height: 24.h),
          AppText.bodyMedium('Species', fontWeight: FontWeight.bold),
          SizedBox(height: 12.h),
          _buildFilterOptions(
            ['Human', 'Alien', 'Robot', 'Humanoid', 'Poopybutthole'],
            selectedSpecies,
            (val) {
              setState(() => selectedSpecies = val);
            },
          ),
          SizedBox(height: 40.h),
          AppButton(
            onPressed: () {
              widget.onApply(selectedStatus, selectedSpecies);
              Navigator.pop(context);
            },
            label: 'Apply Filters',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(
    List<String> options,
    String? selected,
    Function(String?) onSelected,
  ) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((opt) {
        final isSelected = selected == opt;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return InkWell(
          onTap: () => onSelected(isSelected ? null : opt),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondary.withValues(alpha: 0.1)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.background),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.secondary
                    : Theme.of(context).dividerColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: AppText.bodySmall(
              opt,
              color: isSelected ? AppColors.secondary : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}
