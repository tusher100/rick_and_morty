import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rickandmorty/core/widgets/app_button.dart';
import 'package:rickandmorty/core/widgets/section_title.dart';
import 'package:rickandmorty/core/widgets/status_indicator.dart';
import 'package:rickandmorty/features/details/providers/character_details_provider.dart';
import 'package:rickandmorty/features/favorites/providers/favorites_provider.dart';
import 'package:rickandmorty/features/editing/providers/local_edits_provider.dart';
import 'package:rickandmorty/features/editing/screens/edit_character_screen.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';

class CharacterDetailsScreen extends HookConsumerWidget {
  final int characterId;

  const CharacterDetailsScreen({super.key, required this.characterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterAsync = ref.watch(characterDetailProvider(characterId));
    final localEdits = ref.watch(characterEditProvider(characterId));
    final isFavorite = ref.watch(isFavoriteProvider(characterId));

    return characterAsync.when(
      data: (characterData) {
        if (characterData == null) {
          return Scaffold(
            body: Center(child: AppText.h3('Character not found')),
          );
        }

        final character = characterData.mergeWithEdits(localEdits);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350.h,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'character_${character.id}',
                    child: CachedNetworkImage(
                      imageUrl: character.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                backgroundColor: AppColors.cardBackground,
                elevation: 0,
                leading: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: CircleAvatar(
                    backgroundColor: AppColors.cardBackground.withValues(alpha: 0.5),
                    child: BackButton(color: AppColors.textPrimary),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText.h1(character.name),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    StatusIndicator(status: character.status),
                                    SizedBox(width: 6.w),
                                    AppText.bodyLarge(
                                      '${character.status} - ${character.species}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? AppColors.danger : AppColors.textTertiary,
                              size: 30.w,
                            ),
                            onPressed: () {
                              ref.read(favoritesProvider.notifier).toggleFavorite(character);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      const SectionTitle(title: 'Information'),
                      SizedBox(height: 12.h),
                      _buildInfoGrid(character),
                      SizedBox(height: 24.h),
                      const SectionTitle(title: 'Location details'),
                      SizedBox(height: 12.h),
                      _buildLocationInfo('Origin', character.originName, Icons.public),
                      SizedBox(height: 12.h),
                      _buildLocationInfo('Current Location', character.locationName, Icons.location_on),
                      
                      SizedBox(height: 40.h),
                      AppButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCharacterScreen(character: character),
                            ),
                          );
                        },
                        icon: Icons.edit_outlined,
                        label: 'Edit Character',
                      ),
                      SizedBox(height: 100.h), 
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, st) => Scaffold(
        body: Center(
          child: AppText.bodyMedium(
            'Error: $e',
            color: AppColors.danger,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid(dynamic character) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildGridItem('Gender', character.gender, Icons.person_outline),
          _buildDivider(),
          _buildGridItem('Type', character.type.isEmpty ? 'Unknown' : character.type, Icons.category),
        ],
      ),
    );
  }

  Widget _buildGridItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24.w, color: Colors.blueGrey),
        SizedBox(height: 8.h),
        AppText.bodySmall(label),
        SizedBox(height: 4.h),
        AppText.bodyMedium(value),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40.h,
      width: 1,
      color: AppColors.divider,
    );
  }

  Widget _buildLocationInfo(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.iconBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 24.w, color: AppColors.secondary),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodySmall(label),
                AppText.bodyMedium(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
