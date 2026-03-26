import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/models/character_model.dart';
import 'package:rickandmorty/features/home/providers/home_provider.dart';
import 'package:rickandmorty/features/home/widgets/character_grid_item.dart';

class CharacterGrid extends StatelessWidget {
  final List<Character> characters;
  final ScrollController scrollController;
  final ValueNotifier<Set<Character>> selections;
  final bool isSelectionMode;
  final bool hasMore;
  final bool isLoadingMore;
  final Function(Character) onToggleSelection;

  const CharacterGrid({
    super.key,
    required this.characters,
    required this.scrollController,
    required this.selections,
    required this.isSelectionMode,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return RefreshIndicator(
          color: AppColors.textPrimary,
          onRefresh: () =>
              ref.read(characterListProvider.notifier).fetchInitial(),
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
                    (context, index) => CharacterGridItem(
                      character: characters[index],
                      selections: selections,
                      isSelectionMode: isSelectionMode,
                      onToggleSelection: onToggleSelection,
                    ),
                    childCount: characters.length,
                  ),
                ),
              ),
              if (hasMore)
                SliverToBoxAdapter(
                  child: isLoadingMore
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.h),
                            child: const CircularProgressIndicator(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        );
      },
    );
  }
}
