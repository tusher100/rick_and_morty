import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/features/home/providers/home_provider.dart';
import 'package:rickandmorty/features/home/widgets/character_card.dart';
import 'package:rickandmorty/features/details/screens/character_details_screen.dart';
import 'package:rickandmorty/features/favorites/screens/favorites_screen.dart';

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Rick & Morty',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0.5,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: IconButton(
              icon: Icon(Icons.favorite_outline, size: 24.w, color: Colors.black87),
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
            color: Colors.black87,
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
                                color: Colors.black87,
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
          child: CircularProgressIndicator(color: Colors.black87),
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
            child: Icon(Icons.search_off, size: 80.w),
          ),
          SizedBox(height: 16.h),
          Text(
            'No characters found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
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
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 50.w, color: Colors.red[400]),
            ),
            SizedBox(height: 24.h),
            Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'We had trouble fetching the character data. Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () => ref.read(characterListProvider.notifier).fetchInitial(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text('Retry', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}