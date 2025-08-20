import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/data/providers.dart';
import 'package:music_app/src/features/library/presentation/providers/playlist_song_notifier.dart';
import 'package:music_app/src/features/player/presentation/player_page.dart';
import 'package:music_app/src/features/player/presentation/providers/playback_provider.dart';

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
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton.icon(
                  onPressed: () async {
                    final songs = ref.read(playlistSongsNotifierProvider(widget.playlistId)).items;
                    if (songs.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('歌单里没有歌曲')),
                      );
                      return;
                    }

                    final playbackService = ref.read(playbackServiceProvider);
                    playbackService.start(songs);

                    final currentSong = playbackService.currentSong;
                    if (currentSong == null) return;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final detailedSong =
                          await playbackService.getDetailedSong(currentSong);
                      Navigator.of(context).pop(); // Close the loading indicator

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlayerPage(song: detailedSong),
                        ),
                      );
                    } catch (e) {
                      Navigator.of(context).pop(); // Close the loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('播放失败: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('随机播放全部'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ),
            if (songsState.items.isEmpty && songsState.isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (songsState.items.isEmpty && !songsState.hasMore)
              const SliverFillRemaining(child: Center(child: Text('歌单里没有歌曲')))
            else
              SliverList.builder(
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
                    onTap: () async {
                      final playbackService = ref.read(playbackServiceProvider);
                      final allSongsInPlaylist = songsState.items;
                      final tappedSongIndex = allSongsInPlaylist.indexOf(playlistSong);

                      if (tappedSongIndex == -1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('歌曲未找到')),
                        );
                        return;
                      }

                      playbackService.start(allSongsInPlaylist, startIndex: tappedSongIndex);

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final detailedSong =
                            await playbackService.getDetailedSong(playlistSong);
                        Navigator.of(context).pop(); // Close the loading indicator

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PlayerPage(song: detailedSong),
                          ),
                        );
                      } catch (e) {
                        Navigator.of(context).pop(); // Close the loading indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('播放失败: $e')),
                        );
                      }
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}