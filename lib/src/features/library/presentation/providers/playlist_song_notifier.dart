import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/models/playlist_song.dart';
import 'package:music_app/src/data/repositories/playlist_repository.dart';
import 'package:music_app/src/features/library/presentation/providers/playlist_notifier.dart'; // Reusing PaginationState
import 'package:music_app/main.dart'; // For playlistRepositoryProvider

// 1. The StateNotifier for Playlist Songs
class PlaylistSongsNotifier extends StateNotifier<PaginationState<PlaylistSong>> {
  final PlaylistRepository _repository;
  final String _playlistId;

  PlaylistSongsNotifier(this._repository, this._playlistId)
      : super(PaginationState<PlaylistSong>()) {
    fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final newItems = await _repository.getSongsForPlaylist(_playlistId, page: state.page);

    state = state.copyWith(
      items: [...state.items, ...newItems],
      page: state.page + 1,
      hasMore: newItems.length == PlaylistRepository.pageSize,
      isLoading: false,
    );
  }

  Future<void> refresh() async {
    state = PaginationState<PlaylistSong>();
    await fetchNextPage();
  }
}

// 2. The Provider
final playlistSongsNotifierProvider = StateNotifierProvider.autoDispose
    .family<PlaylistSongsNotifier, PaginationState<PlaylistSong>, String>(
        (ref, playlistId) {
  return PlaylistSongsNotifier(ref.watch(playlistRepositoryProvider), playlistId);
});
