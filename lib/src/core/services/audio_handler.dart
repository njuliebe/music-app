import 'package:audio_service/audio_service.dart';
import 'package:music_app/src/core/services/playback_service.dart' as ps;
import 'package:music_app/src/data/models/playlist_song.dart';

/// 音频处理器，用于处理系统媒体控制
class MusicAudioHandler extends BaseAudioHandler {
  final ps.PlaybackService playbackService;

  MusicAudioHandler(this.playbackService) {
    // 监听播放服务的状态变化
    playbackService.playerStateStream.listen((playerState) {
      _updateMediaItem(playerState.currentSong);
      _updatePlaybackState(playerState);
    });
  }

  /// 更新当前播放的媒体项
  void _updateMediaItem(PlaylistSong? song) {
    if (song == null) {
      mediaItem.add(null);
      return;
    }

    final item = MediaItem(
      id: song.songTitle,
      title: song.songTitle,
      artist: song.artist,
      album: '',  // PlaylistSong doesn't have album field
      duration: const Duration(minutes: 4), // 默认时长，实际时长从播放器获取
    );

    mediaItem.add(item);
  }

  /// 更新播放状态
  void _updatePlaybackState(ps.PlayerState playerState) {
    final playing = playerState.isPlaying;
    final processingState = playing
        ? AudioProcessingState.ready
        : AudioProcessingState.buffering;

    final controls = [
      MediaControl.skipToPrevious,
      if (playing) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
    ];

    playbackState.add(PlaybackState(
      controls: controls,
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.skipToPrevious,
        MediaAction.skipToNext,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: processingState,
      playing: playing,
      updatePosition: playerState.position,
      bufferedPosition: playerState.duration,
      speed: 1.0,
      queueIndex: playbackService.currentIndex,
    ));
  }

  @override
  Future<void> play() async {
    await playbackService.play();
  }

  @override
  Future<void> pause() async {
    await playbackService.pause();
  }

  @override
  Future<void> skipToNext() async {
    await playbackService.playNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await playbackService.playPrevious();
  }

  @override
  Future<void> seek(Duration position) async {
    await playbackService.seek(position);
  }

  @override
  Future<void> stop() async {
    await playbackService.pause();
    await super.stop();
  }

  /// 处理自定义媒体按钮事件
  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'togglePlayMode':
        playbackService.togglePlayMode();
        break;
    }
  }

  // 媒体按钮事件会通过 play(), pause(), skipToNext(), skipToPrevious() 自动处理
  // 不需要手动实现 onMediaButtonEvent
}