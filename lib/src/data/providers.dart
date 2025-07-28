import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/repositories/music_repository.dart';

/// A provider that creates and exposes an instance of [MusicRepository].
///
/// By default, it provides the [MockMusicRepository] for development and testing.
/// When the real API service is ready, we can easily swap this out.
final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  // For now, we use the mock implementation.
  return MockMusicRepository();

  // TODO: When ApiService is implemented, switch to the real repository:
  // final dio = ref.watch(dioProvider); // Assuming a dioProvider is defined elsewhere
  // return ApiMusicRepository(apiService: ApiService(dio));
});
