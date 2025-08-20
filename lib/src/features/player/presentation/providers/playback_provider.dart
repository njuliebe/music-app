import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/providers.dart';
import 'package:music_app/src/features/player/application/playback_service.dart';

final playbackServiceProvider = Provider((ref) {
  final musicRepository = ref.watch(musicRepositoryProvider);
  return PlaybackService(musicRepository);
});
