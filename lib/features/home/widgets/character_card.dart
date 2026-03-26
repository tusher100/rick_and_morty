import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/models/character_model.dart';
import 'package:rickandmorty/core/widgets/app_card.dart';
import 'package:rickandmorty/core/widgets/status_indicator.dart';
import 'package:rickandmorty/features/editing/providers/local_edits_provider.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';

class CharacterCard extends HookConsumerWidget {
  final Character character;
  final VoidCallback? onTap;

  const CharacterCard({super.key, required this.character, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retryKey = useState(0);
    final localEdits = ref.watch(characterEditProvider(character.id));

    final displayCharacter = character.mergeWithEdits(localEdits);

    return AppCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: Hero(
                  tag: 'character_${displayCharacter.id}',
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        key: ValueKey(
                          '${displayCharacter.image}_${retryKey.value}',
                        ),
                        imageUrl: displayCharacter.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          if (retryKey.value < 3) {
                            // Exponential backoff for 429s
                            Future.delayed(
                              Duration(seconds: (retryKey.value + 1) * 2),
                              () {
                                if (context.mounted) retryKey.value++;
                              },
                            );
                          }

                          return GestureDetector(
                            onTap: () => retryKey.value++,
                            child: Container(
                              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: AppColors.secondary,
                                  ),
                                  SizedBox(height: 4.h),
                                  AppText.bodySmall(
                                    retryKey.value < 2
                                        ? 'Retrying...'
                                        : 'Tap to retry',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        text: displayCharacter.name,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          StatusIndicator(
                            status: displayCharacter.status,
                            size: 7.w,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: AppText(
                              text:
                                  '${displayCharacter.status} • ${displayCharacter.species}',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
