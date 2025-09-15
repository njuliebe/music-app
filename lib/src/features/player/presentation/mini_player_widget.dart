import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/core/services/playback_service.dart';
import 'package:music_app/src/features/player/presentation/player_page.dart';
import 'package:music_app/src/features/player/presentation/providers/playback_provider.dart';
import 'package:music_app/src/shared/theme/app_theme.dart';

class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackService = ref.watch(playbackServiceProvider);

    return StreamBuilder<PlayerState>(
      stream: playbackService.playerStateStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.currentSong == null) {
          return const SizedBox.shrink();
        }

        final state = snapshot.data!;
        final song = state.currentSong!;
        final progress = state.duration.inMilliseconds > 0
            ? state.position.inMilliseconds / state.duration.inMilliseconds
            : 0.0;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const PlayerPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOutCubic;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryMedium.withValues(alpha: 0.95),
                  AppTheme.primaryDark.withValues(alpha: 0.95),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentPurple.withValues(alpha: 0.8),
                    ),
                    minHeight: 2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundElevated.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: AppTheme.textPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.songTitle,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.artist,
                              style: TextStyle(
                                color: AppTheme.textPrimary.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _buildPlayModeButton(context, ref, state.playMode),
                      const SizedBox(width: 4),
                      _buildControlButton(
                        icon: state.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        onPressed: () {
                          if (state.isPlaying) {
                            playbackService.pause();
                          } else {
                            playbackService.play();
                          }
                        },
                        size: 36,
                        iconSize: 24,
                      ),
                      const SizedBox(width: 4),
                      _buildControlButton(
                        icon: Icons.skip_next_rounded,
                        onPressed: () {
                          playbackService.playNext();
                        },
                        size: 36,
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayModeButton(BuildContext context, WidgetRef ref, PlayMode mode) {
    IconData icon;
    Color color;

    switch (mode) {
      case PlayMode.sequential:
        icon = Icons.repeat_rounded;
        color = AppTheme.textPrimary.withValues(alpha: 0.6);
        break;
      case PlayMode.random:
        icon = Icons.shuffle_rounded;
        color = AppTheme.accentPurple;
        break;
      case PlayMode.loop:
        icon = Icons.repeat_one_rounded;
        color = AppTheme.accentPurple;
        break;
    }

    return _buildControlButton(
      icon: icon,
      onPressed: () {
        final playbackService = ref.read(playbackServiceProvider);
        playbackService.togglePlayMode();
      },
      size: 36,
      iconSize: 20,
      color: color,
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 40,
    double iconSize = 24,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: color ?? AppTheme.textPrimary,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}