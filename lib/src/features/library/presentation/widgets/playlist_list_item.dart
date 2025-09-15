import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/features/library/presentation/pages/playlist_detail_page.dart';
import 'package:music_app/src/features/library/presentation/providers/playlist_notifier.dart';

class PlaylistListItem extends ConsumerWidget {
  const PlaylistListItem({super.key, required this.playlist});

  final Playlist playlist;

  Widget _buildSourceBadge(BuildContext context) {
    // Show badge for custom playlists
    if (playlist.type == PlaylistType.created) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 3),
            Text(
              '自建',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Show badge for imported playlists
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
        color: (config['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: (config['color'] as Color).withValues(alpha: 0.3),
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

  void _showPlaylistMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (playlist.type != PlaylistType.created)
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('刷新歌单'),
                  subtitle: playlist.originalUrl != null
                      ? const Text('重新获取歌单最新内容')
                      : const Text('此歌单不支持刷新'),
                  enabled: playlist.originalUrl != null,
                  onTap: playlist.originalUrl != null
                      ? () async {
                          Navigator.pop(context);
                          _refreshPlaylist(context, ref);
                        }
                      : null,
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除歌单', style: TextStyle(color: Colors.red)),
                subtitle: const Text('删除歌单及其所有歌曲'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, ref);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('取消'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除歌单"${playlist.name}"吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deletePlaylist(context, ref);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePlaylist(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(playlistsNotifierProvider.notifier).deletePlaylist(playlist.sourceId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('歌单"${playlist.name}"已删除')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  Future<void> _refreshPlaylist(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('正在刷新歌单...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      final message = await ref
          .read(playlistsNotifierProvider.notifier)
          .refreshPlaylist(playlist.sourceId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('刷新失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.music_note_rounded, size: 40), // 临时用图标代替封面
      title: Row(
        children: [
          Expanded(
            child: Text(
              playlist.name,
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
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showPlaylistMenu(context, ref),
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
