import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rickandmorty/core/database/sqflite_helper.dart';

class LocalEditsNotifier extends AsyncNotifier<Map<int, Map<String, dynamic>>> {
  @override
  FutureOr<Map<int, Map<String, dynamic>>> build() async {
    return _loadEdits();
  }

  Future<Map<int, Map<String, dynamic>>> _loadEdits() async {
    return await SqfliteHelper.instance.getAllLocalEdits();
  }

  Future<void> saveEdit(int id, Map<String, dynamic> editData) async {
    state = const AsyncLoading();
    try {
      await SqfliteHelper.instance.saveLocalEdit({'id': id, ...editData});
      final updatedEdits = await _loadEdits();
      state = AsyncData(updatedEdits);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteEdit(int id) async {
    state = const AsyncLoading();
    try {
      await SqfliteHelper.instance.deleteLocalEdit(id);
      final updatedEdits = await _loadEdits();
      state = AsyncData(updatedEdits);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final localEditsProvider =
    AsyncNotifierProvider<LocalEditsNotifier, Map<int, Map<String, dynamic>>>(
      () {
        return LocalEditsNotifier();
      },
    );

// A provider to get edits for a specific character ID (reactive)
final characterEditProvider = Provider.family<Map<String, dynamic>?, int>((
  ref,
  id,
) {
  final editsState = ref.watch(localEditsProvider);
  return editsState.maybeWhen(data: (edits) => edits[id], orElse: () => null);
});
