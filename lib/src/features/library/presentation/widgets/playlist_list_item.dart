import 'package:flutter/material.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/features/library/presentation/pages/playlist_detail_page.dart';

class PlaylistListItem extends StatelessWidget {
  const PlaylistListItem({super.key, required this.playlist});

  final Playlist playlist;

  Widget _buildSourceBadge(BuildContext context) {
    if (playlist.source == null) return const SizedBox.shrink();

    final Map<PlaylistSource, Map<String, dynamic>> sourceConfig = {
      PlaylistSource.netease: {
        'label': '网易云',
        'color': const Color(0xFFE60026),
        'icon': Icons.cloud_outlined,
      },
      PlaylistSource.qq: {
        'label': 'QQ音乐',
        'color': const Color(0xFF31C27C),
        'icon': Icons.music_note_outlined,
      },
    };

    final config = sourceConfig[playlist.source];
    if (config == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: (config['color'] as Color).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'] as IconData,
            size: 12,
            color: config['color'] as Color,
          ),
          const SizedBox(width: 3),
          Text(
            config['label'] as String,
            style: TextStyle(
              fontSize: 10,
              color: config['color'] as Color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.music_note_rounded, size: 40), // 临时用图标代替封面
      title: Row(
        children: [
          Expanded(
            child: Text(
              playlist.name ?? '未知歌单',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _buildSourceBadge(context),
        ],
      ),
      subtitle: Text(
        '${playlist.type == PlaylistType.created ? "创建者" : "收藏者"}: ${playlist.creator ?? '未知'}',
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PlaylistDetailPage(
                  playlistId: playlist.sourceId,
                  playlistName: playlist.name,
                ),
          ),
        );
      },
    );
  }
}
