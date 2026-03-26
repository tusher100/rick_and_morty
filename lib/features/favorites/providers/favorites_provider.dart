import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rickandmorty/core/database/sqflite_helper.dart';
import 'package:rickandmorty/core/models/character_model.dart';

class FavoritesNotifier extends AsyncNotifier<List<Character>> {
  @override
  FutureOr<List<Character>> build() async {
    return _loadFavorites();
  }

  Future<List<Character>> _loadFavorites() async {
    return await SqfliteHelper.instance.getFavorites();
  }

  Future<void> toggleFavorite(Character character) async {
    // Optimistic UI update or just reload
    state = const AsyncLoading();
    try {
      await SqfliteHelper.instance.toggleFavorite(character);
      final favorites = await _loadFavorites();
      state = AsyncData(favorites);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, List<Character>>(() {
  return FavoritesNotifier();
});

// A provider to check if a specific ID is favorited (reactive)
final isFavoriteProvider = Provider.family<bool, int>((ref, id) {
  final favoritesState = ref.watch(favoritesProvider);
  return favoritesState.maybeWhen(
    data: (favorites) => favorites.any((c) => c.id == id),
    orElse: () => false,
  );
});
