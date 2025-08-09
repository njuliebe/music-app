import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/data/providers.dart';
import 'package:music_app/src/features/library/presentation/widgets/playlist_list_item.dart';
import 'package:music_app/main.dart'; // 引入 main.dart 以使用 providers

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 Riverpod 的 provider 来获取数据流
    final playlistsAsyncValue = ref.watch(playlistsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的音乐库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: 实现创建歌单功能
            },
          ),
        ],
      ),
      body: playlistsAsyncValue.when(
        data: (playlists) {
          if (playlists.isEmpty) {
            return const Center(child: Text('没有找到任何歌单'));
          }

          final createdPlaylists =
              playlists.where((p) => p.type == PlaylistType.created).toList();
          final collectedPlaylists =
              playlists.where((p) => p.type == PlaylistType.collected).toList();

          return ListView(
            children: [
              if (createdPlaylists.isNotEmpty)
                _buildSectionHeader(
                  context,
                  '我创建的歌单 (${createdPlaylists.length})',
                ),
              ...createdPlaylists.map(
                (playlist) => PlaylistListItem(playlist: playlist),
              ),
              if (collectedPlaylists.isNotEmpty) ...[
                const Divider(),
                _buildSectionHeader(
                  context,
                  '我收藏的歌单 (${collectedPlaylists.length})',
                ),
                ...collectedPlaylists.map(
                  (playlist) => PlaylistListItem(playlist: playlist),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('发生错误: $error')),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
