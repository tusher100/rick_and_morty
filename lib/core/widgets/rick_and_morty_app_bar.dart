import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/models/character_model.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';
import 'package:rickandmorty/features/favorites/providers/favorites_provider.dart';
import 'package:rickandmorty/features/editing/providers/local_edits_provider.dart';
import 'package:rickandmorty/features/favorites/screens/favorites_screen.dart';

class RickAndMortyAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final Character? character;
  final bool isSliver;
  final Widget? flexibleSpace;
  final double? expandedHeight;
  final List<Widget>? actions;
  
  // Selection Mode
  final bool isSelectionMode;
  final int? selectionCount;
  final VoidCallback? onClearSelection;
  final VoidCallback? onBulkFavorite;
  final VoidCallback? onBulkRestore;

  // Search Mode
  final bool showSearch;
  final ValueNotifier<bool>? isSearchExpanded;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onToggleFilter;
  final bool hasActiveFilters;

  // Actions Toggle
  final bool showFavorite;
  final bool showReset;

  const RickAndMortyAppBar({
    super.key,
    this.title,
    this.character,
    this.isSliver = false,
    this.flexibleSpace,
    this.expandedHeight,
    this.actions,
    this.isSelectionMode = false,
    this.selectionCount,
    this.onClearSelection,
    this.onBulkFavorite,
    this.onBulkRestore,
    this.showSearch = false,
    this.isSearchExpanded,
    this.searchController,
    this.onSearchChanged,
    this.onToggleFilter,
    this.hasActiveFilters = false,
    this.showFavorite = true,
    this.showReset = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSelectionMode) return _buildSelectionAppBar(context, ref);
    if (showSearch && isSearchExpanded?.value == true) return _buildSearchAppBar(context, ref);

    final allActions = _buildDefaultActions(context, ref);

    if (isSliver) {
      return SliverAppBar(
        expandedHeight: expandedHeight ?? 300.h,
        pinned: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.5,
        leading: _buildLeading(context, true),
        title: (title != null) ? AppText.h3(title!) : null,
        flexibleSpace: flexibleSpace,
        actions: allActions,
      );
    }

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0.5,
      centerTitle: title != null && title!.length > 15,
      leading: _buildLeading(context, false),
      title: AppText.h2(title ?? character?.name ?? 'Rick & Morty'),
      actions: allActions,
    );
  }

  Widget _buildLeading(BuildContext context, bool withBackground) {
    final canPop = Navigator.canPop(context);
    if (!canPop) return const SizedBox.shrink();

    final backButton = BackButton(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : AppColors.textPrimary,
    );
    if (withBackground) {
      return Padding(
        padding: EdgeInsets.all(8.w),
        child: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
          child: backButton,
        ),
      );
    }
    return backButton;
  }

  List<Widget> _buildDefaultActions(BuildContext context, WidgetRef ref) {
    final List<Widget> list = [];
    
    if (actions != null) list.addAll(actions!);

    if (character != null) {
      final isFavorite = ref.watch(isFavoriteProvider(character!.id));
      final hasEdits = ref.watch(characterEditProvider(character!.id)) != null;

      if (hasEdits && showReset) {
        list.add(IconButton(
          icon: Icon(Icons.restore, color: isSliver ? Colors.white : AppColors.danger, size: 22.w),
          onPressed: () => _showResetDialog(context, ref, character!.id),
        ));
      }
      if (showFavorite) {
        list.add(IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? AppColors.danger : (isSliver ? Colors.white : AppColors.textTertiary),
            size: 26.w,
          ),
          onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(character!),
        ));
      }
    }

    if (showSearch && isSearchExpanded != null) {
      list.add(IconButton(
        icon: Icon(
          Icons.search,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppColors.textPrimary,
          size: 24.w,
        ),
        onPressed: () => isSearchExpanded!.value = true,
      ));
    }

    if (onToggleFilter != null) {
      list.add(IconButton(
        icon: Icon(
          Icons.tune,
          color: hasActiveFilters
              ? AppColors.secondary
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.textPrimary),
          size: 24.w,
        ),
        onPressed: onToggleFilter,
      ));
    }

    if (showSearch && !isSliver) {
      list.add(IconButton(
        icon: Icon(
          Icons.favorite_outline,
          size: 24.w,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppColors.textPrimary,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
        ),
      ));
    }

    list.add(SizedBox(width: 8.w));
    return list;
  }

  Widget _buildSelectionAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: AppColors.secondary,
      title: AppText.bodyLarge('${selectionCount ?? 0} Selected', color: Colors.white, fontWeight: FontWeight.bold),
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: onClearSelection,
      ),
      actions: [
        if (onBulkFavorite != null) IconButton(icon: const Icon(Icons.favorite, color: Colors.white), onPressed: onBulkFavorite),
        if (onBulkRestore != null) IconButton(icon: const Icon(Icons.restore, color: Colors.white), onPressed: onBulkRestore),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildSearchAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppColors.textPrimary,
        ),
        onPressed: () {
          isSearchExpanded?.value = false;
          searchController?.clear();
          onSearchChanged?.call('');
        },
      ),
      title: TextField(
        controller: searchController,
        autofocus: true,
        style: AppText.getStyle(
          fontSize: 16,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search characters...',
          hintStyle: AppText.getStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : AppColors.textSecondary,
          ),
          border: InputBorder.none,
          suffixIcon: searchController?.text.isNotEmpty == true
              ? IconButton(
                  icon: Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () {
                    searchController?.clear();
                    onSearchChanged?.call('');
                  },
                )
              : null,
        ),
        onChanged: onSearchChanged,
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText.h3('Reset Data?'),
        content: AppText.bodyMedium('This will clear your local edits and restore the character to its original API data.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: AppText.bodyMedium('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(localEditsProvider.notifier).deleteEdit(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: AppText.bodyMedium('Reset', color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}
