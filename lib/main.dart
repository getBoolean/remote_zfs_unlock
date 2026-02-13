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
    return MaterialApp(
      title: 'Remote ZFS Unlock',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const ServerListScreen(),
    );
  }
}
