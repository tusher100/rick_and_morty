import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';

void main() {
  testWidgets('AppText.h1 renders correctly with custom text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) => AppText.h1('Hello World'),
          ),
        ),
      ),
    );

    final textFinder = find.text('Hello World');
    expect(textFinder, findsOneWidget);
    
    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.style?.fontWeight, equals(FontWeight.w900));
  });

  testWidgets('AppText renders gradient when provided', (WidgetTester tester) async {
    const gradient = LinearGradient(colors: [Colors.red, Colors.blue]);
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) => const AppText(
              text: 'Gradient Text',
              gradient: gradient,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ShaderMask), findsOneWidget);
  });
}
