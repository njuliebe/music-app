import 'package:music_app/src/data/models/playlist_song.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/data/models/song.dart';
import 'package:sqflite/sqflite.dart';
import 'package:music_app/src/data/services/playlist_import_service.dart'; // Import ImportedPlaylist

class PlaylistRepository {
  final Database _db;

  PlaylistRepository({required Database db}) : _db = db;

  Future<List<Playlist>> getAllPlaylists() async {
    final List<Map<String, dynamic>> maps = await _db.query('playlists');
    return List.generate(maps.length, (i) {
      return Playlist.fromMap(maps[i]);
    });
  }

  // Updated to use String playlistId
  Future<List<PlaylistSong>> getSongsForPlaylist(String playlistId) async {
    final List<Map<String, dynamic>> maps = await _db.rawQuery('''
      SELECT s.* FROM songs s
      INNER JOIN playlist_songs ps ON s.id = ps.song_id
      WHERE ps.playlist_id = ?
    ''', [playlistId]);

    return List.generate(maps.length, (i) {
      final song = Song.fromJson(maps[i]);
      return PlaylistSong(
        playlistId: playlistId,
        song: song,
      );
    });
  }

  // Updated to use String playlistId
  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    await _db.insert(
      'songs',
      song.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _db.insert('playlist_songs', {
      'playlist_id': playlistId,
      'song_id': song.id,
    });
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await _db.delete(
      'playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
  }

  // New method to save imported playlist and its songs
  Future<void> saveImportedPlaylist(ImportedPlaylist importedPlaylist) async {
    await _db.transaction((txn) async {
      // 1. Save/Update the playlist itself
      final playlist = Playlist(
        id: importedPlaylist.id,
        name: importedPlaylist.name,
        type: PlaylistType.collected, // Assuming imported playlists are 'collected'
        description: null, // No description from API
        coverUrl: null, // No coverUrl from API
        creator: 'Imported', // Default creator
      );
      await txn.insert(
        'playlists',
        playlist.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Clear existing songs for this playlist from playlist_songs junction table
      await txn.delete(
        'playlist_songs',
        where: 'playlist_id = ?',
        whereArgs: [importedPlaylist.id],
      );

      // 3. Save each song and link to the playlist
      for (final song in importedPlaylist.songs) {
        await txn.insert(
          'songs',
          song.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await txn.insert(
          'playlist_songs',
          {
            'playlist_id': importedPlaylist.id,
            'song_id': song.id,
          },
          conflictAlgorithm: ConflictAlgorithm.replace, // In case of re-importing same song
        );
      }
    });
  }
}
