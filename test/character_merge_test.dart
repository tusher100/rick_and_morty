import 'package:flutter_test/flutter_test.dart';
import 'package:rickandmorty/core/models/character_model.dart';

void main() {
  group('Character Model Merging', () {
    final originalCharacter = Character(
      id: 1,
      name: 'Rick Sanchez',
      status: 'Alive',
      species: 'Human',
      type: '',
      gender: 'Male',
      originName: 'Earth (C-137)',
      locationName: 'Citadel of Ricks',
      image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
    );

    test('mergeWithEdits should override original fields with user edits', () {
      final edits = {
        'id': 1,
        'name': 'Modified Rick',
        'status': 'Dead',
        'species': 'Cyborg',
        'type': 'Prototype',
        'gender': 'Unknown',
        'originName': 'Unknown World',
        'locationName': 'Deep Space',
      };

      final merged = originalCharacter.mergeWithEdits(edits);

      expect(merged.name, 'Modified Rick');
      expect(merged.status, 'Dead');
      expect(merged.species, 'Cyborg');
      expect(merged.type, 'Prototype');
      expect(merged.gender, 'Unknown');
      expect(merged.originName, 'Unknown World');
      expect(merged.locationName, 'Deep Space');
      // Image should remain the same
      expect(merged.image, originalCharacter.image);
    });

    test('mergeWithEdits should keep original fields if no edits provided', () {
      final merged = originalCharacter.mergeWithEdits(null);

      expect(merged.name, originalCharacter.name);
      expect(merged.status, originalCharacter.status);
      expect(merged.species, originalCharacter.species);
      expect(merged.originName, originalCharacter.originName);
      expect(merged.locationName, originalCharacter.locationName);
    });

    test('mergeWithEdits should handle partial edits correctly', () {
      final partialEdits = {
        'id': 1,
        'name': 'Only Name Changed',
      };

      final merged = originalCharacter.mergeWithEdits(partialEdits);

      expect(merged.name, 'Only Name Changed');
      expect(merged.status, originalCharacter.status);
      expect(merged.species, originalCharacter.species);
    });
  });
}
