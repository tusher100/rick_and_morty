import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/features/home/providers/home_provider.dart';
import 'package:rickandmorty/features/home/widgets/character_card.dart';
import 'package:rickandmorty/features/home/widgets/filter_sheet.dart';
import 'package:rickandmorty/features/home/widgets/active_filters_bar.dart';
import 'package:rickandmorty/features/home/widgets/home_states.dart';
import 'package:rickandmorty/features/details/screens/character_details_screen.dart';
import 'package:rickandmorty/features/favorites/screens/favorites_screen.dart';
import 'package:rickandmorty/features/favorites/providers/favorites_provider.dart';
import 'package:rickandmorty/features/editing/providers/local_edits_provider.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';
import 'package:rickandmorty/core/models/character_model.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(characterListProvider);
    final scrollController = useScrollController();
    final isSearchExpanded = useState(false);
    final searchController = useTextEditingController();
    final debouncer = useState<Timer?>(null);
    final selectedCharacters = useState<Set<Character>>({});
    
    final notifier = ref.read(characterListProvider.notifier);
    final isSelectionMode = selectedCharacters.value.isNotEmpty;

    useEffect(() {
      void scrollListener() {
        if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 500.h) {
          notifier.fetchNextPage();
        }
      }
      scrollController.addListener(scrollListener);
      return () => scrollController.removeListener(scrollListener);
    }, [scrollController]);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isSelectionMode 
        ? _buildSelectionAppBar(context, ref, selectedCharacters)
        : _buildNormalAppBar(context, ref, state, isSearchExpanded, searchController, debouncer),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.statusFilter != null || state.speciesFilter != null)
            ActiveFiltersBar(
              statusFilter: state.statusFilter,
              speciesFilter: state.speciesFilter,
              onClearStatus: () => notifier.setFilters(status: null, species: state.speciesFilter),
              onClearSpecies: () => notifier.setFilters(status: state.statusFilter, species: null),
              onClearAll: () => notifier.setFilters(clearAll: true),
            ),
          Expanded(
            child: state.characters.when(
              data: (characters) => characters.isEmpty 
                ? HomeEmptyState(isFiltered: state.searchQuery != null || state.statusFilter != null || state.speciesFilter != null)
                : _buildCharacterGrid(context, ref, characters, scrollController, selectedCharacters, isSelectionMode, state.hasMore, state.isLoadingMore),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.textPrimary)),
              error: (err, stack) => HomeErrorState(onRetry: () => notifier.fetchInitial()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterGrid(BuildContext context, WidgetRef ref, List<Character> characters, ScrollController scrollController, ValueNotifier<Set<Character>> selections, bool isSelectionMode, bool hasMore, bool isLoadingMore) {
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
                (context, index) => _buildGridItem(context, ref, characters[index], selections, isSelectionMode),
                childCount: characters.length,
              ),
            ),
          ),
          if (hasMore) SliverToBoxAdapter(child: isLoadingMore ? Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32.h), child: const CircularProgressIndicator(color: AppColors.textPrimary))) : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, WidgetRef ref, Character character, ValueNotifier<Set<Character>> selections, bool isSelectionMode) {
    final isSelected = selections.value.any((c) => c.id == character.id);
    return Stack(
      children: [
        CharacterCard(key: ValueKey(character.id), character: character, onTap: null),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isSelectionMode) {
                  _toggleSelection(selections, character);
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CharacterDetailsScreen(characterId: character.id)));
                }
              },
              onLongPress: () => _toggleSelection(selections, character),
              child: isSelected ? _buildSelectionOverlay() : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleSelection(ValueNotifier<Set<Character>> selections, Character character) {
    final newSet = Set<Character>.from(selections.value);
    if (newSet.any((c) => c.id == character.id)) {
      newSet.removeWhere((c) => c.id == character.id);
    } else {
      newSet.add(character);
    }
    selections.value = newSet;
  }

  Widget _buildSelectionOverlay() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      alignment: Alignment.topRight,
      child: const CircleAvatar(backgroundColor: AppColors.secondary, radius: 12, child: Icon(Icons.check, color: Colors.white, size: 16)),
    );
  }

  PreferredSizeWidget _buildNormalAppBar(BuildContext context, WidgetRef ref, CharacterListState state, ValueNotifier<bool> isSearchExpanded, TextEditingController searchController, ValueNotifier<Timer?> debouncer) {
    return AppBar(
      backgroundColor: AppColors.cardBackground, centerTitle: false, elevation: 0.5,
      leading: isSearchExpanded.value ? IconButton(icon: Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () { isSearchExpanded.value = false; searchController.clear(); ref.read(characterListProvider.notifier).search(''); }) : null,
      title: !isSearchExpanded.value ? AppText.h2('Rick & Morty') : _buildSearchField(ref, searchController, debouncer),
      actions: [
        IconButton(icon: Icon(isSearchExpanded.value ? Icons.close : Icons.search, size: 24.w, color: AppColors.textPrimary), onPressed: () { if (isSearchExpanded.value) { searchController.clear(); ref.read(characterListProvider.notifier).search(''); } isSearchExpanded.value = !isSearchExpanded.value; }),
        IconButton(icon: Icon(Icons.tune, size: 24.w, color: (state.statusFilter != null || state.speciesFilter != null) ? AppColors.secondary : AppColors.textPrimary), onPressed: () => _showFilterSheet(context, ref, state)),
        if (!isSearchExpanded.value) Padding(padding: EdgeInsets.only(right: 12.w), child: IconButton(icon: Icon(Icons.favorite_outline, size: 24.w, color: AppColors.textPrimary), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen())))),
      ],
    );
  }

  Widget _buildSearchField(WidgetRef ref, TextEditingController controller, ValueNotifier<Timer?> debouncer) {
    return TextField(
      controller: controller, autofocus: true, style: AppText.getStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(hintText: 'Search characters...', hintStyle: AppText.getStyle(fontSize: 16, color: AppColors.textSecondary), border: InputBorder.none, suffixIcon: controller.text.isNotEmpty ? IconButton(icon: Icon(Icons.close, color: AppColors.textSecondary), onPressed: () { controller.clear(); ref.read(characterListProvider.notifier).search(''); }) : null),
      onChanged: (val) { debouncer.value?.cancel(); debouncer.value = Timer(const Duration(milliseconds: 500), () => ref.read(characterListProvider.notifier).search(val)); },
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(BuildContext context, WidgetRef ref, ValueNotifier<Set<Character>> selections) {
    return AppBar(
      backgroundColor: AppColors.secondary,
      title: AppText.bodyLarge('${selections.value.length} Selected', color: Colors.white, fontWeight: FontWeight.bold),
      leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => selections.value = {}),
      actions: [
        IconButton(icon: const Icon(Icons.favorite, color: Colors.white), onPressed: () async { for (var c in selections.value) { await ref.read(favoritesProvider.notifier).setFavorite(c, true); } selections.value = {}; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to favorites!'))); }),
        IconButton(icon: const Icon(Icons.restore, color: Colors.white), onPressed: () async { for (var c in selections.value) { await ref.read(localEditsProvider.notifier).deleteEdit(c.id); } selections.value = {}; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restored selected characters!'))); }),
      ],
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref, CharacterListState state) {
    showModalBottomSheet(context: context, backgroundColor: AppColors.cardBackground, isScrollControlled: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))), builder: (context) => FilterSheet(initialStatus: state.statusFilter, initialSpecies: state.speciesFilter, onApply: (status, species) => ref.read(characterListProvider.notifier).setFilters(status: status, species: species)));
  }
}