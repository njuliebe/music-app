import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/models/song.dart';
import 'package:music_app/src/data/providers.dart';

import 'package:music_app/src/features/player/presentation/player_page.dart';

// 1. 创建一个 FutureProvider，用于搜索歌曲
final searchResultsProvider = FutureProvider.autoDispose.family<List<Song>, String>((ref, query) async {
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
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for songs, artists, etc.',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  // 3. 修改 _buildSearchResults 以使用 FutureProvider
  Widget _buildSearchResults() {
    final searchResults = ref.watch(searchResultsProvider(_searchQuery));

    return searchResults.when(
      data: (songs) {
        if (songs.isEmpty) {
          return Center(
            child: Text('No results found.'),
          );
        }
        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return ListTile(
              title: Text(song.title),
              subtitle: Text(song.artist),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlayerPage(song: song),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}