import 'dart:async';
import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/src/data/models/playlist_song.dart';
import 'package:music_app/src/data/models/song.dart';
import 'package:music_app/src/data/repositories/music_repository.dart';
import 'package:music_app/src/features/lyrics/data/lyric_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'playback_service.freezed.dart';

// A data model for a single line of LRC lyrics.
class LyricLine {
  final Duration timestamp;
  final String text;

  LyricLine(this.timestamp, this.text);
}

@freezed
class PlayerState with _$PlayerState {
  const factory PlayerState({
    @Default(false) bool isPlaying,
    PlaylistSong? currentSong,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(false) bool isLoadingLyrics,
    @Default([]) List<LyricLine> lyrics,
    @Default(-1) int currentLyricIndex,
  }) = _PlayerState;
}

class PlaybackService {
  final MusicRepository _musicRepository;
  final LyricRepository _lyricRepository;
  final AudioPlayer _audioPlayer;

  PlaybackService(this._musicRepository, this._lyricRepository)
      : _audioPlayer = AudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });

    _audioPlayer.positionStream.listen(_updateCurrentLyricIndex);
  }

  List<PlaylistSong> _playlist = [];
  int? _currentIndex;

  final BehaviorSubject<PlaylistSong?> _currentSongStream =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<bool> _isLoadingLyricsStream =
      BehaviorSubject.seeded(false);
  final BehaviorSubject<List<LyricLine>> _lyricsStream = BehaviorSubject.seeded([]);
  final BehaviorSubject<int> _currentLyricIndexStream = BehaviorSubject.seeded(-1);

  Stream<PlayerState> get playerStateStream {
    return Rx.combineLatest7(
      _audioPlayer.playerStateStream,
      _audioPlayer.positionStream,
      _audioPlayer.durationStream,
      _currentSongStream,
      _isLoadingLyricsStream,
      _lyricsStream,
      _currentLyricIndexStream,
      (playerState, position, duration, currentSong, isLoading, lyrics,
              lyricIndex) =>
          PlayerState(
        isPlaying: playerState.playing,
        currentSong: currentSong,
        position: position,
        duration: duration ?? Duration.zero,
        isLoadingLyrics: isLoading,
        lyrics: lyrics,
        currentLyricIndex: lyricIndex,
      ),
    );
  }

  PlaylistSong? get currentSong => _currentSongStream.value;

  Future<void> start(List<PlaylistSong> playlist, {int? startIndex}) async {
    _playlist = List.from(playlist);
    if (_playlist.isEmpty) {
      _currentIndex = null;
      _currentSongStream.add(null);
      await _audioPlayer.stop();
      return;
    }

    _currentIndex = startIndex ?? Random().nextInt(_playlist.length);
    await _playCurrent();
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    if (_playlist.length == 1) {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
      return;
    }

    if (_currentIndex != null) {
      _currentIndex = (_currentIndex! + 1) % _playlist.length;
      await _playCurrent();
    }
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    if (_playlist.length == 1) {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
      return;
    }
    if (_currentIndex != null) {
      _currentIndex = (_currentIndex! - 1 + _playlist.length) % _playlist.length;
      await _playCurrent();
    }
  }

  Future<void> _playCurrent() async {
    if (_currentIndex != null) {
      final song = _playlist[_currentIndex!];
      _currentSongStream.add(song);
      _resetLyricState();

      try {
        await _audioPlayer.stop();
        final detailedSong = await getDetailedSong(song);
        _searchLyrics(detailedSong.title);

        if (detailedSong.playUrl != null && detailedSong.playUrl!.isNotEmpty) {
          await _audioPlayer.setUrl(detailedSong.playUrl!);
          play();
        } else {
          playNext();
        }
      } catch (e) {
        playNext();
      }
    }
  }

  void _resetLyricState() {
    _isLoadingLyricsStream.add(true);
    _lyricsStream.add([]);
    _currentLyricIndexStream.add(-1);
  }

  Future<void> _searchLyrics(String title) async {
    try {
      final lyrics = await _lyricRepository.searchLyrics(title);
      if (lyrics.isNotEmpty && lyrics.first.syncedLyrics != null) {
        final parsed = _parseLyrics(lyrics.first.syncedLyrics!);
        _lyricsStream.add(parsed);
      }
    } catch (e) {
      // Fail silently
    } finally {
      _isLoadingLyricsStream.add(false);
    }
  }

  List<LyricLine> _parseLyrics(String lrcContent) {
    final lines = <LyricLine>[];
    final regex = RegExp(r'\\[(\\d{2}):(\\d{2})\\.(\\d{2,3})\\](.*)');
    for (final line in lrcContent.split('\n')) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final min = int.parse(match.group(1)!);
        final sec = int.parse(match.group(2)!);
        final ms = int.parse(match.group(3)!);
        final text = match.group(4) ?? '';
        lines.add(LyricLine(
            Duration(minutes: min, seconds: sec, milliseconds: ms), text));
      }
    }
    return lines;
  }

  void _updateCurrentLyricIndex(Duration position) {
    final lyrics = _lyricsStream.value;
    if (lyrics.isEmpty) return;

    int newIndex = -1;
    for (int i = lyrics.length - 1; i >= 0; i--) {
      if (position >= lyrics[i].timestamp) {
        newIndex = i;
        break;
      }
    }

    if (newIndex != _currentLyricIndexStream.value) {
      _currentLyricIndexStream.add(newIndex);
    }
  }

  Future<void> play() => _audioPlayer.play();
  Future<void> pause() => _audioPlayer.pause();
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  Future<Song> getDetailedSong(PlaylistSong playlistSong) async {
    final songs = await _musicRepository.searchSongs(playlistSong.songTitle);
    if (songs.isNotEmpty) {
      return await _musicRepository.getSongDetail(songs.first);
    } else {
      throw Exception('Song not found: ${playlistSong.songTitle}');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    _currentSongStream.close();
    _isLoadingLyricsStream.close();
    _lyricsStream.close();
    _currentLyricIndexStream.close();
  }
}
