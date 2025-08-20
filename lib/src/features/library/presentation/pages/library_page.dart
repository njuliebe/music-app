import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/data/providers.dart';
import 'package:music_app/src/features/library/presentation/providers/playlist_notifier.dart';
import 'package:music_app/src/features/library/presentation/widgets/playlist_list_item.dart';
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
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
              // TODO: Implement create playlist functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: () {
              _showImportPlaylistDialog(context, ref);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(playlistsNotifierProvider.notifier).refresh(),
        child: Builder(builder: (context) {
          if (playlistState.items.isEmpty && playlistState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (playlistState.items.isEmpty && !playlistState.hasMore) {
            return const Center(child: Text('没有找到任何歌单'));
          } else {
            return ListView.builder(
              controller: _scrollController,
              itemCount: playlistState.items.length + (playlistState.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == playlistState.items.length) {
                  if (playlistState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('没有更多歌单了'),
                    ));
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
        }),
      ),
    );
  }

  void _showImportPlaylistDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController _urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('导入歌单'),
          content: TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              hintText: '请输入歌单链接',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('导入'),
              onPressed: () async {
                final String playlistUrl = _urlController.text;
                if (playlistUrl.isEmpty) return;

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.of(dialogContext).pop();

                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('正在导入歌单...')),
                );

                try {
                  final importService = ref.read(playlistImportServiceProvider);
                  final playlistRepository = ref.read(playlistRepositoryProvider);
                  final importedPlaylist = await importService.importPlaylist(playlistUrl);

                  if (importedPlaylist != null) {
                    await playlistRepository.saveImportedPlaylist(importedPlaylist);
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('歌单 "${importedPlaylist.name}" 导入成功！')),
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
              },
            ),
          ],
        );
      },
    );
  }
}