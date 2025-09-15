import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/core/services/playback_service.dart';
import 'package:music_app/src/features/player/presentation/providers/playback_provider.dart';
import 'package:music_app/src/features/player/presentation/player_page.dart';

class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the provider to get the PlaybackService instance
    final playbackService = ref.watch(playbackServiceProvider);

    return StreamBuilder<PlayerState>(
      stream: playbackService.playerStateStream,
      builder: (context, snapshot) {
        // If there's no data or no song, show nothing
        if (!snapshot.hasData || snapshot.data!.currentSong == null) {
          return const SizedBox.shrink();
        }

        final state = snapshot.data!;
        final song = state.currentSong!;

        final isSingleSong = state.playlistSize <= 1;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PlayerPage()),
            );
          },
          child: Container(
            height: 60,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                // 歌曲信息
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.songTitle,
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 播放控制按钮组
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 上一首按钮
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous,
                        size: 28.0,
                        color: isSingleSong
                            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                            : null,
                      ),
                      onPressed: isSingleSong ? null : playbackService.playPrevious,
                    ),
                    // 播放/暂停按钮
                    IconButton(
                      icon: Icon(
                        state.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 36.0,
                      ),
                      onPressed: () {
                        if (state.isPlaying) {
                          playbackService.pause();
                        } else {
                          playbackService.play();
                        }
                      },
                    ),
                    // 下一首按钮
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        size: 28.0,
                        color: isSingleSong
                            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                            : null,
                      ),
                      onPressed: isSingleSong ? null : playbackService.playNext,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
