import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/features/lyrics/data/lyric_repository.dart';
import 'package:music_app/src/features/lyrics/domain/lyric.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class LyricSearchScreen extends ConsumerStatefulWidget {
  const LyricSearchScreen({super.key});

  @override
  ConsumerState<LyricSearchScreen> createState() => _LyricSearchScreenState();
}

class _LyricSearchScreenState extends ConsumerState<LyricSearchScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final lyrics = ref.watch(lyricSearchProvider(searchQuery));

    return Scaffold(
      appBar: AppBar(title: const Text('搜索歌词')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '输入歌曲名或歌手',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    ref.read(searchQueryProvider.notifier).state =
                        _textController.text;
                  },
                ),
              ),
              onSubmitted: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: lyrics.when(
              data: (data) => ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final lyric = data[index];
                  return ListTile(
                    title: Text(lyric.name),
                    subtitle: Text(lyric.artistName),
                    onTap: () {
                      // TODO: Navigate to lyric detail screen
                    },
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text(error.toString())),
            ),
          ),
        ],
      ),
    );
  }
}

final lyricSearchProvider =
    FutureProvider.autoDispose.family<List<Lyric>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  return ref.watch(lyricRepositoryProvider).searchLyrics(query);
});
