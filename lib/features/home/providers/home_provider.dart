import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:rickandmorty/core/models/character_model.dart';

final characterListProvider = StateNotifierProvider<CharacterListNotifier, AsyncValue<List<Character>>>((ref) {
  return CharacterListNotifier();
});

class CharacterListNotifier extends StateNotifier<AsyncValue<List<Character>>> {
  CharacterListNotifier() : super(const AsyncValue.loading()) {
    fetchInitial();
  }

  int _currentPage = 1;
  bool _isFetchingMore = false;

  Future<void> fetchInitial() async {
    state = const AsyncValue.loading();
    try {
      //  Fetch from API or SQLite Cache
      //  Fetch local Edits from SQLite
      //  Fetch Favorites from SQLite
      //  Map and merge: character.mergeWithEdits(edits)
      
      final List<Character> mergedCharacters = []; 
      
      state = AsyncValue.data(mergedCharacters);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (_isFetchingMore) return;
    _isFetchingMore = true;
    _currentPage++;
    
    // Fetch next page, merge with local DB edits/favorites, and append to state
    
    
    _isFetchingMore = false;
  }
}