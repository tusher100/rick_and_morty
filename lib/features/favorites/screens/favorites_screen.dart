import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/features/home/widgets/character_card.dart';
import 'package:rickandmorty/features/favorites/providers/favorites_provider.dart';
import 'package:rickandmorty/features/details/screens/character_details_screen.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';

class FavoritesScreen extends HookConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: AppText.h2('My Favorites'),
        backgroundColor: AppColors.cardBackground,
        elevation: 0.5,
        leading: BackButton(color: AppColors.textPrimary),
      ),
      body: favoritesState.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: 0.3,
                    child: Icon(
                      Icons.favorite_border,
                      size: 80.w,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  AppText.h3(
                    'No favorites yet',
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 8.h),
                  AppText.bodySmall(
                    'Characters you favorite will appear here.',
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: EdgeInsets.all(16.w),
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final character = favorites[index];
              return CharacterCard(
                key: ValueKey('fav_${character.id}'),
                character: character,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CharacterDetailsScreen(characterId: character.id),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: AppText.bodyMedium(
            'Error loading favorites: $err',
            color: AppColors.danger,
          ),
        ),
      ),
    );
  }
}
