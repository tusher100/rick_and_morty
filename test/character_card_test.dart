import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/models/character_model.dart';
import 'package:rickandmorty/features/home/widgets/character_card.dart';

void main() {
  final testCharacter = Character(
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

  testWidgets('CharacterCard displays name and status', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ScreenUtilInit(
              designSize: const Size(360, 690),
              builder: (context, child) => CharacterCard(character: testCharacter),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Alive • Human'), findsOneWidget);
  });
}
