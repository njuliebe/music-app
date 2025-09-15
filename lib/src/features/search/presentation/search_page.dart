import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/models/playlist_song.dart';
import 'package:music_app/src/data/models/song.dart';
import 'package:music_app/src/data/providers.dart';
import 'package:music_app/src/features/player/presentation/player_page.dart';
import 'package:music_app/src/features/player/presentation/providers/playback_provider.dart';

// 1. 创建一个 FutureProvider，用于搜索歌曲
final searchResultsProvider = FutureProvider.autoDispose
    .family<List<Song>, String>((ref, query) async {
      if (query.isEmpty) {
        return [];
      }
      final musicRepository = ref.watch(musicRepositoryProvider);
      return musicRepository.searchSongs(query);
    });

// 2. 将 SearchPage 转换为 ConsumerStatefulWidget
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索')),
      body: Column(
        children: [_buildSearchBar(), Expanded(child: _buildSearchResults())],
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索歌曲、歌手等',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
              onSubmitted: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _searchQuery = _searchController.text;
              });
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  // 3. 修改 _buildSearchResults 以使用 FutureProvider
  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return const Center(child: Text('输入关键词搜索歌曲'));
    }
    final searchResults = ref.watch(searchResultsProvider(_searchQuery));

    return searchResults.when(
      data: (songs) {
        if (songs.isEmpty) {
          return const Center(child: Text('未找到相关结果'));
        }
        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return ListTile(
              title: Text(song.title),
              subtitle: Text(song.artist),
              onTap: () async {
                if (song.playUrl != null && song.playUrl!.isNotEmpty) {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => PlayerPage()));
                } else {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) =>
                            const Center(child: CircularProgressIndicator()),
                  );
                  try {
                    final musicRepository = ref.read(musicRepositoryProvider);
                    final detailedSong = await musicRepository.getSongDetail(
                      song,
                    );

                    // Create a PlaylistSong from the detailed song
                    final playlistSong = PlaylistSong(
                      playlistId: 'search', // Temporary playlist ID for search results
                      songTitle: detailedSong.title,
                      artist: detailedSong.artist,
                      playUrl: detailedSong.playUrl,
                    );

                    // Start playback with the song
                    final playbackService = ref.read(playbackServiceProvider);
                    await playbackService.start([playlistSong], startIndex: 0);

                    if (!mounted) return;
                    Navigator.of(context).pop(); // Close the loading indicator
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PlayerPage()),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    Navigator.of(context).pop(); // Close the loading indicator
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('加载歌曲失败: $e')),
                    );
                  }
                }
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('错误: $error')),
    );
  }
}
