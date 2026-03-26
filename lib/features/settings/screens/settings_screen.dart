import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rickandmorty/core/theme/theme_provider.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';
import 'package:rickandmorty/features/editing/providers/local_edits_provider.dart';
import 'package:rickandmorty/features/favorites/screens/favorites_screen.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText.h2('Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.5,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSectionTitle('Preferences'),
          _buildSettingTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Toggle dark theme for the app',
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
              activeThumbColor: AppColors.secondary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildSectionTitle('Data Management'),
          _buildSettingTile(
            icon: Icons.favorite_border,
            title: 'My Favorites',
            subtitle: 'View your saved characters',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.restore,
            title: 'Reset All Edits',
            subtitle: 'Restore all locally edited characters to API data',
            textColor: AppColors.danger,
            onTap: () => _showResetConfirmation(context, ref),
          ),
          SizedBox(height: 32.h),
          Center(
            child: AppText.bodySmall(
              'Rick & Morty Explorer v1.0.0',
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
      child: AppText.bodySmall(
        title.toUpperCase(),
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.iconBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: AppColors.secondary, size: 24.w),
        ),
        title: AppText.bodyLarge(
          title,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        subtitle: AppText.bodySmall(subtitle),
        trailing:
            trailing ??
            Icon(
              Icons.chevron_right,
              size: 20.w,
              color: AppColors.textTertiary,
            ),
        onTap: onTap,
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText.h3('Reset All Edits?'),
        content: AppText.bodyMedium(
          'This will permanently restore all characters to their original API data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText.bodyMedium('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(localEditsProvider.notifier).resetAllEdits();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All characters restored to original data'),
                ),
              );
            },
            child: AppText.bodyMedium('Reset All', color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}
