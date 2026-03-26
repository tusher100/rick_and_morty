import 'package:flutter_test/flutter_test.dart';
import 'package:rickandmorty/core/models/character_model.dart';

void main() {
  group('Character Model Merging Logic', () {
    final originalCharacter = Character(
      id: 1,
      name: 'Rick Sanchez',
      status: 'Alive',
      species: 'Human',
      type: '',
      gender: 'Male',
      originName: 'Earth',
      locationName: 'Earth',
      image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
    );

    test('should merge with null edits correctly (return original)', () {
      final merged = originalCharacter.mergeWithEdits(null);
      expect(merged.name, equals('Rick Sanchez'));
      expect(merged.status, equals('Alive'));
    });

    test('should override name and status when edits are present', () {
      final edits = {
        'name': 'Cool Rick',
        'status': 'Dead',
      };
      
      final merged = originalCharacter.mergeWithEdits(edits);
      
      expect(merged.name, equals('Cool Rick'));
      expect(merged.status, equals('Dead'));
      // Unedited fields should remain original
      expect(merged.species, equals('Human'));
    });

    test('should override all fields correctly', () {
      final edits = {
        'name': 'New Name',
        'status': 'Unknown',
        'species': 'Alien',
        'type': 'Super Alien',
        'gender': 'Genderless',
        'originName': 'Mars',
        'locationName': 'Venus',
      };

      final merged = originalCharacter.mergeWithEdits(edits);

      expect(merged.name, equals('New Name'));
      expect(merged.status, equals('Unknown'));
      expect(merged.species, equals('Alien'));
      expect(merged.type, equals('Super Alien'));
      expect(merged.gender, equals('Genderless'));
      expect(merged.originName, equals('Mars'));
      expect(merged.locationName, equals('Venus'));
      // Image should never be overriden in this implementation
      expect(merged.image, equals(originalCharacter.image));
    });
  });
}
