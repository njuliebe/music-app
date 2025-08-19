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
    version: 3,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS playlists (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          coverUrl TEXT,
          creator TEXT,
          type TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS songs (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          artist TEXT NOT NULL,
          href TEXT NOT NULL,
          play_url TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS playlist_songs (
          playlist_id TEXT NOT NULL,
          song_id TEXT NOT NULL,
          PRIMARY KEY (playlist_id, song_id),
          FOREIGN KEY (playlist_id) REFERENCES playlists (id) ON DELETE CASCADE,
          FOREIGN KEY (song_id) REFERENCES songs (id) ON DELETE CASCADE
        )
      ''');
    },

    onUpgrade: (db, oldVersion, newVersion) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS playlists (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          coverUrl TEXT,
          creator TEXT,
          type TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS songs (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          artist TEXT NOT NULL,
          href TEXT NOT NULL,
          play_url TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS playlist_songs (
          playlist_id TEXT NOT NULL,
          song_id TEXT NOT NULL,
          PRIMARY KEY (playlist_id, song_id),
          FOREIGN KEY (playlist_id) REFERENCES playlists (id) ON DELETE CASCADE,
          FOREIGN KEY (song_id) REFERENCES songs (id) ON DELETE CASCADE
        )
      ''');
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
