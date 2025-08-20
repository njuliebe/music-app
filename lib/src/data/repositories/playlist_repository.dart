import 'package:music_app/src/data/models/playlist_song.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:sqflite/sqflite.dart';
import 'package:music_app/src/data/services/playlist_import_service.dart';

class PlaylistRepository {
  final Database _db;
  static const int pageSize = 500; // Common page size

  PlaylistRepository({required Database db}) : _db = db;

  Future<List<Playlist>> getPlaylists({int page = 1}) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'playlists',
      orderBy: 'import_time DESC',
      limit: pageSize,
      offset: (page - 1) * pageSize,
    );
    return List.generate(maps.length, (i) {
      return Playlist.fromMap(maps[i]);
    });
  }

  Future<List<PlaylistSong>> getSongsForPlaylist(
    String playlistId, {
    int page = 1,
  }) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'playlist_songs',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
      orderBy: 'pk_id ASC', // Order by the auto-incrementing key
      limit: pageSize,
      offset: (page - 1) * pageSize,
    );

    return List.generate(maps.length, (i) {
      return PlaylistSong.fromJson(maps[i]);
    });
  }

  Future<void> addSongToPlaylist(String playlistId, PlaylistSong song) async {
    // The `song` object should have the playlistId (source_id) set correctly.
    await _db.insert(
      'playlist_songs',
      song.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeSongFromPlaylist(
    String playlistId,
    String songTitle,
    String artist,
  ) async {
    await _db.delete(
      'playlist_songs',
      where: 'playlist_id = ? AND song_title = ? AND artist = ?',
      whereArgs: [playlistId, songTitle, artist],
    );
  }

  Future<void> saveImportedPlaylist(ImportedPlaylist importedPlaylist) async {
    await _db.transaction((txn) async {
      // 1. Save/Update the playlist itself
      final playlist = Playlist(
        sourceId: importedPlaylist.id, // This is the ID from the source URL
        name: importedPlaylist.name,
        type: PlaylistType.collected,
        description: null,
        coverUrl: null,
        creator: 'Imported',
        importTime: DateTime.now(), // Set the import time
      );

      // Since source_id is UNIQUE, `insert` with `replace` will work as an upsert.
      await txn.insert(
        'playlists',
        playlist.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Clear existing songs for this playlist to avoid duplicates on re-import
      await txn.delete(
        'playlist_songs',
        where: 'playlist_id = ?',
        whereArgs: [importedPlaylist.id],
      );

      // 3. Save each song's denormalized data into the playlist_songs table
      for (final song in importedPlaylist.songs) {
        final playlistSong = PlaylistSong(
          playlistId: importedPlaylist.id, // This is the source_id
          songTitle: song.title,
          artist: song.artist,
          playUrl: song.playUrl,
        );
        await txn.insert(
          'playlist_songs',
          playlistSong.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
