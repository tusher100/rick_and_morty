import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rickandmorty/core/widgets/rick_and_morty_app_bar.dart';
import 'package:rickandmorty/core/widgets/app_button.dart';
import 'package:rickandmorty/core/widgets/section_title.dart';
import 'package:rickandmorty/core/widgets/status_indicator.dart';
import 'package:rickandmorty/features/details/providers/character_details_provider.dart';
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

    return characterAsync.when(
      data: (characterData) {
        if (characterData == null) {
          return Scaffold(
            body: Center(child: AppText.h3('Character not found')),
          );
        }

        final character = characterData.mergeWithEdits(localEdits);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: RickAndMortyAppBar(
            character: character,
            title: character.name,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'character_${character.id}',
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: CachedNetworkImage(
                      imageUrl: character.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
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
                        ],
                      ),
                      SizedBox(height: 24.h),
                      const SectionTitle(title: 'Information'),
                      SizedBox(height: 12.h),
                      _buildInfoGrid(context, character),
                      SizedBox(height: 24.h),
                      const SectionTitle(title: 'Location details'),
                      SizedBox(height: 12.h),
                      _buildLocationInfo(
                        context,
                        'Origin',
                        character.originName,
                        Icons.public,
                      ),
                      SizedBox(height: 12.h),
                      _buildLocationInfo(
                        context,
                        'Current Location',
                        character.locationName,
                        Icons.location_on,
                      ),
                      SizedBox(height: 40.h),
                      Center(
                        child: AppButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditCharacterScreen(character: character),
                              ),
                            );
                          },
                          icon: Icons.edit_outlined,
                          label: 'Edit Character',
                        ),
                      ),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
        ),
      ),
      error: (e, st) => Scaffold(
        body: Center(
          child: AppText.bodyMedium('Error: $e', color: AppColors.danger),
        ),
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, dynamic character) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildGridItem('Gender', character.gender, Icons.person_outline),
          _buildDivider(context),
          _buildGridItem(
            'Type',
            character.type.isEmpty ? 'Unknown' : character.type,
            Icons.category,
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24.w, color: AppColors.secondary),
        SizedBox(height: 8.h),
        AppText.bodySmall(label),
        SizedBox(height: 4.h),
        AppText.bodyMedium(value),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(height: 40.h, width: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.2));
  }

  Widget _buildLocationInfo(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.iconBackground.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.1 : 1.0),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 24.w, color: AppColors.secondary),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [AppText.bodySmall(label), AppText.bodyMedium(value)],
            ),
          ),
        ],
      ),
    );
  }
}
