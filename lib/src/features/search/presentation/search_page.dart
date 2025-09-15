import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/main.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/data/models/playlist_song.dart';
import 'package:music_app/src/data/models/song.dart';
import 'package:music_app/src/data/providers.dart';
import 'package:music_app/src/features/library/presentation/providers/playlist_notifier.dart';
import 'package:music_app/src/features/library/presentation/providers/playlist_song_notifier.dart';
import 'package:music_app/src/features/player/presentation/player_page.dart';
import 'package:music_app/src/features/player/presentation/providers/playback_provider.dart';
import 'package:music_app/src/shared/theme/app_theme.dart';

final searchResultsProvider = FutureProvider.autoDispose
    .family<List<Song>, String>((ref, query) async {
      if (query.isEmpty) {
        return [];
      }
      final musicRepository = ref.watch(musicRepositoryProvider);
      return musicRepository.searchSongs(query);
    });

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      FocusScope.of(context).unfocus();
      setState(() {
        _searchQuery = query;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '搜索',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: '搜索歌曲、歌手或专辑',
            hintStyle: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 15,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppTheme.textHint,
              size: 22,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: AppTheme.textHint,
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _performSearch(),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState();
    }

    final searchResults = ref.watch(searchResultsProvider(_searchQuery));

    return searchResults.when(
      data: (songs) {
        if (songs.isEmpty) {
          return _buildNoResultsState();
        }
        return _buildSongsList(songs);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 80,
            color: AppTheme.textHint.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '搜索你喜欢的音乐',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: AppTheme.textHint.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '未找到相关结果',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试其他关键词',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.accentPurple,
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppTheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              '搜索出错了',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                ref.invalidate(searchResultsProvider(_searchQuery));
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsList(List<Song> songs) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return _buildSongTile(song, songs, index);
      },
    );
  }

  Widget _buildSongTile(Song song, List<Song> allSongs, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final playbackService = ref.read(playbackServiceProvider);
            final playlistSongs = allSongs.map((s) => PlaylistSong(
              playlistId: "search_results",
              songTitle: s.title,
              artist: s.artist,
              playUrl: s.playUrl,
            )).toList();

            await playbackService.start(playlistSongs, startIndex: index);

            if (mounted) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PlayerPage(),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.accentPurple.withValues(alpha: 0.3),
                        AppTheme.accentBlue.withValues(alpha: 0.3),
                      ],
                    ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              song.artist,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppTheme.textHint,
                    size: 20,
                  ),
                  onPressed: () {
                    _showSongOptions(context, song);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSongOptions(BuildContext context, Song song) {
    _showAddToPlaylistDialog(context, song);
  }

  void _showAddToPlaylistDialog(BuildContext context, Song song) async {
    final playlistsState = ref.read(playlistsNotifierProvider);
    final createdPlaylists = playlistsState.items.where((p) => p.type == PlaylistType.created).toList();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundCard,
          title: const Text(
            '收藏到歌单',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: createdPlaylists.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.playlist_add_rounded,
                      size: 48,
                      color: AppTheme.textHint.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '还没有创建歌单',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '请先在"我的音乐"页面创建歌单',
                      style: TextStyle(
                        color: AppTheme.textHint,
                        fontSize: 13,
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: createdPlaylists.length,
                    itemBuilder: (context, index) {
                      final playlist = createdPlaylists[index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentPurple.withValues(alpha: 0.6),
                                AppTheme.accentBlue.withValues(alpha: 0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.library_music_rounded,
                            color: AppTheme.textPrimary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          playlist.name,
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          await _addSongToPlaylist(context, song, playlist);
                        },
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addSongToPlaylist(BuildContext context, Song song, Playlist playlist) async {
    try {
      final playlistSong = PlaylistSong(
        playlistId: playlist.sourceId,
        songTitle: song.title,
        artist: song.artist,
        playUrl: song.playUrl,
      );

      final repository = ref.read(playlistRepositoryProvider);
      await repository.addSongToPlaylist(playlist.sourceId, playlistSong);

      // Refresh the playlist songs
      ref.invalidate(playlistSongsNotifierProvider(playlist.sourceId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.backgroundCard,
            content: Text(
              '已添加到歌单"${playlist.name}"',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.error,
            content: Text(
              '添加失败: $e',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        );
      }
    }
  }
}