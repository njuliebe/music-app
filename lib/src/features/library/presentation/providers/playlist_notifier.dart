import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/data/repositories/playlist_repository.dart';
import 'package:music_app/main.dart'; // For playlistRepositoryProvider

// 1. Generic State for Pagination
class PaginationState<T> {
  final List<T> items;
  final int page;
  final bool hasMore;
  final bool isLoading;

  PaginationState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 2. The StateNotifier for Playlists
class PlaylistsNotifier extends StateNotifier<PaginationState<Playlist>> {
  final PlaylistRepository _repository;

  PlaylistsNotifier(this._repository) : super(PaginationState<Playlist>()) {
    fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final newItems = await _repository.getPlaylists(page: state.page);

    state = state.copyWith(
      items: [...state.items, ...newItems],
      page: state.page + 1,
      hasMore: newItems.length == PlaylistRepository.pageSize,
      isLoading: false,
    );
  }

  Future<void> refresh() async {
    state = PaginationState<Playlist>();
    await fetchNextPage();
  }
}

// 3. The Provider
final playlistsNotifierProvider =
    StateNotifierProvider<PlaylistsNotifier, PaginationState<Playlist>>((ref) {
  return PlaylistsNotifier(ref.watch(playlistRepositoryProvider));
});
