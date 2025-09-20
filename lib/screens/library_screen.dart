// screens/library_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import '../widgets/song_card.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final downloadedSongs = ref.watch(downloadedSongsProvider);
    final favoriteSongs = downloadedSongs.where((s) => s.isFavorite).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '📚 My Library',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Downloads', icon: Icon(Icons.download_rounded)),
            Tab(text: 'Favorites', icon: Icon(Icons.favorite_rounded)),
            Tab(text: 'Playlists', icon: Icon(Icons.playlist_play_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDownloadsList(downloadedSongs),
          _buildDownloadsList(favoriteSongs),
          _buildPlaylistsTab(),
        ],
      ),
    );
  }

  Widget _buildDownloadsList(List<Song> songs) {
    if (songs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note_rounded,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No songs downloaded yet',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Search and download your favorite music!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(downloadedSongsProvider.notifier).loadDownloadedSongs();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return SongCard(
            song: songs[index],
            isLibraryView: true,
          );
        },
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add_rounded,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Custom playlists coming soon!',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}