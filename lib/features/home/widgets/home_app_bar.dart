import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';
import 'package:rickandmorty/features/home/providers/home_provider.dart';
import 'package:rickandmorty/features/favorites/screens/favorites_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CharacterListState state;
  final ValueNotifier<bool> isSearchExpanded;
  final TextEditingController searchController;
  final ValueNotifier<Timer?> debouncer;
  final VoidCallback onToggleFilter;

  const HomeAppBar({
    super.key,
    required this.state,
    required this.isSearchExpanded,
    required this.searchController,
    required this.debouncer,
    required this.onToggleFilter,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final notifier = ref.read(characterListProvider.notifier);

        return AppBar(
          backgroundColor: AppColors.cardBackground,
          centerTitle: false,
          elevation: 0.5,
          leading: isSearchExpanded.value
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () {
                    isSearchExpanded.value = false;
                    searchController.clear();
                    notifier.search('');
                  },
                )
              : null,
          title: !isSearchExpanded.value
              ? AppText.h2('Rick & Morty')
              : _buildSearchField(notifier),
          actions: [
            IconButton(
              icon: Icon(
                isSearchExpanded.value ? Icons.close : Icons.search,
                size: 24.w,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                if (isSearchExpanded.value) {
                  searchController.clear();
                  notifier.search('');
                }
                isSearchExpanded.value = !isSearchExpanded.value;
              },
            ),
            IconButton(
              icon: Icon(
                Icons.tune,
                size: 24.w,
                color:
                    (state.statusFilter != null || state.speciesFilter != null)
                    ? AppColors.secondary
                    : AppColors.textPrimary,
              ),
              onPressed: onToggleFilter,
            ),
            if (!isSearchExpanded.value)
              Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: IconButton(
                  icon: Icon(
                    Icons.favorite_outline,
                    size: 24.w,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSearchField(CharacterListNotifier notifier) {
    return TextField(
      controller: searchController,
      autofocus: true,
      style: AppText.getStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search characters...',
        hintStyle: AppText.getStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
        border: InputBorder.none,
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () {
                  searchController.clear();
                  notifier.search('');
                },
              )
            : null,
      ),
      onChanged: (val) {
        debouncer.value?.cancel();
        debouncer.value = Timer(
          const Duration(milliseconds: 500),
          () => notifier.search(val),
        );
      },
    );
  }
}
