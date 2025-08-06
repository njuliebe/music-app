import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/src/data/models/song.dart';
import 'package:music_app/src/features/lyrics/data/lyric_repository.dart';
import 'package:music_app/src/features/lyrics/domain/lyric.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key, required this.song});

  final Song song;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _lyrics;
  bool _isLoadingLyrics = true;

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
      _audioPlayer.play();
    } catch (e) {
      // Handle error
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
          if (lyrics.isNotEmpty) {
            _lyrics =
                lyrics
                    .firstWhere(
                      (lyric) =>
                          lyric.name == widget.song.title &&
                          lyric.artistName == widget.song.artist,
                      orElse: () => Lyric.fromJson({}),
                    )
                    .syncedLyrics;
          } else {
            _lyrics = 'No lyrics found.';
          }
          _isLoadingLyrics = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lyrics = 'Failed to load lyrics.';
          _isLoadingLyrics = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.song.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              child: _isLoadingLyrics
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('歌词搜索中...'),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _lyrics ?? 'No lyrics available.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // Bottom: Player Controls
            _buildPlaybackControls(),
            const SizedBox(height: 16),
            _buildProgressBar(),
          ],
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
