import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/features/library/presentation/pages/playlist_detail_page.dart';
import 'package:music_app/src/features/library/presentation/providers/playlist_notifier.dart';
import 'package:music_app/src/shared/theme/app_theme.dart';

class PlaylistListItem extends ConsumerWidget {
  const PlaylistListItem({super.key, required this.playlist});

  final Playlist playlist;

  Widget _buildSourceBadge(BuildContext context) {
    // Show badge for custom playlists
    if (playlist.type == PlaylistType.created) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.accentPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppTheme.accentPurple.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person,
              size: 12,
              color: AppTheme.accentPurple,
            ),
            const SizedBox(width: 3),
            Text(
              '自建',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.accentPurple,
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
      backgroundColor: AppTheme.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (playlist.type != PlaylistType.created)
                ListTile(
                  leading: const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary),
                  title: const Text('刷新歌单', style: TextStyle(color: AppTheme.textPrimary)),
                  subtitle: playlist.originalUrl != null
                      ? Text('重新获取歌单最新内容', style: TextStyle(color: AppTheme.textSecondary))
                      : Text('此歌单不支持刷新', style: TextStyle(color: AppTheme.textHint)),
                  enabled: playlist.originalUrl != null,
                  onTap: playlist.originalUrl != null
                      ? () async {
                          Navigator.pop(context);
                          _refreshPlaylist(context, ref);
                        }
                      : null,
                ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: AppTheme.error),
                title: const Text('删除歌单', style: TextStyle(color: AppTheme.error)),
                subtitle: Text('删除歌单及其所有歌曲', style: TextStyle(color: AppTheme.error.withValues(alpha: 0.7))),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, ref);
                },
              ),
              const SizedBox(height: 8),
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
          backgroundColor: AppTheme.backgroundCard,
          title: const Text('确认删除', style: TextStyle(color: AppTheme.textPrimary)),
          content: Text(
            '确定要删除歌单"${playlist.name}"吗？此操作不可恢复。',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
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
              style: TextButton.styleFrom(foregroundColor: AppTheme.error),
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
          SnackBar(
            backgroundColor: AppTheme.backgroundCard,
            content: Text('歌单"${playlist.name}"已删除', style: const TextStyle(color: AppTheme.textPrimary)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.error,
            content: Text('删除失败: $e', style: const TextStyle(color: AppTheme.textPrimary)),
          ),
        );
      }
    }
  }

  Future<void> _refreshPlaylist(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.backgroundCard,
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.accentPurple,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('正在刷新歌单...', style: TextStyle(color: AppTheme.textPrimary)),
              ],
            ),
            duration: const Duration(seconds: 30),
          ),
        );
      }

      final message = await ref
          .read(playlistsNotifierProvider.notifier)
          .refreshPlaylist(playlist.sourceId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.backgroundCard,
            content: Text(message, style: const TextStyle(color: AppTheme.textPrimary)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.error,
            content: Text('刷新失败: $e', style: const TextStyle(color: AppTheme.textPrimary)),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistDetailPage(
                  playlistId: playlist.sourceId,
                  playlistName: playlist.name,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 歌单图标
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.accentPurple.withValues(alpha: 0.8),
                        AppTheme.accentBlue.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.library_music_rounded,
                    color: AppTheme.textPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                // 歌单信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              playlist.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildSourceBadge(context),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '更新于 ${_formatDate(playlist.importTime)}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // 更多选项按钮
                IconButton(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppTheme.textHint,
                    size: 20,
                  ),
                  onPressed: () => _showPlaylistMenu(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}