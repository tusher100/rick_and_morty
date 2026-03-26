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

  CharacterListState({
    required this.characters,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  CharacterListState copyWith({
    AsyncValue<List<Character>>? characters,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return CharacterListState(
      characters: characters ?? this.characters,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
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
      final fetchedData = await _fetchCharactersData(1);
      _currentPage = 1;
      state = state.copyWith(
        characters: AsyncValue.data(fetchedData.characters),
        hasMore: fetchedData.hasMore,
      );
    } catch (e, st) {
      state = state.copyWith(characters: AsyncValue.error(e, st));
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = _currentPage + 1;
      final fetchedData = await _fetchCharactersData(nextPage);

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

  Future<({List<Character> characters, bool hasMore})> _fetchCharactersData(int page) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      final data = await apiClient.fetchCharacters(page: page);
      final List results = data['results'];
      final characters = results.map((json) => Character.fromJson(json)).toList();

      await SqfliteHelper.instance.saveCharacters(characters, page);

      return (
        characters: characters,
        hasMore: data['info']['next'] != null,
      );
    } catch (e) {
      final cachedCharacters = await SqfliteHelper.instance.getCachedCharacters(page: page);
      if (cachedCharacters.isNotEmpty) {
        return (
          characters: cachedCharacters,
          hasMore: true,
        );
      }
      rethrow;
    }
  }
}

final characterListProvider = NotifierProvider<CharacterListNotifier, CharacterListState>(() {
  return CharacterListNotifier();
});