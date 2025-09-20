
// services/music_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class MusicService {
  final Dio _dio = Dio();
  static const String _jamendoApiUrl = 'https://api.jamendo.com/v3.0';
  static const String _clientId = '19a89a72'; // Replace with actual client ID

  Future<List<Song>> searchSongs(String query) async {
    try {
      final response = await _dio.get(
        '$_jamendoApiUrl/tracks',
        queryParameters: {
          'client_id': _clientId,
          'format': 'json',
          'search': query,
          'limit': 20,
          'include': 'musicinfo',
        },
      );

      final List<dynamic> results = response.data['results'];
      return results.map((json) => Song.fromJson({
        'id': json['id'].toString(),
        'title': json['name'] ?? 'Unknown Title',
        'artist': json['artist_name'] ?? 'Unknown Artist',
        'albumArt': json['album_image'] ?? '',
        'audioUrl': json['audio'] ?? '',
        'duration': json['duration'] ?? 0,
        'lyrics': null,
        'isDownloaded': false,
        'localPath': null,
        'isFavorite': false,
      })).toList();
    } catch (e) {
      // Fallback mock data for development
      return _getMockSongs(query);
    }
  }

  List<Song> _getMockSongs(String query) {
    return [
      Song(
        id: '1',
        title: 'Chill Vibes $query',
        artist: 'Lo-Fi Artist',
        albumArt: 'https://picsum.photos/300/300?random=1',
        audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
        duration: 180,
      ),
      Song(
        id: '2',
        title: 'Summer Breeze',
        artist: 'Indie Pop',
        albumArt: 'https://picsum.photos/300/300?random=2',
        audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
        duration: 210,
      ),
      Song(
        id: '3',
        title: 'Neon Dreams',
        artist: 'Synthwave',
        albumArt: 'https://picsum.photos/300/300?random=3',
        audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
        duration: 195,
      ),
    ];
  }

  Future<void> downloadSong(Song song) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${song.id}.mp3';

      await _dio.download(song.audioUrl, filePath);

      final updatedSong = song.copyWith(
        isDownloaded: true,
        localPath: filePath,
      );

      await _saveSongToLocal(updatedSong);
    } catch (e) {
      throw Exception('Failed to download song: $e');
    }
  }

  Future<void> _saveSongToLocal(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final songs = await getDownloadedSongs();
    songs.removeWhere((s) => s.id == song.id);
    songs.add(song);

    final jsonList = songs.map((s) => s.toJson()).toList();
    await prefs.setString('downloaded_songs', jsonEncode(jsonList));
  }

  Future<List<Song>> getDownloadedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('downloaded_songs') ?? '[]';
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Song.fromJson(json)).toList();
  }

  Future<void> deleteSong(Song song) async {
    if (song.localPath != null) {
      final file = File(song.localPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    final songs = await getDownloadedSongs();
    songs.removeWhere((s) => s.id == song.id);

    final prefs = await SharedPreferences.getInstance();
    final jsonList = songs.map((s) => s.toJson()).toList();
    await prefs.setString('downloaded_songs', jsonEncode(jsonList));
  }

  Future<void> updateSong(Song song) async {
    await _saveSongToLocal(song);
  }
}