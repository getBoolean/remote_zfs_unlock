import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remote_zfs_unlock/providers/app_providers.dart';
import 'package:remote_zfs_unlock/screens/server_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  final box = await Hive.openBox<Map<dynamic, dynamic>>(serverProfilesBoxName);

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
      home: const ServerListScreen(),
    );
  }
}
