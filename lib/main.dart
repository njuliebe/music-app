import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/data/repositories/playlist_repository.dart';
import 'package:music_app/src/shared/shell/main_scaffold.dart';
import 'package:music_app/src/shared/theme/app_theme.dart';
import 'package:path/path.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// 1. Define a provider for the Database.
// It throws by default, because we will provide its actual value
// at the root of the application in `ProviderScope`.
final databaseProvider = Provider<Database>((ref) {
  throw UnimplementedError('Database provider was not overridden');
});

// 2. The repository provider now safely depends on the synchronous databaseProvider.
final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PlaylistRepository(db: db);
});

// 3. The FutureProvider for playlists now has a much simpler, safer dependency chain.
final playlistsFutureProvider = FutureProvider.autoDispose<List<Playlist>>((
  ref,
) {
  final repository = ref.watch(playlistRepositoryProvider);
  return repository.getAllPlaylists();
});

Future<void> main() async {
  // --- CENTRALIZED INITIALIZATION ---
  WidgetsFlutterBinding.ensureInitialized();

  // FFI init for desktop
  if (!kIsWeb && Platform.isWindows || Platform.isLinux) {
    databaseFactory = databaseFactoryFfi;
    sqfliteFfiInit();
  }

  // Open the database and prepare the instance
  final db = await openDatabase(
    join(await getDatabasesPath(), 'music_app.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE playlists (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          coverUrl TEXT,
          creator TEXT,
          type TEXT NOT NULL
        )
      ''');
      // Insert sample data
      await db.insert('playlists', {
        'name': '我的最爱',
        'description': '一些精选好歌',
        'creator': 'Liebe',
        'type': PlaylistType.created.name,
      });
      await db.insert('playlists', {
        'name': '学习时听的歌',
        'description': '专注 BGM',
        'creator': 'Liebe',
        'type': PlaylistType.created.name,
      });
    },
  );
  // --- END OF INITIALIZATION ---

  runApp(
    ProviderScope(
      // Override the provider with the REAL, initialized database instance.
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainScaffold(),
    );
  }
}
