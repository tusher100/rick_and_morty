import 'package:flutter/material.dart';
import 'package:rickandmorty/core/widgets/app_text.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppText.h3(title);
  }
}
