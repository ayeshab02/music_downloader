// widgets/song_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import '../services/audio_service.dart';

class SongCard extends ConsumerStatefulWidget {
  final Song song;
  final bool isLibraryView;

  const SongCard({
    super.key,
    required this.song,
    this.isLibraryView = false,
  });

  @override
  ConsumerState<SongCard> createState() => _SongCardState();
}

class _SongCardState extends ConsumerState<SongCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(currentSongProvider);
    final isCurrentSong = currentSong?.id == widget.song.id;
    final isPlaying = ref.watch(isPlayingProvider) && isCurrentSong;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCurrentSong
                    ? [
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ]
                    : [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: isCurrentSong
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: isCurrentSong ? 15 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                onTap: () async {
                  ref.read(currentSongProvider.notifier).setSong(widget.song);
                  await AudioService.instance.play(widget.song);
                  ref.read(isPlayingProvider.notifier).state = true;
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Album Art
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Image.network(
                                widget.song.albumArt,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.music_note_rounded,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                              if (isPlaying)
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.equalizer_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Song Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.song.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isCurrentSong
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.song.artist,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDuration(widget.song.duration),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.song.isFavorite)
                            Icon(
                              Icons.favorite_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                          const SizedBox(width: 8),
                          if (_isDownloading)
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                value: _downloadProgress,
                                strokeWidth: 2,
                              ),
                            )
                          else if (widget.song.isDownloaded)
                            Icon(
                              Icons.download_done_rounded,
                              color: Colors.green,
                              size: 24,
                            )
                          else
                            IconButton(
                              onPressed: _downloadSong,
                              icon: const Icon(Icons.download_rounded),
                              iconSize: 24,
                            ),
                          const SizedBox(width: 4),
                          if (widget.isLibraryView)
                            IconButton(
                              onPressed: _showDeleteDialog,
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                              ),
                              iconSize: 24,
                            )
                          else
                            IconButton(
                              onPressed: () => context.push('/player'),
                              icon: const Icon(Icons.open_in_full_rounded),
                              iconSize: 24,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadSong() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      // Simulate download progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          setState(() {
            _downloadProgress = i / 100;
          });
        }
      }

      await ref.read(downloadedSongsProvider.notifier).downloadSong(widget.song);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.song.title} downloaded successfully! 🎵'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Song'),
        content: Text('Are you sure you want to delete "${widget.song.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(downloadedSongsProvider.notifier).deleteSong(widget.song);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.song.title} deleted'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
