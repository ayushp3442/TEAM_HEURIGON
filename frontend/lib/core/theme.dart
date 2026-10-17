import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// COLOR TOKENS
// No pure white, no rainbow, no neon, no pastels, no purple-and-black.
// One primary (deep green) + one accent (terracotta) + warm neutrals.
// ---------------------------------------------------------------------------
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFFF5F1E8); // warm paper
  static const Color surface    = Color(0xFFFBF9F4); // card surface
  static const Color border     = Color(0xFFDAD3C3); // 1-px separators

  // Text
  static const Color ink        = Color(0xFF1E2622); // primary text
  static const Color muted      = Color(0xFF5C665F); // secondary text

  // Brand
  static const Color primary    = Color(0xFF1F5A47); // deep green
  static const Color primaryDark= Color(0xFF164035); // hover/pressed
  static const Color onPrimary  = Color(0xFFFFFFFF);
  static const Color accent     = Color(0xFFB8532A); // terracotta – use sparingly

  // Request status
  static const Color pending    = Color(0xFF9A6B12);
  static const Color accepted   = Color(0xFF2F6B3A);
  static const Color declined   = Color(0xFF9B3B32);
  static const Color cancelled  = Color(0xFF6B6F6C);

  // Status backgrounds (very light tints)
  static const Color pendingBg   = Color(0xFFFDF3DC);
  static const Color acceptedBg  = Color(0xFFDFF0E3);
  static const Color declinedBg  = Color(0xFFFAE0DD);
  static const Color cancelledBg = Color(0xFFEEEEEE);

  // Utility
  static const Color error       = Color(0xFF9B3B32);
  static const Color success     = Color(0xFF2F6B3A);
  static const Color white       = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
}

// ---------------------------------------------------------------------------
// TYPOGRAPHY TOKENS
// Headings: Newsreader (serif). Body + UI: Public Sans.
// NOT Inter, NOT Geist, NOT Space Grotesk.
// Scale: 28 / 22 / 18 / 16 / 14 / 12 — left-aligned everywhere.
// ---------------------------------------------------------------------------
class AppTextStyles {
  AppTextStyles._();

  static TextTheme buildTextTheme() {
    const newsreader = GoogleFonts.newsreader;
    const publicSans  = GoogleFonts.publicSans;

    return TextTheme(
      // Display / headings
      displayLarge:  newsreader(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.3),
      displayMedium: newsreader(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.35),
      displaySmall:  newsreader(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.4),

      // Headlines (used for card titles etc.)
      headlineLarge:  publicSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink),
      headlineMedium: publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
      headlineSmall:  publicSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),

      // Body text
      bodyLarge:   publicSans(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.ink, height: 1.55),
      bodyMedium:  publicSans(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.ink, height: 1.5),
      bodySmall:   publicSans(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.muted, height: 1.45),

      // Labels / UI elements
      labelLarge:  publicSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink),
      labelMedium: publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.muted),
      labelSmall:  publicSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.muted),

      // Title
      titleLarge:  publicSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink),
      titleMedium: publicSans(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.ink),
      titleSmall:  publicSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink),
    );
  }
}

// ---------------------------------------------------------------------------
// THEME
// Material 3 on, but defaults overridden:
// - elevation 0 everywhere (no drop shadows)
// - surfaceTintColor transparent
// - corner radius 6 (not soft large rounding)
// - 1-px borders instead of shadows
// - No gradients
// ---------------------------------------------------------------------------
class AppTheme {
  AppTheme._();

  static const double _radius = 6.0;
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(_radius));

  static ThemeData build() {
    final textTheme = AppTextStyles.buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness:       Brightness.light,
        primary:          AppColors.primary,
        onPrimary:        AppColors.onPrimary,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: AppColors.onPrimary,
        secondary:        AppColors.accent,
        onSecondary:      AppColors.onPrimary,
        secondaryContainer: Color(0xFFF2DDD5),
        onSecondaryContainer: AppColors.accent,
        error:            AppColors.error,
        onError:          AppColors.onPrimary,
        surface:          AppColors.surface,
        onSurface:        AppColors.ink,
        surfaceContainerHighest: AppColors.background,
        outline:          AppColors.border,
        outlineVariant:   AppColors.border,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,

      // ----- App Bar -----
      appBarTheme: AppBarTheme(
        backgroundColor:  AppColors.surface,
        foregroundColor:  AppColors.ink,
        elevation:        0,
        shadowColor:      AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        titleTextStyle:   GoogleFonts.publicSans(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink,
        ),
        shape: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),

      // ----- Cards -----
      cardTheme: const CardThemeData(
        color:            AppColors.surface,
        elevation:        0,
        shadowColor:      AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ----- Input Decoration -----
      inputDecorationTheme: InputDecorationTheme(
        filled:           false,
        contentPadding:   const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.publicSans(fontSize: 14, color: AppColors.muted),
        hintStyle:  GoogleFonts.publicSans(fontSize: 14, color: AppColors.muted),
        errorStyle: GoogleFonts.publicSans(fontSize: 12, color: AppColors.error),
      ),

      // ----- Filled Button (primary actions) -----
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered)) {
              return AppColors.primaryDark;
            }
            if (states.contains(WidgetState.disabled)) {
              return AppColors.border;
            }
            return AppColors.primary;
          }),
          foregroundColor: WidgetStateProperty.all(AppColors.onPrimary),
          elevation:        WidgetStateProperty.all(0),
          shadowColor:      WidgetStateProperty.all(AppColors.transparent),
          overlayColor:     WidgetStateProperty.all(AppColors.transparent),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(borderRadius: borderRadius),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),

      // ----- Outlined Button (secondary actions) -----
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed)) {
              return AppColors.background;
            }
            return AppColors.transparent;
          }),
          foregroundColor:  WidgetStateProperty.all(AppColors.primary),
          overlayColor:     WidgetStateProperty.all(AppColors.transparent),
          elevation:        WidgetStateProperty.all(0),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.primary),
          ),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(borderRadius: borderRadius),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ),

      // ----- Text Button -----
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(AppColors.primary),
          overlayColor:    WidgetStateProperty.all(AppColors.transparent),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),

      // ----- Chips -----
      chipTheme: ChipThemeData(
        backgroundColor:  AppColors.surface,
        selectedColor:    AppColors.primary,
        labelStyle: GoogleFonts.publicSans(fontSize: 12, color: AppColors.ink),
        side:  const BorderSide(color: AppColors.border),
        shape: const StadiumBorder(), // pills for chips
        elevation:        0,
        pressElevation:   0,
        padding:          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ----- Dialogs -----
      dialogTheme: DialogThemeData(
        backgroundColor:  AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation:        0,
        shadowColor:      AppColors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: AppColors.border),
        ),
        titleTextStyle: GoogleFonts.newsreader(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink,
        ),
        contentTextStyle: GoogleFonts.publicSans(
          fontSize: 14, color: AppColors.ink,
        ),
      ),

      // ----- Snack Bars -----
      snackBarTheme: SnackBarThemeData(
        backgroundColor:    AppColors.ink,
        contentTextStyle:   GoogleFonts.publicSans(fontSize: 14, color: AppColors.white),
        actionTextColor:    AppColors.accent,
        behavior:           SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: borderRadius),
        elevation:          0,
      ),

      // ----- Tab Bar -----
      tabBarTheme: TabBarThemeData(
        labelColor:         AppColors.primary,
        unselectedLabelColor: AppColors.muted,
        labelStyle:   GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w400),
        indicatorColor:     AppColors.primary,
        indicatorSize:      TabBarIndicatorSize.label,
        dividerColor:       AppColors.border,
        overlayColor:       WidgetStateProperty.all(AppColors.transparent),
      ),

      // ----- Navigation Rail -----
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor:    AppColors.surface,
        selectedIconTheme:  const IconThemeData(color: AppColors.primary, size: 22),
        unselectedIconTheme:const IconThemeData(color: AppColors.muted,   size: 22),
        selectedLabelTextStyle: GoogleFonts.publicSans(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary,
        ),
        unselectedLabelTextStyle: GoogleFonts.publicSans(
          fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.muted,
        ),
        elevation: 0,
        indicatorColor: AppColors.background,
        useIndicator: true,
      ),

      // ----- Navigation Bar (bottom) -----
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:    AppColors.surface,
        indicatorColor:     AppColors.background,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 22);
          }
          return const IconThemeData(color: AppColors.muted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary);
          }
          return GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.muted);
        }),
        elevation: 0,
        shadowColor: AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        height: 64,
      ),

      // ----- Divider -----
      dividerTheme: const DividerThemeData(
        color:     AppColors.border,
        thickness: 1,
        space:     1,
      ),

      // ----- List Tile -----
      listTileTheme: const ListTileThemeData(
        tileColor:         AppColors.transparent,
        selectedTileColor: AppColors.background,
        contentPadding:    EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor:         AppColors.muted,
        textColor:         AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),

      // ----- Bottom Sheet -----
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor:    AppColors.surface,
        surfaceTintColor:   AppColors.transparent,
        elevation:          0,
        shadowColor:        AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          side: BorderSide(color: AppColors.border),
        ),
      ),

      // ----- Progress Indicator -----
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color:              AppColors.primary,
        linearTrackColor:   AppColors.border,
      ),

      // ----- Floating Action Button -----
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor:    AppColors.primary,
        foregroundColor:    AppColors.onPrimary,
        elevation:          0,
        focusElevation:     0,
        hoverElevation:     0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
    );
  }
}
