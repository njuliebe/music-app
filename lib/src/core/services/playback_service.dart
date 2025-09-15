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

// 播放模式
enum PlayMode {
  sequential, // 顺序播放
  random,     // 随机播放
  loop,       // 单曲循环
}

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
    @Default(0) int playlistSize,
    @Default(PlayMode.random) PlayMode playMode,
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
  int? _predeterminedNextIndex; // 预先确定的下一首索引（随机模式）

  // 缓存机制
  final Map<String, Song> _songCache = {};
  final Map<String, List<LyricLine>> _lyricsCache = {};
  static const int _maxCacheSize = 10; // 最大缓存歌曲数

  // 播放历史管理
  final List<PlaylistSong> _playHistory = [];
  int _historyIndex = -1;
  static const int _maxHistorySize = 100;

  // 用于避免随机播放重复
  final Set<int> _recentlyPlayedIndices = {};
  static const int _recentBufferSize = 3; // 避免最近3首内重复

  // 播放模式
  PlayMode _playMode = PlayMode.random;
  final BehaviorSubject<PlayMode> _playModeStream = BehaviorSubject.seeded(PlayMode.random);

  final BehaviorSubject<PlaylistSong?> _currentSongStream =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<bool> _isLoadingLyricsStream = BehaviorSubject.seeded(
    false,
  );
  final BehaviorSubject<List<LyricLine>> _lyricsStream = BehaviorSubject.seeded(
    [],
  );
  final BehaviorSubject<int> _currentLyricIndexStream = BehaviorSubject.seeded(
    -1,
  );

  final BehaviorSubject<int> _playlistSizeStream = BehaviorSubject.seeded(0);

  Stream<PlayerState> get playerStateStream {
    return Rx.combineLatest9(
      _audioPlayer.playerStateStream,
      _audioPlayer.positionStream,
      _audioPlayer.durationStream,
      _currentSongStream,
      _isLoadingLyricsStream,
      _lyricsStream,
      _currentLyricIndexStream,
      _playlistSizeStream,
      _playModeStream,
      (
        playerState,
        position,
        duration,
        currentSong,
        isLoading,
        lyrics,
        lyricIndex,
        playlistSize,
        playMode,
      ) => PlayerState(
        isPlaying: playerState.playing,
        currentSong: currentSong,
        position: position,
        duration: duration ?? Duration.zero,
        isLoadingLyrics: isLoading,
        lyrics: lyrics,
        currentLyricIndex: lyricIndex,
        playlistSize: playlistSize,
        playMode: playMode,
      ),
    );
  }

  PlaylistSong? get currentSong => _currentSongStream.value;

  Future<void> start(List<PlaylistSong> playlist, {int? startIndex}) async {
    _playlist = List.from(playlist);
    _playlistSizeStream.add(_playlist.length);
    if (_playlist.isEmpty) {
      _currentIndex = null;
      _currentSongStream.add(null);
      await _audioPlayer.stop();
      return;
    }

    _currentIndex = startIndex ?? Random().nextInt(_playlist.length);

    // 清空历史并重置
    _playHistory.clear();
    _historyIndex = -1;
    _recentlyPlayedIndices.clear();
    _predeterminedNextIndex = null;

    // 清空缓存
    _songCache.clear();
    _lyricsCache.clear();

    await _playCurrent();
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;

    // 单曲循环模式
    if (_playMode == PlayMode.loop || _playlist.length == 1) {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
      return;
    }

    if (_currentIndex != null) {
      // 添加当前歌曲到播放历史
      _addToHistory(_playlist[_currentIndex!]);

      // 根据播放模式选择下一首
      if (_playMode == PlayMode.random) {
        // 使用预先确定的下一首索引
        if (_predeterminedNextIndex != null) {
          _currentIndex = _predeterminedNextIndex;
          _predeterminedNextIndex = null; // 清空预设
        } else {
          // 如果没有预确定的索引（不应该发生），生成一个
          _currentIndex = _getRandomIndex();
        }
      } else {
        // 顺序播放
        _currentIndex = (_currentIndex! + 1) % _playlist.length;
      }

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

    // 优先从播放历史中获取上一首
    if (_historyIndex > 0 && _historyIndex <= _playHistory.length) {
      _historyIndex--;
      final historySong = _playHistory[_historyIndex];

      // 在播放列表中找到对应歌曲的索引
      final index = _playlist.indexWhere((song) =>
        song.songTitle == historySong.songTitle &&
        song.artist == historySong.artist
      );

      if (index != -1) {
        _currentIndex = index;
        await _playCurrent(isFromHistory: true);
        return;
      }
    }

    // 如果没有历史或历史已到头，则播放列表的上一首
    if (_currentIndex != null) {
      _currentIndex = (_currentIndex! - 1 + _playlist.length) % _playlist.length;
      await _playCurrent();
    }
  }

  Future<void> _playCurrent({bool isFromHistory = false}) async {
    if (_currentIndex != null) {
      final song = _playlist[_currentIndex!];
      _currentSongStream.add(song);
      _resetLyricState();

      // 更新最近播放索引集合
      _updateRecentlyPlayed(_currentIndex!);

      // 如果不是从历史导航，则添加到历史
      if (!isFromHistory) {
        _addToHistory(song);
      }

      try {
        await _audioPlayer.stop();
        final detailedSong = await _getCachedSongDetail(song);
        await _loadCachedLyrics(detailedSong.title);

        if (detailedSong.playUrl != null && detailedSong.playUrl!.isNotEmpty) {
          await _audioPlayer.setUrl(detailedSong.playUrl!);
          play();

          // 预加载下一首和上一首
          _preloadNextAndPrevious();
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


  Future<void> _loadCachedLyrics(String title) async {
    final cacheKey = _getLyricsCacheKey(title);

    // 检查缓存
    if (_lyricsCache.containsKey(cacheKey)) {
      _lyricsStream.add(_lyricsCache[cacheKey]!);
      _isLoadingLyricsStream.add(false);
    } else {
      // 异步加载歌词
      _isLoadingLyricsStream.add(true);
      try {
        final lyrics = await _lyricRepository.searchLyrics(title);
        List<LyricLine> parsedLyrics = [];

        if (lyrics.isNotEmpty && lyrics.first.syncedLyrics != null) {
          parsedLyrics = _parseLyrics(lyrics.first.syncedLyrics!);
        }

        // 缓存歌词
        _lyricsCache[cacheKey] = parsedLyrics;
        _manageLyricsCache();

        // 更新歌词流
        _lyricsStream.add(parsedLyrics);
      } catch (e) {
        _lyricsStream.add([]);
      } finally {
        _isLoadingLyricsStream.add(false);
      }
    }
  }

  List<LyricLine> _parseLyrics(String lrcContent) {
    final lines = <LyricLine>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');
    for (final line in lrcContent.split('\n')) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final min = int.parse(match.group(1)!);
        final sec = int.parse(match.group(2)!);
        final ms = int.parse(match.group(3)!);
        final text = match.group(4) ?? '';
        lines.add(
          LyricLine(
            Duration(minutes: min, seconds: sec, milliseconds: ms * 10),
            text,
          ),
        );
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

  Future<Song> _getCachedSongDetail(PlaylistSong playlistSong) async {
    final cacheKey = _getSongCacheKey(playlistSong);

    // 检查缓存
    if (_songCache.containsKey(cacheKey)) {
      return _songCache[cacheKey]!;
    }

    // 未缓存，获取并缓存
    final song = await getDetailedSong(playlistSong);
    _songCache[cacheKey] = song;
    _manageSongCache();

    return song;
  }

  Future<void> _preloadSong(PlaylistSong playlistSong) async {
    final cacheKey = _getSongCacheKey(playlistSong);

    // 如果已缓存，跳过
    if (_songCache.containsKey(cacheKey)) {
      return;
    }

    try {
      final song = await getDetailedSong(playlistSong);
      _songCache[cacheKey] = song;
      _manageSongCache();

      // 同时预加载歌词
      _preloadLyrics(song.title);
    } catch (e) {
      // 预加载失败，静默处理
    }
  }

  Future<void> _preloadLyrics(String title) async {
    final cacheKey = _getLyricsCacheKey(title);

    // 如果已缓存，跳过
    if (_lyricsCache.containsKey(cacheKey)) {
      return;
    }

    try {
      final lyrics = await _lyricRepository.searchLyrics(title);
      List<LyricLine> parsedLyrics = [];

      if (lyrics.isNotEmpty && lyrics.first.syncedLyrics != null) {
        parsedLyrics = _parseLyrics(lyrics.first.syncedLyrics!);
      }

      _lyricsCache[cacheKey] = parsedLyrics;
      _manageLyricsCache();
    } catch (e) {
      // 预加载失败，静默处理
    }
  }

  void _preloadNextAndPrevious() {
    if (_playlist.isEmpty || _currentIndex == null) return;

    // 预加载下一首
    if (_playMode == PlayMode.loop) {
      // 单曲循环不需要预加载
      return;
    } else if (_playMode == PlayMode.random) {
      // 随机模式，提前确定下一首
      _predeterminedNextIndex = _getRandomIndex();
      if (_predeterminedNextIndex != null) {
        _preloadSong(_playlist[_predeterminedNextIndex!]);
      }
    } else {
      // 顺序播放
      final nextIndex = (_currentIndex! + 1) % _playlist.length;
      _preloadSong(_playlist[nextIndex]);
    }

    // 预加载上一首
    if (_historyIndex > 0 && _historyIndex <= _playHistory.length) {
      final historySong = _playHistory[_historyIndex - 1];
      _preloadSong(historySong);
    } else if (_currentIndex != null) {
      final prevIndex = (_currentIndex! - 1 + _playlist.length) % _playlist.length;
      _preloadSong(_playlist[prevIndex]);
    }
  }

  String _getSongCacheKey(PlaylistSong song) {
    return '${song.songTitle}_${song.artist}'.replaceAll(' ', '_');
  }

  String _getLyricsCacheKey(String title) {
    return title.replaceAll(' ', '_');
  }

  void _manageSongCache() {
    // 限制缓存大小
    if (_songCache.length > _maxCacheSize) {
      // 简单的FIFO策略，移除最早的
      final keysToRemove = _songCache.keys.take(_songCache.length - _maxCacheSize).toList();
      for (final key in keysToRemove) {
        _songCache.remove(key);
      }
    }
  }

  void _manageLyricsCache() {
    // 限制缓存大小
    if (_lyricsCache.length > _maxCacheSize) {
      final keysToRemove = _lyricsCache.keys.take(_lyricsCache.length - _maxCacheSize).toList();
      for (final key in keysToRemove) {
        _lyricsCache.remove(key);
      }
    }
  }

  void _addToHistory(PlaylistSong song) {
    // 如果正在历史中导航，清除当前位置之后的历史
    if (_historyIndex >= 0 && _historyIndex < _playHistory.length - 1) {
      _playHistory.removeRange(_historyIndex + 1, _playHistory.length);
    }

    // 添加新歌曲到历史
    _playHistory.add(song);

    // 限制历史大小
    if (_playHistory.length > _maxHistorySize) {
      _playHistory.removeAt(0);
    }

    // 更新历史索引
    _historyIndex = _playHistory.length - 1;
  }

  int _getRandomIndex() {
    if (_playlist.length <= _recentBufferSize) {
      // 如果歌单很小，直接随机
      return Random().nextInt(_playlist.length);
    }

    // 创建可选索引列表（排除最近播放的）
    final availableIndices = <int>[];
    for (int i = 0; i < _playlist.length; i++) {
      if (!_recentlyPlayedIndices.contains(i)) {
        availableIndices.add(i);
      }
    }

    // 如果所有歌曲都最近播放过，清空限制
    if (availableIndices.isEmpty) {
      _recentlyPlayedIndices.clear();
      for (int i = 0; i < _playlist.length; i++) {
        if (i != _currentIndex) {
          availableIndices.add(i);
        }
      }
    }

    // 随机选择
    return availableIndices[Random().nextInt(availableIndices.length)];
  }

  void _updateRecentlyPlayed(int index) {
    _recentlyPlayedIndices.add(index);

    // 保持集合大小
    if (_recentlyPlayedIndices.length > _recentBufferSize) {
      // 移除最早的（这里简化处理，实际可能需要队列）
      if (_recentlyPlayedIndices.length > _recentBufferSize) {
        final toRemove = _recentlyPlayedIndices.length - _recentBufferSize;
        final sorted = _recentlyPlayedIndices.toList();
        for (int i = 0; i < toRemove; i++) {
          _recentlyPlayedIndices.remove(sorted[i]);
        }
      }
    }
  }

  // 切换播放模式
  void togglePlayMode() {
    switch (_playMode) {
      case PlayMode.sequential:
        _playMode = PlayMode.random;
        break;
      case PlayMode.random:
        _playMode = PlayMode.loop;
        break;
      case PlayMode.loop:
        _playMode = PlayMode.sequential;
        break;
    }
    _playModeStream.add(_playMode);

    // 播放模式切换时，重新预加载
    if (_playMode == PlayMode.random) {
      _predeterminedNextIndex = _getRandomIndex();
      if (_predeterminedNextIndex != null) {
        _preloadSong(_playlist[_predeterminedNextIndex!]);
      }
    } else {
      _predeterminedNextIndex = null;
      // 预加载顺序播放的下一首
      if (_playMode == PlayMode.sequential && _currentIndex != null) {
        final nextIndex = (_currentIndex! + 1) % _playlist.length;
        _preloadSong(_playlist[nextIndex]);
      }
    }
  }

  // 设置播放模式
  void setPlayMode(PlayMode mode) {
    _playMode = mode;
    _playModeStream.add(_playMode);

    // 播放模式切换时，重新预加载
    if (_playMode == PlayMode.random) {
      _predeterminedNextIndex = _getRandomIndex();
      if (_predeterminedNextIndex != null) {
        _preloadSong(_playlist[_predeterminedNextIndex!]);
      }
    } else {
      _predeterminedNextIndex = null;
      // 预加载顺序播放的下一首
      if (_playMode == PlayMode.sequential && _currentIndex != null) {
        final nextIndex = (_currentIndex! + 1) % _playlist.length;
        _preloadSong(_playlist[nextIndex]);
      }
    }
  }

  PlayMode get playMode => _playMode;

  void dispose() {
    _audioPlayer.dispose();
    _currentSongStream.close();
    _isLoadingLyricsStream.close();
    _lyricsStream.close();
    _currentLyricIndexStream.close();
    _playlistSizeStream.close();
    _playModeStream.close();
    _songCache.clear();
    _lyricsCache.clear();
  }
}
