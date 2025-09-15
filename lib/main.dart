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
    version: 6, // Incremented version to trigger onUpgrade
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE playlists (
          pk_id INTEGER PRIMARY KEY AUTOINCREMENT,
          source_id TEXT UNIQUE,
          name TEXT NOT NULL,
          description TEXT,
          coverUrl TEXT,
          creator TEXT,
          type TEXT NOT NULL,
          import_time INTEGER NOT NULL,
          original_url TEXT,
          source TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE playlist_songs (
          pk_id INTEGER PRIMARY KEY AUTOINCREMENT,
          playlist_id TEXT NOT NULL,
          song_title TEXT NOT NULL,
          artist TEXT NOT NULL,
          play_url TEXT,
          FOREIGN KEY (playlist_id) REFERENCES playlists (source_id) ON DELETE CASCADE,
          UNIQUE (playlist_id, song_title, artist)
        )
      ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      // This is a simple migration strategy that DROPS and RECREATES tables.
      // All existing data will be lost. For a production app, a more
      // sophisticated data migration strategy would be required.
      if (oldVersion < 6) {
        await db.execute('DROP TABLE IF EXISTS playlists');
        await db.execute('DROP TABLE IF EXISTS playlist_songs');
        await db.execute('DROP TABLE IF EXISTS songs'); // Also drop legacy songs table

        // Re-create tables with the new schema
        await db.execute('''
          CREATE TABLE playlists (
            pk_id INTEGER PRIMARY KEY AUTOINCREMENT,
            source_id TEXT UNIQUE,
            name TEXT NOT NULL,
            description TEXT,
            coverUrl TEXT,
            creator TEXT,
            type TEXT NOT NULL,
            import_time INTEGER NOT NULL,
            original_url TEXT,
            source TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE playlist_songs (
            pk_id INTEGER PRIMARY KEY AUTOINCREMENT,
            playlist_id TEXT NOT NULL,
            song_title TEXT NOT NULL,
            artist TEXT NOT NULL,
            play_url TEXT,
            FOREIGN KEY (playlist_id) REFERENCES playlists (source_id) ON DELETE CASCADE,
            UNIQUE (playlist_id, song_title, artist)
          )
        ''');
      }
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
      title: 'MusicX',
      theme: AppTheme.theme,
      home: const MainScaffold(),
    );
  }
}
