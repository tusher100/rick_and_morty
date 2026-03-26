import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: TextFormField(
        controller: controller,
        style: AppText.getStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontFamily: 'Plus Jakarta Sans',
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppText.getStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : AppColors.textSecondary,
            fontFamily: 'Plus Jakarta Sans',
          ),
          prefixIcon: Icon(icon, color: isDark ? AppColors.secondary : Colors.blueGrey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: AppColors.secondary, width: 2),
          ),
          filled: true,
          fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        ),
        validator: validator,
      ),
    );
  }
}
