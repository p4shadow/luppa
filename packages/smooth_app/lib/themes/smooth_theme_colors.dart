import 'package:flutter/material.dart';

class SmoothColorsThemeExtension
    extends ThemeExtension<SmoothColorsThemeExtension> {
  SmoothColorsThemeExtension({
    required this.primaryUltraBlack,
    required this.primaryBlack,
    required this.primaryDark,
    required this.primarySemiDark,
    required this.primaryTone,
    required this.primaryNormal,
    required this.primaryAccent,
    required this.primaryMedium,
    required this.primaryLight,
    required this.secondaryNormal,
    required this.secondaryVibrant,
    required this.secondaryLight,
    required this.error,
    required this.successBackground,
    required this.warning,
    required this.warningBackground,
    required this.success,
    required this.errorBackground,
    required this.greyDark,
    required this.greyNormal,
    required this.greyMedium,
    required this.greyLight,
    required this.cellOdd,
    required this.cellEven,
    required this.nova,
    required this.recommendation,
  });

  SmoothColorsThemeExtension.defaultValues(bool lightTheme)
    : primaryUltraBlack = const Color(0xFF2E7D32), // Verde Yuka oscuro
      primaryBlack = const Color(0xFF1B5E20), // Verde Yuka profundo
      primaryDark = const Color(0xFF388E3C), // Verde Yuka intenso
      primarySemiDark = const Color(0xFF43A047), // Verde Yuka medio
      primaryTone = const Color(0xFF66BB6A), // Verde Yuka suave
      primaryAccent = const Color(0xFF81C784), // Verde Yuka claro
      primaryNormal = const Color(0xFFA5D6A7), // Verde Yuka muy claro
      primaryMedium = const Color(0xFFC8E6C9), // Verde Yuka pastel
      primaryLight = const Color(0xE8F5E9), // Verde Yuka extremadamente claro
      secondaryNormal = const Color(0xFFFF5722), // Naranja Yuka
      secondaryVibrant = const Color(0xFFFF7043), // Coral Yuka
      secondaryLight = const Color(0xFFFF8A65), // Coral Yuka suave
      success = const Color(0xFF43A047), // Verde éxito Yuka
      successBackground = const Color(0xFFE8F5E9), // Fondo verde Yuka claro
      warning = const Color(0xFFFF5722), // Naranja advertencia Yuka
      warningBackground = const Color(0xFFFFF3E0), // Fondo naranja Yuka claro
      error = const Color(0xFFEF5350), // Rojo error Yuka
      errorBackground = const Color(0xFFFFEBEE), // Fondo rojo Yuka claro
      greyDark = const Color(0xFF757575), // Gris oscuro Yuka
      greyNormal = const Color(0xFF9E9E9E), // Gris medio Yuka
      greyMedium = const Color(0xFFE0E0E0), // Gris claro Yuka
      greyLight = const Color(0xFFF5F5F5), // Gris muy claro Yuka
      cellOdd = lightTheme ? const Color(0xFFE8F5E9) : const Color(0xFF2E7D32),
      cellEven = lightTheme ? const Color(0xFFFFFFFF) : const Color(0xFF1B5E20),
      nova = const Color(0xFFFFAB91), // Coral Yuka suave
      recommendation = const Color(0xFFFFE082); // Amarillo Yuka claro

  // Ristreto
  final Color primaryUltraBlack;

  // Chocolate
  final Color primaryBlack;

  // Cortado
  final Color primaryDark;

  // Mocha
  final Color primarySemiDark;

  // Darker Macchiato (from old palette)
  final Color primaryTone;

  // Macchiato
  final Color primaryNormal;
  final Color primaryAccent;

  // Cappuccino
  final Color primaryMedium;

  // Latte
  final Color primaryLight;
  final Color secondaryNormal;
  final Color secondaryVibrant;
  final Color secondaryLight;

  final Color error;
  final Color errorBackground;
  final Color warning;
  final Color warningBackground;
  final Color success;
  final Color successBackground;

  final Color greyDark;
  final Color greyNormal;
  final Color greyMedium;
  final Color greyLight;

  final Color cellOdd;
  final Color cellEven;
  final Color nova;
  final Color recommendation;

  @override
  ThemeExtension<SmoothColorsThemeExtension> copyWith({
    Color? primaryUltraBlack,
    Color? primaryBlack,
    Color? primaryDark,
    Color? primarySemiDark,
    Color? primaryTone,
    Color? primaryNormal,
    Color? primaryAccent,
    Color? primaryMedium,
    Color? primaryLight,
    Color? secondaryNormal,
    Color? secondaryLight,
    Color? secondaryVibrant,
    Color? error,
    Color? errorBackground,
    Color? warning,
    Color? warningBackground,
    Color? success,
    Color? successBackground,
    Color? greyDark,
    Color? greyNormal,
    Color? greyMedium,
    Color? greyLight,
    Color? cellOdd,
    Color? cellEven,
    Color? nova,
    Color? recommendation,
  }) {
    return SmoothColorsThemeExtension(
      primaryUltraBlack: primaryUltraBlack ?? this.primaryUltraBlack,
      primaryBlack: primaryBlack ?? this.primaryBlack,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySemiDark: primarySemiDark ?? this.primarySemiDark,
      primaryTone: primaryTone ?? this.primaryTone,
      primaryNormal: primaryNormal ?? this.primaryNormal,
      primaryAccent: primaryAccent ?? this.primaryAccent,
      primaryMedium: primaryMedium ?? this.primaryMedium,
      primaryLight: primaryLight ?? this.primaryLight,
      secondaryNormal: secondaryNormal ?? this.secondaryNormal,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      secondaryVibrant: secondaryVibrant ?? this.secondaryVibrant,
      error: error ?? this.error,
      errorBackground: errorBackground ?? this.errorBackground,
      warning: warning ?? this.warning,
      warningBackground: warningBackground ?? this.warningBackground,
      success: success ?? this.success,
      successBackground: successBackground ?? this.successBackground,
      greyDark: greyDark ?? this.greyDark,
      greyNormal: greyDark ?? this.greyDark,
      greyMedium: greyMedium ?? this.greyMedium,
      greyLight: greyLight ?? this.greyLight,
      cellOdd: cellOdd ?? this.cellOdd,
      cellEven: cellEven ?? this.cellEven,
      nova: nova ?? this.nova,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  @override
  ThemeExtension<SmoothColorsThemeExtension> lerp(
    covariant ThemeExtension<SmoothColorsThemeExtension>? other,
    double t,
  ) {
    if (other is! SmoothColorsThemeExtension) {
      return this;
    }

    return SmoothColorsThemeExtension(
      primaryUltraBlack: Color.lerp(
        primaryUltraBlack,
        other.primaryUltraBlack,
        t,
      )!,
      primaryBlack: Color.lerp(primaryBlack, other.primaryBlack, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primarySemiDark: Color.lerp(primarySemiDark, other.primarySemiDark, t)!,
      primaryTone: Color.lerp(primaryTone, other.primaryTone, t)!,
      primaryNormal: Color.lerp(primaryNormal, other.primaryNormal, t)!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      primaryMedium: Color.lerp(primaryMedium, other.primaryMedium, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      secondaryNormal: Color.lerp(secondaryNormal, other.secondaryNormal, t)!,
      secondaryLight: Color.lerp(secondaryLight, other.secondaryLight, t)!,
      secondaryVibrant: Color.lerp(
        secondaryVibrant,
        other.secondaryVibrant,
        t,
      )!,
      error: Color.lerp(error, other.error, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBackground: Color.lerp(
        warningBackground,
        other.warningBackground,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      successBackground: Color.lerp(
        successBackground,
        other.successBackground,
        t,
      )!,
      greyDark: Color.lerp(greyDark, other.greyDark, t)!,
      greyNormal: Color.lerp(greyNormal, other.greyNormal, t)!,
      greyMedium: Color.lerp(greyMedium, other.greyMedium, t)!,
      greyLight: Color.lerp(greyLight, other.greyLight, t)!,
      cellOdd: Color.lerp(cellOdd, other.cellOdd, t)!,
      cellEven: Color.lerp(cellEven, other.cellEven, t)!,
      nova: Color.lerp(nova, other.nova, t)!,
      recommendation: Color.lerp(recommendation, other.recommendation, t)!,
    );
  }
}
