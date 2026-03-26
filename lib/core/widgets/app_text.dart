import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText extends StatelessWidget {
  final String? text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final Color? color;
  final bool isUnderlined;
  final Color? underlineColor;
  final Gradient? gradient;
  final double? letterSpacing;
  final double? fontHeight;
  final FontStyle? fontStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final String fontFamily;

  const AppText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.color,
    this.isUnderlined = false,
    this.underlineColor,
    this.gradient,
    this.letterSpacing,
    this.fontHeight,
    this.fontStyle,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    this.fontFamily = 'Rubik',
  });

  // Factory methods for consistent styles
  factory AppText.h1(String text, {Color? color, TextAlign? textAlign}) =>
      AppText(
        text: text,
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
        color: color,
        textAlign: textAlign,
        fontFamily: 'Rubik',
      );

  factory AppText.h2(String text, {Color? color, TextAlign? textAlign}) =>
      AppText(
        text: text,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
        color: color,
        textAlign: textAlign,
        fontFamily: 'Rubik',
      );

  factory AppText.h3(String text, {Color? color, TextAlign? textAlign}) =>
      AppText(
        text: text,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
        textAlign: textAlign,
        fontFamily: 'Rubik',
      );

  factory AppText.bodyLarge(
    String text, {
    Color? color,
    TextAlign? textAlign,
    FontWeight? fontWeight,
  }) => AppText(
    text: text,
    fontSize: 16,
    fontWeight: fontWeight ?? FontWeight.w500,
    color: color,
    textAlign: textAlign,
    fontFamily: 'Plus Jakarta Sans',
  );

  factory AppText.bodyMedium(
    String text, {
    Color? color,
    TextAlign? textAlign,
    FontWeight? fontWeight,
  }) => AppText(
    text: text,
    fontSize: 14,
    fontWeight: fontWeight ?? FontWeight.bold,
    color: color,
    textAlign: textAlign,
    fontFamily: 'Plus Jakarta Sans',
  );

  factory AppText.bodySmall(
    String text, {
    Color? color,
    TextAlign? textAlign,
    FontWeight? fontWeight,
  }) => AppText(
    text: text,
    fontSize: 12,
    fontWeight: fontWeight,
    color: color,
    textAlign: textAlign,
    fontFamily: 'Plus Jakarta Sans',
  );

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width >= 600;
    final defaultColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;

    final textStyle = GoogleFonts.getFont(fontFamily).copyWith(
      fontSize: isTablet
          ? (fontSize != null ? fontSize! * 0.96 : null)
          : fontSize?.sp,
      fontWeight: fontWeight,
      color: gradient != null ? null : color ?? defaultColor,
      decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,
      decorationColor: isUnderlined ? (underlineColor ?? defaultColor) : null,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      height: isTablet ? (fontHeight == null ? null : 0) : fontHeight,
    );

    final textWidget = Text(
      text ?? '',
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      softWrap: softWrap,
      style: textStyle,
    );

    if (gradient != null) {
      return ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => gradient!.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        ),
        child: textWidget,
      );
    }

    return textWidget;
  }

  // Static helpers for cases where a TextStyle is needed (e.g. Buttons, InputFields)
  static TextStyle getStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    String fontFamily = 'Rubik',
  }) {
    return GoogleFonts.getFont(
      fontFamily,
    ).copyWith(fontSize: fontSize?.sp, fontWeight: fontWeight, color: color);
  }
}

TextSpan customTextSpan({
  required String text,
  required Color? color,
  bool isUnderlined = false,
  Color? underlineColor,
  Gradient? gradient,
  double? fontSize,
  FontWeight? fontWeight,
  double? letterSpacing,
  double? height,
  FontStyle? fontStyle,
  GestureRecognizer? recognizer,
  String fontFamily = 'Rubik',
}) {
  return TextSpan(
    text: text,
    style: GoogleFonts.getFont(fontFamily).copyWith(
      fontSize: fontSize?.sp,
      fontWeight: fontWeight,
      color: gradient != null
          ? null
          : color ?? (fontWeight == FontWeight.bold ? Colors.white : Colors.white70),
      decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,
      decorationColor: isUnderlined ? (underlineColor ?? Colors.black) : null,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      height: (height != null && fontSize != null) ? height / fontSize : null,
    ),
    recognizer: recognizer,
  );
}
