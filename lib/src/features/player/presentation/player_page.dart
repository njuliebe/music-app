import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/core/services/playback_service.dart';
import 'package:music_app/src/features/player/presentation/providers/playback_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key});

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  final ItemScrollController _scrollController = ItemScrollController();
  OverlayEntry? _toastOverlay;
  bool _showSourceAttribution = true;
  Timer? _attributionTimer;
  int _lastScrolledIndex = -1;
  String? _currentSongId;
  Timer? _scrollDebounceTimer;

  @override
  Widget build(BuildContext context) {
    final playbackService = ref.watch(playbackServiceProvider);

    return StreamBuilder<PlayerState>(
      stream: playbackService.playerStateStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.currentSong == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.expand_more),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Colors.transparent,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("音乐加载中"),
                ],
              ),
            ),
          );
        }

        final state = snapshot.data!;
        final song = state.currentSong!;

        // Check if song changed and reset scroll state
        final songId = '${song.songTitle}_${song.artist}';
        if (_currentSongId != songId) {
          _currentSongId = songId;
          _lastScrolledIndex = -1;
          _scrollDebounceTimer?.cancel();
        }

        // Start timer when playback starts
        if (state.isPlaying && _attributionTimer == null) {
          _attributionTimer = Timer(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                _showSourceAttribution = false;
              });
            }
          });
        }

        // Scroll to the current lyric line only when index actually changes
        if (_scrollController.isAttached &&
            state.currentLyricIndex != -1 &&
            state.currentLyricIndex != _lastScrolledIndex &&
            state.lyrics.isNotEmpty &&
            state.currentLyricIndex < state.lyrics.length) {

          // Cancel any pending scroll
          _scrollDebounceTimer?.cancel();

          // Debounce the scroll to prevent rapid updates
          _scrollDebounceTimer = Timer(const Duration(milliseconds: 100), () {
            if (_scrollController.isAttached &&
                mounted &&
                state.currentLyricIndex != _lastScrolledIndex) {
              _lastScrolledIndex = state.currentLyricIndex;
              _scrollController.scrollTo(
                index: state.currentLyricIndex,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                alignment: 0.4,
              );
            }
          });
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.expand_more),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text("正在播放"),
            centerTitle: true,
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      // Top section: Title and Artist
                      const SizedBox(height: 20),
                      Text(
                        song.songTitle,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(fontSize: 24),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        song.artist,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),

                      // Middle: Lyrics View
                      Expanded(child: _buildLyricsView(state)),
                      const SizedBox(height: 20),

                      // Bottom: Player Controls
                      _buildProgressBar(context, state, playbackService),
                      const SizedBox(height: 20),
                      _buildPlaybackControls(context, state, playbackService),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                // Source Attribution at bottom
                if (_showSourceAttribution)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      opacity: _showSourceAttribution ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Center(
                        child: Text(
                          '音乐来自GD音乐台(music.gdstudio.xyz)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLyricsView(PlayerState state) {
    if (state.isLoadingLyrics) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('歌词搜索中...'),
          ],
        ),
      );
    }

    if (state.lyrics.isEmpty) {
      return const Center(child: Text('暂无歌词'));
    }

    return ScrollablePositionedList.builder(
      itemCount: state.lyrics.length,
      itemScrollController: _scrollController,
      itemBuilder: (context, index) {
        final line = state.lyrics[index];
        final isCurrent = index == state.currentLyricIndex;

        final style =
            isCurrent
                ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                )
                : Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(line.text, style: style, textAlign: TextAlign.center),
        );
      },
    );
  }

  Widget _buildPlaybackControls(
    BuildContext context,
    PlayerState state,
    PlaybackService service,
  ) {
    final isSingleSong = state.playlistSize <= 1;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 播放模式按钮
          Flexible(
            child: IconButton(
              icon: Icon(
                _getPlayModeIcon(state.playMode),
                color: Theme.of(context).colorScheme.primary,
              ),
              iconSize: isSmallScreen ? 28.0 : 32.0,
              onPressed: () {
                service.togglePlayMode();
                _showPlayModeToast(context, service.playMode);
              },
            ),
          ),
          Flexible(
            child: IconButton(
              icon: Icon(
                Icons.skip_previous,
                color:
                    isSingleSong
                        ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.3)
                        : null,
              ),
              iconSize: isSmallScreen ? 40.0 : 48.0,
              onPressed: isSingleSong ? null : service.playPrevious,
            ),
          ),
          Flexible(
            child: IconButton(
              icon: Icon(
                state.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
              ),
              iconSize: isSmallScreen ? 60.0 : 72.0,
              onPressed: () {
                if (state.isPlaying) {
                  service.pause();
                } else {
                  service.play();
                }
              },
            ),
          ),
          Flexible(
            child: IconButton(
              icon: Icon(
                Icons.skip_next,
                color:
                    isSingleSong
                        ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.3)
                        : null,
              ),
              iconSize: isSmallScreen ? 40.0 : 48.0,
              onPressed: isSingleSong ? null : service.playNext,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    PlayerState state,
    PlaybackService service,
  ) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.3),
            thumbColor: Theme.of(context).colorScheme.primary,
            overlayColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 3,
          ),
          child: Slider(
            min: 0.0,
            max: state.duration.inMilliseconds.toDouble(),
            value: state.position.inMilliseconds.toDouble().clamp(
              0.0,
              state.duration.inMilliseconds.toDouble(),
            ),
            onChanged: (value) {
              service.seek(Duration(milliseconds: value.round()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(state.position),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _formatDuration(state.duration),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  IconData _getPlayModeIcon(PlayMode mode) {
    switch (mode) {
      case PlayMode.sequential:
        return Icons.repeat;
      case PlayMode.random:
        return Icons.shuffle;
      case PlayMode.loop:
        return Icons.repeat_one;
    }
  }

  String _getPlayModeText(PlayMode mode) {
    switch (mode) {
      case PlayMode.sequential:
        return '列表循环';
      case PlayMode.random:
        return '随机播放';
      case PlayMode.loop:
        return '单曲循环';
    }
  }

  void _showPlayModeToast(BuildContext context, PlayMode mode) {
    // 移除之前的 toast
    _toastOverlay?.remove();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _toastOverlay = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: size.width / 2 - 75,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _getPlayModeText(mode),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(_toastOverlay!);

    // 1秒后自动移除
    Future.delayed(const Duration(seconds: 1), () {
      _toastOverlay?.remove();
      _toastOverlay = null;
    });
  }

  @override
  void dispose() {
    _toastOverlay?.remove();
    _attributionTimer?.cancel();
    _scrollDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Reset attribution visibility when page opens
    _showSourceAttribution = true;
    _attributionTimer = null;
    _lastScrolledIndex = -1;
    _currentSongId = null;
  }
}
