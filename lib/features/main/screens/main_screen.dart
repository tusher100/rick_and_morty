import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';
import 'package:rickandmorty/core/network/connectivity_provider.dart';
import 'package:rickandmorty/features/home/screens/home_screen.dart';
import 'package:rickandmorty/features/settings/screens/settings_screen.dart';

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(0);
    final connectivity = ref.watch(connectivityProvider);

    final screens = [const HomeScreen(), const SettingsScreen()];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: currentIndex.value, children: screens),
          if (connectivity == ConnectivityStatus.isDisconnected)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildOfflineBanner(context),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex.value,
        onTap: (index) => currentIndex.value = index,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      color: AppColors.danger.withValues(alpha: 0.9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 14),
          SizedBox(width: 8.w),
          AppText.bodySmall(
            'Offline Mode: Viewing Cached Data',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
