import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/providers.dart';
import 'package:music_app/src/features/player/application/playback_service.dart';

import 'package:music_app/src/features/lyrics/data/lyric_repository.dart';

final playbackServiceProvider = Provider<PlaybackService>((ref) {
  final musicRepository = ref.watch(musicRepositoryProvider);
  final lyricRepository = ref.watch(lyricRepositoryProvider);
  final service = PlaybackService(musicRepository, lyricRepository);

  // Dispose the service when the provider is no longer used
  ref.onDispose(() => service.dispose());

  return service;
});
