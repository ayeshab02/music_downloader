

// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/player_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/music_provider.dart';
import 'widgets/mini_player.dart';

void main() {
  runApp(const ProviderScope(child: MusicApp()));
}

final GoRouter _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/library',
          builder: (context, state) => const LibraryScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) => const PlayerScreen(),
    ),
  ],
);

class MusicApp extends ConsumerWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final customColors = ref.watch(customColorsProvider);

    return MaterialApp.router(
      title: 'Cute Music Downloader',
      routerConfig: _router,
      theme: _buildTheme(false, customColors),
      darkTheme: _buildTheme(true, customColors),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(bool isDark, Map<String, Color> customColors) {
    final colorScheme = isDark
        ? ColorScheme.dark(
      primary: customColors['primary'] ?? const Color(0xFF9C27B0),
      secondary: customColors['secondary'] ?? const Color(0xFFE91E63),
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
    )
        : ColorScheme.light(
      primary: customColors['primary'] ?? const Color(0xFF9C27B0),
      secondary: customColors['secondary'] ?? const Color(0xFFE91E63),
      surface: Colors.white,
      background: const Color(0xFFF8F9FA),
    );

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: GoogleFonts.poppinsTextTheme(),
      useMaterial3: true,
    );
  }
}

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: _getGradientForRoute(context),
            ),
            child: child,
          ),
          if (currentSong != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: const MiniPlayer(),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  LinearGradient _getGradientForRoute(BuildContext context) {
    final route = GoRouterState.of(context).matchedLocation;
    switch (route) {
      case '/':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFC1E3), Color(0xFF9BB5FF)],
        );
      case '/library':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB19CD9), Color(0xFFDDD6FE)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFC1E3), Color(0xFF9BB5FF)],
        );
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    final route = GoRouterState.of(context).matchedLocation;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: route == '/' ? 0 : 1,
        onTap: (index) {
          if (index == 0) {
            context.go('/');
          } else {
            context.go('/library');
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_rounded),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
