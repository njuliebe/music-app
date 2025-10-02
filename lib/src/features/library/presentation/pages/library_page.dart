import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/providers.dart';
import 'package:music_app/src/features/library/presentation/providers/playlist_notifier.dart';
import 'package:music_app/src/features/library/presentation/widgets/playlist_list_item.dart';
import 'package:music_app/src/features/library/presentation/widgets/import_tips_dialog.dart';
import 'package:music_app/main.dart'; // For playlistRepositoryProvider

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load next page when user is 200 pixels from the bottom
      ref.read(playlistsNotifierProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlistState = ref.watch(playlistsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的音乐库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreatePlaylistDialog(context, ref);
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: () async {
              // Show tips dialog with URL input
              final result = await showDialog<String>(
                context: context,
                builder: (context) => ImportTipsDialog(
                  onComplete: () {},
                ),
              );

              if (result != null && result.isNotEmpty) {
                // Process the import directly with the URL
                _importPlaylist(context, ref, result);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(playlistsNotifierProvider.notifier).refresh(),
        child: Builder(
          builder: (context) {
            if (playlistState.items.isEmpty && playlistState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (playlistState.items.isEmpty && !playlistState.hasMore) {
              return const Center(child: Text('没有找到任何歌单'));
            } else {
              return ListView.builder(
                controller: _scrollController,
                itemCount:
                    playlistState.items.length +
                    (playlistState.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == playlistState.items.length) {
                    if (playlistState.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('没有更多歌单了'),
                        ),
                      );
                    }
                  }

                  final playlist = playlistState.items[index];
                  // The UI for displaying playlists needs to be reconstructed as the original
                  // logic for separating created/collected is not suitable for pagination.
                  // For now, we will display them as a single list.
                  return PlaylistListItem(playlist: playlist);
                },
              );
            }
          },
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建歌单'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '歌单名称',
                hintText: '请输入歌单名称',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '歌单描述（可选）',
                hintText: '请输入歌单描述',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入歌单名称')),
                );
                return;
              }

              Navigator.of(context).pop();
              await _createPlaylist(context, ref, name, descriptionController.text.trim());
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPlaylist(BuildContext context, WidgetRef ref, String name, String description) async {
    try {
      await ref.read(playlistsNotifierProvider.notifier).createPlaylist(name, description);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('歌单"$name"创建成功')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    }
  }

  void _importPlaylist(BuildContext context, WidgetRef ref, String playlistUrl) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('正在导入歌单...')),
    );

    try {
      final importService = ref.read(playlistImportServiceProvider);
      final playlistRepository = ref.read(playlistRepositoryProvider);
      final importedPlaylist = await importService.importPlaylist(playlistUrl);

      if (importedPlaylist != null) {
        print('DEBUG: Imported playlist name: "${importedPlaylist.name}"');
        print('DEBUG: Imported playlist songs count: ${importedPlaylist.songs.length}');
        if (importedPlaylist.songs.isNotEmpty) {
          print('DEBUG: First song: "${importedPlaylist.songs.first.title}" by ${importedPlaylist.songs.first.artist}');
        }
        await playlistRepository.saveImportedPlaylist(importedPlaylist);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('歌单 "${importedPlaylist.name}" 导入成功！'),
          ),
        );
        ref.read(playlistsNotifierProvider.notifier).refresh();
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('歌单导入失败：未获取到歌单数据。')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('歌单导入失败: ${e.toString()}')),
      );
    }
  }
}
