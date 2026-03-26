import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';
import 'package:rickandmorty/core/models/character_model.dart';
import 'package:rickandmorty/features/favorites/providers/favorites_provider.dart';
import 'package:rickandmorty/features/editing/providers/local_edits_provider.dart';

class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueNotifier<Set<Character>> selections;

  const SelectionAppBar({super.key, required this.selections});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return AppBar(
          backgroundColor: AppColors.secondary,
          title: AppText.bodyLarge(
            '${selections.value.length} Selected',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => selections.value = {},
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.white),
              onPressed: () async {
                for (var c in selections.value) {
                  await ref
                      .read(favoritesProvider.notifier)
                      .setFavorite(c, true);
                }
                selections.value = {};
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to favorites!')),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.restore, color: Colors.white),
              onPressed: () async {
                for (var c in selections.value) {
                  await ref.read(localEditsProvider.notifier).deleteEdit(c.id);
                }
                selections.value = {};
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Restored selected characters!'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
