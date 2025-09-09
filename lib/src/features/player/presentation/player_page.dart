import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/features/player/application/playback_service.dart';
import 'package:music_app/src/features/player/presentation/providers/playback_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key});

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  final ItemScrollController _scrollController = ItemScrollController();

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
            body: const Center(child: Text("No song is currently playing.")),
          );
        }

        final state = snapshot.data!;
        final song = state.currentSong!;

        // Scroll to the current lyric line
        if (_scrollController.isAttached && state.currentLyricIndex != -1) {
          _scrollController.scrollTo(
            index: state.currentLyricIndex,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            alignment: 0.4,
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.expand_more),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text("Now Playing"),
            centerTitle: true,
            backgroundColor: Colors.transparent,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Top section: Title and Artist
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Text(
                  song.songTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  song.artist,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),

                // Middle: Lyrics View
                Expanded(
                  child: _buildLyricsView(state),
                ),
                const SizedBox(height: 24),

                // Bottom: Player Controls
                _buildProgressBar(context, state, playbackService),
                _buildPlaybackControls(context, state, playbackService),
                const SizedBox(height: 32),
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
      return const Center(
        child: Text('No synced lyrics available.'),
      );
    }

    return ScrollablePositionedList.builder(
      itemCount: state.lyrics.length,
      itemScrollController: _scrollController,
      itemBuilder: (context, index) {
        final line = state.lyrics[index];
        final isCurrent = index == state.currentLyricIndex;

        final style = isCurrent
            ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                )
            : Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  height: 1.5,
                );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            line.text,
            style: style,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildPlaybackControls(
      BuildContext context, PlayerState state, PlaybackService service) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: 48.0,
          onPressed: service.playPrevious,
        ),
        const SizedBox(width: 24),
        IconButton(
          icon: Icon(state.isPlaying
              ? Icons.pause_circle_filled
              : Icons.play_circle_filled),
          iconSize: 72.0,
          onPressed: () {
            if (state.isPlaying) {
              service.pause();
            } else {
              service.play();
            }
          },
        ),
        const SizedBox(width: 24),
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: 48.0,
          onPressed: service.playNext,
        ),
      ],
    );
  }

  Widget _buildProgressBar(
      BuildContext context, PlayerState state, PlaybackService service) {
    return Column(
      children: [
        Slider(
          min: 0.0,
          max: state.duration.inMilliseconds.toDouble(),
          value: state.position.inMilliseconds
              .toDouble()
              .clamp(0.0, state.duration.inMilliseconds.toDouble()),
          onChanged: (value) {
            service.seek(Duration(milliseconds: value.round()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(state.position)),
              Text(_formatDuration(state.duration)),
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
}