import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/features/library/presentation/providers/playlist_song_notifier.dart';

class PlaylistDetailPage extends ConsumerStatefulWidget {
  const PlaylistDetailPage({
    super.key,
    required this.playlistId,
    this.playlistName,
  });

  final String playlistId;
  final String? playlistName;

  @override
  ConsumerState<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends ConsumerState<PlaylistDetailPage> {
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
      ref.read(playlistSongsNotifierProvider(widget.playlistId).notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final songsState = ref.watch(playlistSongsNotifierProvider(widget.playlistId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.playlistName ?? '歌单')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(playlistSongsNotifierProvider(widget.playlistId).notifier).refresh(),
        child: Builder(builder: (context) {
          if (songsState.items.isEmpty && songsState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (songsState.items.isEmpty && !songsState.hasMore) {
            return const Center(child: Text('歌单里没有歌曲'));
          } else {
            return ListView.builder(
              controller: _scrollController,
              itemCount: songsState.items.length + (songsState.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == songsState.items.length) {
                  if (songsState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('没有更多歌曲了'),
                    ));
                  }
                }

                final playlistSong = songsState.items[index];
                return ListTile(
                  title: Text(playlistSong.songTitle),
                  subtitle: Text(playlistSong.artist),
                  onTap: () {
                    // TODO: implement play song
                  },
                );
              },
            );
          }
        }),
      ),
    );
  }
}