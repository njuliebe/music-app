import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/features/player/application/playback_service.dart';
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

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PlayerPage()),
            );
          },
          child: Container(
            height: 60,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
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
                IconButton(
                  icon: Icon(
                    state.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 32.0,
                  ),
                  onPressed: () {
                    if (state.isPlaying) {
                      playbackService.pause();
                    } else {
                      playbackService.play();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
