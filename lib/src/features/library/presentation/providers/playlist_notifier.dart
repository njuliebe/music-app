import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/data/repositories/playlist_repository.dart';
import 'package:music_app/src/data/services/playlist_import_service.dart';
import 'package:music_app/main.dart'; // For playlistRepositoryProvider
import 'package:dio/dio.dart';

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
  final PlaylistImportService _importService;

  PlaylistsNotifier(this._repository, this._importService) : super(PaginationState<Playlist>()) {
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

  Future<void> deletePlaylist(String playlistId) async {
    // Delete from database
    await _repository.deletePlaylist(playlistId);

    // Remove from state
    state = state.copyWith(
      items: state.items.where((p) => p.sourceId != playlistId).toList(),
    );
  }

  Future<String> refreshPlaylist(String playlistId) async {
    // Get playlist info
    final playlist = await _repository.getPlaylistById(playlistId);
    if (playlist == null || playlist.originalUrl == null) {
      throw Exception('Playlist not found or missing original URL');
    }

    try {
      // Re-import playlist
      final importedPlaylist = await _importService.importPlaylist(playlist.originalUrl!);
      if (importedPlaylist == null) {
        throw Exception('Failed to import playlist');
      }

      // Update playlist in database
      final updated = await _repository.updatePlaylist(importedPlaylist);

      if (updated) {
        // Refresh the list to show updated data
        await refresh();
        return '歌单已更新，歌曲数量发生变化';
      } else {
        return '歌单歌曲数量未变化，无需更新';
      }
    } catch (e) {
      throw Exception('刷新歌单失败: $e');
    }
  }
}

// 3. The Provider
final playlistsNotifierProvider =
    StateNotifierProvider<PlaylistsNotifier, PaginationState<Playlist>>((ref) {
  final dio = Dio();
  final importService = PlaylistImportService(dio);
  return PlaylistsNotifier(ref.watch(playlistRepositoryProvider), importService);
});
