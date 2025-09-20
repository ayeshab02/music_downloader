// services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import '../models/song.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  static AudioService get instance => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> play(Song song) async {
    try {
      final source = song.isDownloaded && song.localPath != null
          ? DeviceFileSource(song.localPath!)
          : UrlSource(song.audioUrl);

      await _audioPlayer.play(source);
    } catch (e) {
      throw Exception('Failed to play song: $e');
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Stream<Duration> get positionStream => _audioPlayer.onPositionChanged;
  Stream<Duration> get durationStream => _audioPlayer.onDurationChanged;
  Stream<PlayerState> get playerStateStream => _audioPlayer.onPlayerStateChanged;
}