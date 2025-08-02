import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/src/data/models/song.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.song});

  final Song song;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.song.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.song.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget.song.artist,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            _buildPlaybackControls(),
            const SizedBox(height: 32),
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
              icon: Icon(Icons.skip_previous),
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
              icon: Icon(Icons.skip_next),
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
