import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/utils/app_colors.dart';
import 'package:rickandmorty/core/models/character_model.dart';
import 'package:rickandmorty/features/home/widgets/character_card.dart';
import 'package:rickandmorty/features/details/screens/character_details_screen.dart';

class CharacterGridItem extends StatelessWidget {
  final Character character;
  final ValueNotifier<Set<Character>> selections;
  final bool isSelectionMode;
  final Function(Character) onToggleSelection;

  const CharacterGridItem({
    super.key,
    required this.character,
    required this.selections,
    required this.isSelectionMode,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selections.value.any((c) => c.id == character.id);

    return Stack(
      children: [
        CharacterCard(
          key: ValueKey(character.id),
          character: character,
          onTap: null, // Tap handled by overlay
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isSelectionMode) {
                  onToggleSelection(character);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CharacterDetailsScreen(characterId: character.id),
                    ),
                  );
                }
              },
              onLongPress: () => onToggleSelection(character),
              child: isSelected
                  ? _buildSelectionOverlay()
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
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
      child: const CircleAvatar(
        backgroundColor: AppColors.secondary,
        radius: 12,
        child: Icon(Icons.check, color: Colors.white, size: 16),
      ),
    );
  }
}
