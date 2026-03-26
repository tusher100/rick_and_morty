import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/features/home/providers/home_provider.dart';
import 'package:rickandmorty/features/home/widgets/character_card.dart';
import 'package:rickandmorty/core/widgets/app_button.dart';
import 'package:rickandmorty/features/details/screens/character_details_screen.dart';
import 'package:rickandmorty/features/favorites/screens/favorites_screen.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(characterListProvider);
    final scrollController = useScrollController();

    useEffect(() {
      void scrollListener() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 500.h) {
          ref.read(characterListProvider.notifier).fetchNextPage();
        }
      }

      scrollController.addListener(scrollListener);
      return () => scrollController.removeListener(scrollListener);
    }, [scrollController]);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: AppText.h2('Rick & Morty'),
        backgroundColor: AppColors.cardBackground,
        centerTitle: false,
        elevation: 0.5,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: IconButton(
              icon: Icon(Icons.favorite_outline, size: 24.w, color: AppColors.textPrimary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                );
              },
            ),
          )
        ],
      ),
      body: state.characters.when(
        data: (characters) {
          if (characters.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            color: AppColors.textPrimary,
            onRefresh: () => ref.read(characterListProvider.notifier).fetchInitial(),
            child: CustomScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(16.w),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final character = characters[index];
                        return CharacterCard(
                          key: ValueKey(character.id),
                          character: character,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CharacterDetailsScreen(
                                  characterId: character.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: characters.length,
                    ),
                  ),
                ),
                if (state.hasMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: state.isLoadingMore
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.textPrimary,
                                strokeWidth: 3,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        ),
        error: (err, stack) => _buildErrorState(ref, err),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.5,
            child: Icon(Icons.search_off, size: 80.w, color: AppColors.textSecondary),
          ),
          SizedBox(height: 16.h),
          AppText.h3(
            'No characters found',
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object err) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 50.w, color: AppColors.danger),
            ),
            SizedBox(height: 24.h),
            AppText.h2('Connection Error'),
            SizedBox(height: 8.h),
            AppText.bodySmall(
              'We had trouble fetching the character data. Please check your internet connection and try again.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            AppButton(
              onPressed: () => ref.read(characterListProvider.notifier).fetchInitial(),
              label: 'Retry',
            ),
          ],
        ),
      ),
    );
  }
}