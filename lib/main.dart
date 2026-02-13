import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remote_zfs_unlock/providers/app_providers.dart';
import 'package:remote_zfs_unlock/screens/server_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Web uses IndexedDB; an arbitrary base path is sufficient.
    Hive.init('remote_zfs_unlock');
  } else {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
  }
  final box = await Hive.openBox<Map<dynamic, dynamic>>(serverProfilesBoxName);
  await Hive.openBox<List<dynamic>>(uiPreferencesBoxName);

  runApp(
    ProviderScope(
      overrides: [serverProfilesBoxProvider.overrideWithValue(box)],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final futuristicDarkTheme = _buildFuturisticDarkTheme();
    return MaterialApp(
      title: 'Remote ZFS Unlock',
      debugShowCheckedModeBanner: false,
      theme: futuristicDarkTheme,
      darkTheme: futuristicDarkTheme,
      themeMode: ThemeMode.dark,
      home: const ServerListScreen(),
    );
  }
}

ThemeData _buildFuturisticDarkTheme() {
  const seedBlue = Color(0xFF3F8CFF);
  final baseScheme = ColorScheme.fromSeed(
    seedColor: seedBlue,
    brightness: Brightness.dark,
  );
  final scheme = baseScheme.copyWith(
    primary: const Color(0xFF79C7FF),
    onPrimary: const Color(0xFF001425),
    secondary: const Color(0xFF57F4FF),
    onSecondary: const Color(0xFF002024),
    tertiary: const Color(0xFF9B8CFF),
    onTertiary: const Color(0xFF1A103A),
    surface: const Color(0xFF0A101C),
    onSurface: const Color(0xFFE5EEFF),
    surfaceContainerHighest: const Color(0xFF1A2438),
    outline: const Color(0xFF44577D),
    outlineVariant: const Color(0xFF2A3854),
  );

  final titleText = const TextStyle(
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF060B16),
    canvasColor: const Color(0xFF060B16),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF071327),
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      scrolledUnderElevation: 10,
      iconTheme: IconThemeData(
        color: scheme.onSurface.withValues(alpha: 0.96),
        size: 22,
      ),
      actionsIconTheme: IconThemeData(
        color: scheme.primary.withValues(alpha: 0.95),
        size: 22,
      ),
      titleTextStyle: titleText.copyWith(
        color: scheme.onSurface,
        fontSize: 24,
        letterSpacing: 0.45,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.62),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      margin: const EdgeInsets.symmetric(vertical: 6),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.95)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFAEDFFF).withValues(alpha: 0.18),
      selectedColor: const Color(0xFF4EB8FF).withValues(alpha: 0.5),
      disabledColor: const Color(0xFF9FC3DD).withValues(alpha: 0.1),
      shadowColor: const Color(0xFF8EE9FF).withValues(alpha: 0.16),
      selectedShadowColor: const Color(0xFFB9F3FF).withValues(alpha: 0.34),
      surfaceTintColor: Colors.white.withValues(alpha: 0.12),
      elevation: 0,
      pressElevation: 1.4,
      side: BorderSide(
        color: const Color(0xFFEAF7FF).withValues(alpha: 0.2),
        width: 0.75,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      labelStyle: TextStyle(
        color: const Color(0xFFF5FCFF).withValues(alpha: 0.98),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.32,
      ),
      secondaryLabelStyle: TextStyle(
        color: const Color(0xFFF2FDFF).withValues(alpha: 1),
        fontWeight: FontWeight.w800,
        letterSpacing: 0.32,
      ),
      checkmarkColor: const Color(0xFFE8FDFF).withValues(alpha: 0.99),
      iconTheme: IconThemeData(
        color: const Color(0xFFEAF9FF).withValues(alpha: 0.98),
        size: 16,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.primary,
      textColor: scheme.onSurface,
      tileColor: scheme.surface.withValues(alpha: 0.08),
      selectedTileColor: scheme.primary.withValues(alpha: 0.14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary.withValues(alpha: 0.9),
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary.withValues(alpha: 0.85),
      foregroundColor: scheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.9)),
      hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.secondary.withValues(alpha: 0.8)),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0A162A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.secondary.withValues(alpha: 0.6),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.secondary.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.secondary.withValues(alpha: 0.85),
            width: 1.2,
          ),
        ),
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(const Color(0xFF0A162A)),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: WidgetStatePropertyAll(
          scheme.secondary.withValues(alpha: 0.2),
        ),
        elevation: const WidgetStatePropertyAll(14),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: scheme.secondary.withValues(alpha: 0.65),
              width: 1.1,
            ),
          ),
        ),
      ),
      textStyle: const TextStyle(
        color: Color(0xFFEAF5FF),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF0B1324),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: scheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      elevation: 16,
      shadowColor: scheme.secondary.withValues(alpha: 0.22),
      titleTextStyle: TextStyle(
        color: const Color(0xFFF2F8FF),
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.35,
      ),
      contentTextStyle: TextStyle(
        color: scheme.onSurface.withValues(alpha: 0.93),
        fontSize: 14.5,
        height: 1.35,
        letterSpacing: 0.15,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.75),
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color.fromARGB(255, 19, 43, 65),
      contentTextStyle: TextStyle(
        color: const Color(0xFFF3FCFF).withValues(alpha: 0.98),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: const Color(0xFFEAF7FF).withValues(alpha: 0.24),
          width: 0.85,
        ),
      ),
      actionTextColor: const Color(0xFFD8F7FF).withValues(alpha: 0.98),
      elevation: 4,
      showCloseIcon: true,
      closeIconColor: const Color(0xFFE6FAFF).withValues(alpha: 0.96),
    ),
  );
}
