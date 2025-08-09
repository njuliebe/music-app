import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/src/features/home/presentation/home_page.dart';
import 'package:music_app/src/features/library/presentation/pages/library_page.dart';
import 'package:music_app/src/features/lyrics/presentation/lyric_search_screen.dart';
import 'package:music_app/src/features/search/presentation/search_page.dart';

final pageIndexProvider = StateProvider<int>((ref) => 0);

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  final _pages = const [HomePage(), SearchPage(), LibraryPage()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIndex = ref.watch(pageIndexProvider);

    return Scaffold(
      body: _pages[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: (index) => ref.read(pageIndexProvider.notifier).state = index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_library_music_outlined),
            activeIcon: Icon(Icons.my_library_music),
            label: 'My Library',
          ),
        ],
      ),
    );
  }
}
