import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/src/data/models/song.dart';
import 'package:music_app/src/features/lyrics/data/lyric_repository.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// A data model for a single line of LRC lyrics.
class LyricLine {
  final Duration timestamp;
  final String text;

  LyricLine(this.timestamp, this.text);
}

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key, required this.song});

  final Song song;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoadingLyrics = true;
  List<LyricLine> _parsedLyrics = [];
  int _currentLyricIndex = -1;

  final ItemScrollController _scrollController = ItemScrollController();
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _searchLyrics();
  }

  Future<void> _initAudioPlayer() async {
    try {
      if (widget.song.playUrl == null || widget.song.playUrl!.isEmpty) {
        throw Exception('音频链接为空');
      }
      await _audioPlayer.setUrl(widget.song.playUrl!);
      _setupPositionListener();
      _audioPlayer.play();
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  Future<void> _searchLyrics() async {
    try {
      final lyrics = await ref
          .read(lyricRepositoryProvider)
          .searchLyrics(widget.song.title);
      if (mounted) {
        setState(() {
          if (lyrics.isNotEmpty && lyrics.first.syncedLyrics != null) {
            _parsedLyrics = _parseLyrics(lyrics.first.syncedLyrics!);
          } else {
            _parsedLyrics = [];
          }
          _isLoadingLyrics = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLyrics = false;
        });
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
        lines.add(LyricLine(
            Duration(minutes: min, seconds: sec, milliseconds: ms), text));
      }
    }
    return lines;
  }

  void _setupPositionListener() {
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (_parsedLyrics.isEmpty) return;

      int newIndex = -1;
      for (int i = _parsedLyrics.length - 1; i >= 0; i--) {
        if (position >= _parsedLyrics[i].timestamp) {
          newIndex = i;
          break;
        }
      }

      if (newIndex != _currentLyricIndex) {
        setState(() {
          _currentLyricIndex = newIndex;
        });
        if (_scrollController.isAttached && _currentLyricIndex != -1) {
          _scrollController.scrollTo(
            index: _currentLyricIndex,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            alignment: 0.5, // Scroll to the center
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.song.title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Top: Song Info
            Text(
              widget.song.title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.song.artist,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Middle: Lyrics
            Expanded(
              child: _buildLyricsView(),
            ),
            const SizedBox(height: 24),

            // Bottom: Player Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                children: [
                  _buildPlaybackControls(),
                  const SizedBox(height: 16),
                  _buildProgressBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLyricsView() {
    if (_isLoadingLyrics) {
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

    if (_parsedLyrics.isEmpty) {
      return const Center(
        child: Text('No synced lyrics available.'),
      );
    }

    // Center the lyrics view and constrain its width for better aesthetics.
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.8, // Use 80% of the available width.
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Adjust padding calculation for the new font sizes.
            final padding = constraints.maxHeight / 2 - 24;

            return ScrollablePositionedList.builder(
              itemCount: _parsedLyrics.length,
              itemScrollController: _scrollController,
              padding: EdgeInsets.symmetric(vertical: padding > 0 ? padding : 0),
              itemBuilder: (context, index) {
                final line = _parsedLyrics[index];
                final isCurrent = index == _currentLyricIndex;

                // Use smaller, more subtle fonts for a cleaner look.
                final style = isCurrent
                    ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          height: 1.6,
                        )
                    : Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          height: 1.5,
                        );

                return Padding(
                  // Adjust vertical padding to match the smaller font size.
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    line.text,
                    style: style,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return const CircularProgressIndicator();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              iconSize: 48.0,
              onPressed: () {
                // TODO: Implement previous song logic
              },
            ),
            IconButton(
              icon: Icon(playing == true ? Icons.pause : Icons.play_arrow),
              iconSize: 64.0,
              onPressed: () {
                if (playing == true) {
                  _audioPlayer.pause();
                } else {
                  _audioPlayer.play();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              iconSize: 48.0,
              onPressed: () {
                // TODO: Implement next song logic
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return StreamBuilder<Duration?>(
      stream: _audioPlayer.durationStream,
      builder: (context, snapshot) {
        final duration = snapshot.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: _audioPlayer.positionStream,
          builder: (context, snapshot) {
            var position = snapshot.data ?? Duration.zero;
            if (position > duration) {
              position = duration;
            }
            return Slider(
              min: 0.0,
              max: duration.inMilliseconds.toDouble(),
              value: position.inMilliseconds.toDouble(),
              onChanged: (value) {
                _audioPlayer.seek(Duration(milliseconds: value.round()));
              },
            );
          },
        );
      },
    );
  }
}
