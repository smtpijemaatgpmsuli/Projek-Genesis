import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

import '../../features/authentication/application/providers/auth_state.dart';

/// Splash screen aplikasi.
///
/// Dua mode:
/// 1. **Pre-login (no cached session):** putar splash.mp4, lalu redirect ke sign-in
/// 2. **Post-login (cached session):** tampilkan logo + nama aplikasi loading, lalu redirect ke dashboard
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _videoEnded = false;
  bool _navigating = false;
  late bool _hasSession;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Cek apakah ada session tersimpan (user sudah pernah login)
    _hasSession = Supabase.instance.client.auth.currentUser != null;

    // Animasi pulse untuk logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (!_hasSession) {
      _initVideo();
    }
  }

  void _initVideo() {
    _videoController = VideoPlayerController.asset('assets/splash.mp4');
    _videoController!.initialize().then((_) {
      if (!mounted) return;
      setState(() => _videoReady = true);
      _videoController!.play();
      _videoController!.addListener(_onVideoUpdate);
    });
  }

  void _onVideoUpdate() {
    if (!mounted || _videoController == null || _navigating) return;
    final pos = _videoController!.value.position;
    final dur = _videoController!.value.duration;
    if (dur != Duration.zero && pos >= dur - const Duration(milliseconds: 100)) {
      _videoEnded = true;
      _videoController!.removeListener(_onVideoUpdate);
      setState(() {});
      _onSplashDone();
    }
  }

  void _onSplashDone() {
    if (_navigating) return;
    final authState = ref.read(authStateProvider);
    switch (authState) {
      case AuthAuthenticated _:
        _navigating = true;
        context.go('/');
      case AuthUnauthenticated _:
        _navigating = true;
        context.go('/sign-in');
      case AuthInitial _:
        // Auth belum selesai — logo loading akan tampil,
        // nanti AuthGuard yang handle redirect-nya
        break;
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // If auth already resolved to Authenticated while we're showing video/loading
    if (authState case AuthAuthenticated _) {
      // Use post-frame to avoid build-time navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_navigating && mounted) {
          _navigating = true;
          context.go('/');
        }
      });
      return _buildLogoLoading(context);
    }

    // Session terdeteksi — logo loading screen (tunggu AuthGuard redirect)
    if (_hasSession) {
      return _buildLogoLoading(context);
    }

    // Video sudah siap dan belum selesai
    if (_videoReady && !_videoEnded) {
      return _buildVideoSplash(context);
    }

    // Fallback: logo loading
    return _buildLogoLoading(context);
  }

  Widget _buildVideoSplash(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video fullscreen — branding intro
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoLoading(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: FadeTransition(
          opacity: _pulseAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Image.asset(
                'assets/logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),

              // Teks "E-Raport Sekolah Minggu" — playful & colorful
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'E-Raport',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: 'Sekolah',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: 'Minggu',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEF476F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Genesis',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 32),

              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 12),
              Text(
                _hasSession ? 'Memulihkan sesi...' : 'Memuat...',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
