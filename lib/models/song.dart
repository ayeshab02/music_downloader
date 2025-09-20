// models/song.dart
import 'package:json_annotation/json_annotation.dart';

part 'song.g.dart';

@JsonSerializable()
class Song {
  final String id;
  final String title;
  final String artist;
  final String albumArt;
  final String audioUrl;
  final int duration;
  final String? lyrics;
  bool isDownloaded;
  String? localPath;
  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.audioUrl,
    required this.duration,
    this.lyrics,
    this.isDownloaded = false,
    this.localPath,
    this.isFavorite = false,
  });

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
  Map<String, dynamic> toJson() => _$SongToJson(this);

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? albumArt,
    String? audioUrl,
    int? duration,
    String? lyrics,
    bool? isDownloaded,
    String? localPath,
    bool? isFavorite,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArt: albumArt ?? this.albumArt,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      lyrics: lyrics ?? this.lyrics,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}