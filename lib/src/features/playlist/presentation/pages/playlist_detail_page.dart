import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/main.dart';
import 'package:music_app/src/data/models/playlist_song.dart';
import 'package:music_app/src/data/repositories/playlist_repository.dart';

final playlistSongsProvider = FutureProvider.autoDispose
    .family<List<PlaylistSong>, String>((ref, playlistId) {
      final playlistRepository = ref.watch(playlistRepositoryProvider);
      return playlistRepository.getSongsForPlaylist(playlistId);
    });

class PlaylistDetailPage extends ConsumerWidget {
  const PlaylistDetailPage({
    super.key,
    required this.playlistId,
    this.playlistName,
  });

  final String playlistId;
  final String? playlistName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsyncValue = ref.watch(playlistSongsProvider(playlistId));

    return Scaffold(
      appBar: AppBar(title: Text(playlistName ?? '歌单')),
      body: songsAsyncValue.when(
        data: (songs) {
          if (songs.isEmpty) {
            return const Center(child: Text('歌单里没有歌曲'));
          }
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index].song;
              return ListTile(
                // leading: Image.network(song.album?.cover ?? '', width: 50, height: 50, fit: BoxFit.cover,),
                title: Text(song.title ?? '未知歌曲'),
                subtitle: Text(song.artist ?? '未知艺术家'),
                onTap: () {
                  // TODO: implement play song
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
      ),
    );
  }
}
