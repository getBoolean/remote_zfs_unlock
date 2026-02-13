import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
      backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      selectedColor: scheme.primary.withValues(alpha: 0.25),
      disabledColor: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      iconTheme: IconThemeData(color: scheme.primary, size: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
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
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface.withValues(alpha: 0.96),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.75),
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF101C31),
      contentTextStyle: TextStyle(
        color: const Color(0xFFEAF5FF),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFF63D9FF).withValues(alpha: 0.72),
          width: 1.1,
        ),
      ),
      actionTextColor: const Color(0xFF7AF2FF),
      elevation: 14,
      showCloseIcon: true,
      closeIconColor: const Color(0xFF9FEAFF),
    ),
  );
}
