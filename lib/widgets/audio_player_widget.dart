
// widgets/audio_player_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/music_provider.dart';
import '../services/audio_service.dart';

class AudioPlayerWidget extends ConsumerWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider);
    final position = ref.watch(positionProvider);
    final duration = ref.watch(durationProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Progress Bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 16,
              ),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.2),
            ),
            child: Slider(
              value: duration.inMilliseconds > 0
                  ? position.inMilliseconds / duration.inMilliseconds
                  : 0.0,
              onChanged: (value) async {
                final newPosition = Duration(
                  milliseconds: (duration.inMilliseconds * value).round(),
                );
                await AudioService.instance.seek(newPosition);
                ref.read(positionProvider.notifier).state = newPosition;
              },
            ),
          ),

          // Time Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous Button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
                child: IconButton(
                  onPressed: () {
                    // TODO: Implement previous song
                  },
                  icon: const Icon(
                    Icons.skip_previous_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

              // Play/Pause Button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () async {
                    if (isPlaying) {
                      await AudioService.instance.pause();
                      ref.read(isPlayingProvider.notifier).state = false;
                    } else {
                      await AudioService.instance.resume();
                      ref.read(isPlayingProvider.notifier).state = true;
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 40,
                  ),
                ),
              ),

              // Next Button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
                child: IconButton(
                  onPressed: () {
                    // TODO: Implement next song
                  },
                  icon: const Icon(
                    Icons.skip_next_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Additional Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Implement shuffle
                },
                icon: Icon(
                  Icons.shuffle_rounded,
                  color: Colors.white.withOpacity(0.6),
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement repeat
                },
                icon: Icon(
                  Icons.repeat_rounded,
                  color: Colors.white.withOpacity(0.6),
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Show lyrics
                },
                icon: Icon(
                  Icons.lyrics_rounded,
                  color: Colors.white.withOpacity(0.6),
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
