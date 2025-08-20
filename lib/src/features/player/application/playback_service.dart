
import 'dart:math';

import 'package:music_app/src/data/models/playlist_song.dart';
import 'package:music_app/src/data/models/song.dart';
import 'package:music_app/src/data/repositories/music_repository.dart';

class PlaybackService {
  final MusicRepository _musicRepository;

  PlaybackService(this._musicRepository);

  List<PlaylistSong> _playlist = [];
  int? _currentIndex;
  int? _nextIndex;

  PlaylistSong? get currentSong =>
      _currentIndex != null ? _playlist[_currentIndex!] : null;
  PlaylistSong? get nextSong =>
      _nextIndex != null ? _playlist[_nextIndex!] : null;

  void start(List<PlaylistSong> playlist, {int? startIndex}) {
    _playlist = List.from(playlist);
    if (_playlist.isEmpty) {
      return;
    }

    _currentIndex = startIndex ?? Random().nextInt(_playlist.length);
    _prepareNext();
  }

  void playNext() {
    if (_nextIndex != null) {
      _currentIndex = _nextIndex;
      _prepareNext();
    }
  }

  void _prepareNext() {
    if (_playlist.length <= 1) {
      _nextIndex = null;
      return;
    }
    _nextIndex = Random().nextInt(_playlist.length);
  }

  Future<Song> getDetailedSong(PlaylistSong playlistSong) async {
    final songs = await _musicRepository.searchSongs(playlistSong.songTitle);
    if (songs.isNotEmpty) {
      return await _musicRepository.getSongDetail(songs.first);
    } else {
      throw Exception('Song not found: ${playlistSong.songTitle}');
    }
  }
}
