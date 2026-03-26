import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rickandmorty/core/models/character_model.dart';
import 'package:rickandmorty/core/database/sqflite_helper.dart';
import 'package:rickandmorty/features/home/providers/home_provider.dart';

// Provider to get a character by ID, looking in memory first, then DB
final characterDetailProvider = FutureProvider.family<Character?, int>((ref, id) async {
  // Check current home list in memory
  final homeState = ref.watch(characterListProvider);
  final characters = homeState.characters.asData?.value;
  if (characters != null) {
    try {
      return characters.firstWhere((c) => c.id == id);
    } catch (_) {
      // Not in current loaded list (maybe it's a favorite from another page)
    }
  }

  // Check DB cache
  final cached = await SqfliteHelper.instance.getCachedCharacters();
  try {
    return cached.firstWhere((c) => c.id == id);
  } catch (_) {
    // Not in cache either
  }

  // Last fallback: try fetching from API specifically (not usually needed if we cache everything)
  // For now, we rely on the list being the source of truth for IDs we know about.
  return null;
});
