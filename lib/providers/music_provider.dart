// providers/music_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song.dart';
import '../services/music_service.dart';

final musicServiceProvider = Provider<MusicService>((ref) => MusicService());

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<List<Song>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final musicService = ref.watch(musicServiceProvider);
  return await musicService.searchSongs(query);
});

final currentSongProvider = StateNotifierProvider<CurrentSongNotifier, Song?>((ref) {
  return CurrentSongNotifier(ref.watch(musicServiceProvider));
});

final isPlayingProvider = StateProvider<bool>((ref) => false);
final positionProvider = StateProvider<Duration>((ref) => Duration.zero);
final durationProvider = StateProvider<Duration>((ref) => Duration.zero);

final downloadedSongsProvider = StateNotifierProvider<DownloadedSongsNotifier, List<Song>>((ref) {
  return DownloadedSongsNotifier(ref.watch(musicServiceProvider));
});

final playlistProvider = StateNotifierProvider<PlaylistNotifier, List<Song>>((ref) {
  return PlaylistNotifier();
});

class CurrentSongNotifier extends StateNotifier<Song?> {
  final MusicService _musicService;

  CurrentSongNotifier(this._musicService) : super(null);

  void setSong(Song song) {
    state = song;
  }

  void toggleFavorite() {
    if (state != null) {
      state = state!.copyWith(isFavorite: !state!.isFavorite);
      _musicService.updateSong(state!);
    }
  }
}

class DownloadedSongsNotifier extends StateNotifier<List<Song>> {
  final MusicService _musicService;

  DownloadedSongsNotifier(this._musicService) : super([]) {
    loadDownloadedSongs();
  }

  Future<void> loadDownloadedSongs() async {
    state = await _musicService.getDownloadedSongs();
  }

  Future<void> downloadSong(Song song) async {
    await _musicService.downloadSong(song);
    await loadDownloadedSongs();
  }

  Future<void> deleteSong(Song song) async {
    await _musicService.deleteSong(song);
    await loadDownloadedSongs();
  }
}

class PlaylistNotifier extends StateNotifier<List<Song>> {
  PlaylistNotifier() : super([]);

  void addSong(Song song) {
    state = [...state, song];
  }

  void removeSong(Song song) {
    state = state.where((s) => s.id != song.id).toList();
  }

  void reorderSongs(int oldIndex, int newIndex) {
    final songs = [...state];
    final song = songs.removeAt(oldIndex);
    songs.insert(newIndex, song);
    state = songs;
  }
}