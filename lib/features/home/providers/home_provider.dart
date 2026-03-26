import 'dart:async';
import 'package:rickandmorty/core/database/sqflite_helper.dart';
import 'package:rickandmorty/core/models/character_model.dart';
import 'package:rickandmorty/core/network/api_client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final apiClientProvider = Provider((ref) => ApiClient());

class CharacterListState {
  final AsyncValue<List<Character>> characters;
  final bool hasMore;
  final bool isLoadingMore;
  final String? searchQuery;
  final String? statusFilter;
  final String? speciesFilter;

  CharacterListState({
    required this.characters,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.searchQuery,
    this.statusFilter,
    this.speciesFilter,
  });

  CharacterListState copyWith({
    AsyncValue<List<Character>>? characters,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    String? statusFilter,
    String? speciesFilter,
    bool clearSearch = false,
    bool clearStatus = false,
    bool clearSpecies = false,
  }) {
    return CharacterListState(
      characters: characters ?? this.characters,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
      speciesFilter: clearSpecies ? null : (speciesFilter ?? this.speciesFilter),
    );
  }
}

class CharacterListNotifier extends Notifier<CharacterListState> {
  int _currentPage = 1;

  @override
  CharacterListState build() {
    // Initial fetch triggered after build
    Future.microtask(() => fetchInitial());
    return CharacterListState(characters: const AsyncValue.loading());
  }

  Future<void> fetchInitial() async {
    state = state.copyWith(characters: const AsyncValue.loading());
    try {
      final fetchedData = await _fetchCharactersData(
        1, 
        state.searchQuery, 
        state.statusFilter, 
        state.speciesFilter
      );
      _currentPage = 1;
      state = state.copyWith(
        characters: AsyncValue.data(fetchedData.characters),
        hasMore: fetchedData.hasMore,
      );
    } catch (e, st) {
      state = state.copyWith(characters: AsyncValue.error(e, st));
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(
      searchQuery: query.isEmpty ? null : query,
      clearSearch: query.isEmpty,
    );
    await fetchInitial();
  }

  Future<void> setFilters({String? status, String? species, bool clearAll = false}) async {
    if (clearAll) {
      state = state.copyWith(
        clearStatus: true,
        clearSpecies: true,
      );
    } else {
      state = state.copyWith(
        statusFilter: status,
        speciesFilter: species,
        clearStatus: status == null,
        clearSpecies: species == null,
      );
    }
    await fetchInitial();
  }

  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = _currentPage + 1;
      final fetchedData = await _fetchCharactersData(
        nextPage, 
        state.searchQuery,
        state.statusFilter,
        state.speciesFilter
      );

      final currentValue = state.characters.asData?.value ?? [];
      final existingIds = currentValue.map((c) => c.id).toSet();
      final uniqueNewCharacters = fetchedData.characters.where((c) => !existingIds.contains(c.id)).toList();

      _currentPage = nextPage;
      state = state.copyWith(
        characters: AsyncValue.data([...currentValue, ...uniqueNewCharacters]),
        hasMore: fetchedData.hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<({List<Character> characters, bool hasMore})> _fetchCharactersData(
    int page, 
    String? name,
    String? status,
    String? species,
  ) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      final data = await apiClient.fetchCharacters(
        page: page, 
        name: name,
        status: status,
        species: species,
      );
      final List results = data['results'];
      final characters = results.map((json) => Character.fromJson(json)).toList();

      // Only cache full list results (no filters)
      if (name == null && status == null && species == null) {
        await SqfliteHelper.instance.saveCharacters(characters, page);
      }

      return (
        characters: characters,
        hasMore: data['info']['next'] != null,
      );
    } catch (e) {
      // For filtered results, we don't have deep cache logic for page combinations yet
      if (name == null && status == null && species == null) {
        final cachedCharacters = await SqfliteHelper.instance.getCachedCharacters(page: page);
        if (cachedCharacters.isNotEmpty) {
          return (
            characters: cachedCharacters,
            hasMore: true,
          );
        }
      }
      rethrow;
    }
  }
}

final characterListProvider = NotifierProvider<CharacterListNotifier, CharacterListState>(() {
  return CharacterListNotifier();
});