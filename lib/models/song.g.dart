// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Song _$SongFromJson(Map<String, dynamic> json) => Song(
  id: json['id'] as String,
  title: json['title'] as String,
  artist: json['artist'] as String,
  albumArt: json['albumArt'] as String,
  audioUrl: json['audioUrl'] as String,
  duration: (json['duration'] as num).toInt(),
  lyrics: json['lyrics'] as String?,
  isDownloaded: json['isDownloaded'] as bool? ?? false,
  localPath: json['localPath'] as String?,
  isFavorite: json['isFavorite'] as bool? ?? false,
);

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'artist': instance.artist,
  'albumArt': instance.albumArt,
  'audioUrl': instance.audioUrl,
  'duration': instance.duration,
  'lyrics': instance.lyrics,
  'isDownloaded': instance.isDownloaded,
  'localPath': instance.localPath,
  'isFavorite': instance.isFavorite,
};
