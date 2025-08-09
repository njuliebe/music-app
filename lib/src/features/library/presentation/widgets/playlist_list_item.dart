import 'package:flutter/material.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/features/playlist/presentation/pages/playlist_detail_page.dart';

class PlaylistListItem extends StatelessWidget {
  const PlaylistListItem({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.music_note_rounded, size: 40), // 临时用图标代替封面
      title: Text(playlist.name ?? '未知歌单'),
      subtitle: Text(
        '${playlist.type == PlaylistType.created ? "创建者" : "收藏者"}: ${playlist.creator ?? '未知'}',
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PlaylistDetailPage(
                  playlistId: playlist.id?.toString() ?? '',
                  playlistName: playlist.name,
                ),
          ),
        );
      },
    );
  }
}
