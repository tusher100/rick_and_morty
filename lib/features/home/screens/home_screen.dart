import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/features/home/providers/home_provider.dart';
import 'package:rickandmorty/features/home/widgets/filter_sheet.dart';
import 'package:rickandmorty/features/home/widgets/active_filters_bar.dart';
import 'package:rickandmorty/features/home/widgets/home_states.dart';
import 'package:rickandmorty/features/home/widgets/character_grid.dart';
import 'package:rickandmorty/core/widgets/rick_and_morty_app_bar.dart';
import 'package:rickandmorty/features/favorites/providers/favorites_provider.dart';
import 'package:rickandmorty/features/editing/providers/local_edits_provider.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: RickAndMortyAppBar(
        isSelectionMode: isSelectionMode,
        selectionCount: selectedCharacters.value.length,
        onClearSelection: () => selectedCharacters.value = {},
        onBulkFavorite: () async {
          for (var c in selectedCharacters.value) {
            await ref.read(favoritesProvider.notifier).setFavorite(c, true);
          }
          selectedCharacters.value = {};
        },
        onBulkRestore: () async {
          for (var c in selectedCharacters.value) {
            await ref.read(localEditsProvider.notifier).deleteEdit(c.id);
          }
          selectedCharacters.value = {};
        },
        showSearch: true,
        isSearchExpanded: isSearchExpanded,
        searchController: searchController,
        onSearchChanged: (val) {
          debouncer.value?.cancel();
          debouncer.value = Timer(const Duration(milliseconds: 500), () => notifier.search(val));
        },
        onToggleFilter: () => _showFilterSheet(context, ref, state),
        hasActiveFilters: state.statusFilter != null || state.speciesFilter != null,
      ),
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
                  ? HomeEmptyState(
                      searchQuery: state.searchQuery,
                      statusFilter: state.statusFilter,
                      speciesFilter: state.speciesFilter,
                    )
                  : CharacterGrid(
                      characters: characters,
                      scrollController: scrollController,
                      selections: selectedCharacters,
                      isSelectionMode: isSelectionMode,
                      hasMore: state.hasMore,
                      isLoadingMore: state.isLoadingMore,
                      onToggleSelection: (c) => _toggleSelection(selectedCharacters, c),
                    ),
              loading: () => const HomeLoadingState(),
              error: (err, stack) => HomeErrorState(onRetry: () => notifier.fetchInitial()),
            ),
          ),
        ],
      ),
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

  void _showFilterSheet(BuildContext context, WidgetRef ref, CharacterListState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (context) => FilterSheet(
        initialStatus: state.statusFilter,
        initialSpecies: state.speciesFilter,
        onApply: (status, species) => ref.read(characterListProvider.notifier).setFilters(status: status, species: species),
      ),
    );
  }
}
