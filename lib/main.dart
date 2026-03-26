import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/features/home/screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Rick & Morty Explorer',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: GoogleFonts.rubikTextTheme(
              Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}