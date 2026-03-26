import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/models/character_model.dart';
import 'package:rickandmorty/features/favorites/providers/favorites_provider.dart';
import 'package:rickandmorty/features/editing/providers/local_edits_provider.dart';

class CharacterCard extends HookConsumerWidget {
  final Character character;
  final VoidCallback? onTap;

  const CharacterCard({
    super.key,
    required this.character,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add a retry key to force reload the image
    final retryKey = useState(0);
    final isFavorite = ref.watch(isFavoriteProvider(character.id));
    final localEdits = ref.watch(characterEditProvider(character.id));
    
    // Merge API data with local overrides
    final displayCharacter = character.mergeWithEdits(localEdits);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                        key: ValueKey('${displayCharacter.image}_${retryKey.value}'),
                        imageUrl: displayCharacter.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          debugPrint('Error for ${displayCharacter.name}: $error');
                          
                          // Auto-retry once if it's a rate limit (429) or transient error
                          if (retryKey.value < 2) {
                            Future.delayed(Duration(seconds: 1 + retryKey.value), () {
                              if (context.mounted) retryKey.value++;
                            });
                          }

                          return GestureDetector(
                            onTap: () => retryKey.value++,
                            child: Container(
                              color: Colors.grey[100],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.refresh, color: Colors.blue[300]),
                                  SizedBox(height: 4.h),
                                  Text(
                                    retryKey.value < 2 ? 'Retrying...' : 'Tap to retry',
                                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (isFavorite)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.favorite, color: Colors.red, size: 16.w),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayCharacter.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          _buildStatusIndicator(displayCharacter.status),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              '${displayCharacter.status} • ${displayCharacter.species}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'alive':
        color = const Color(0xFF55CC44);
        break;
      case 'dead':
        color = const Color(0xFFD63D2E);
        break;
      default:
        color = const Color(0xFF9E9E9E);
    }
    return Container(
      width: 7.w,
      height: 7.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
