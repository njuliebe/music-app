import 'package:music_app/src/data/models/playlist_song.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/data/models/song.dart';
import 'package:sqflite/sqflite.dart';

class PlaylistRepository {
  final Database _db;

  PlaylistRepository({required Database db}) : _db = db;

  Future<List<Playlist>> getAllPlaylists() async {
    final List<Map<String, dynamic>> maps = await _db.query('playlists');
    return List.generate(maps.length, (i) {
      return Playlist.fromMap(maps[i]);
    });
  }

  // Fetches the list of songs for a given playlist.
  // In a real app, this would make a network or database request.
  Future<List<PlaylistSong>> getSongsForPlaylist(String playlistId) async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return a dummy list of songs for the given playlist
    // In a real implementation, you would fetch this data based on playlistId
    return [
      PlaylistSong(
        playlistId: playlistId,
        song: const Song(
          id: '1',
          title: 'Sample Song 1',
          artist: 'Artist 1',
          href: 'url1',
          playUrl: 'url1',
        ),
      ),
      PlaylistSong(
        playlistId: playlistId,
        song: const Song(
          id: '2',
          title: 'Sample Song 2',
          artist: 'Artist 2',
          href: 'url2',
          playUrl: 'url2',
        ),
      ),
      PlaylistSong(
        playlistId: playlistId,
        song: const Song(
          id: '3',
          title: 'Sample Song 3',
          artist: 'Artist 3',
          href: 'url3',
          playUrl: 'url3',
        ),
      ),
    ];
  }
}
