import 'package:audioplayers/audioplayers.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class AudioPlayerService {
  static AudioPlayer? _audioPlayer;
  static bool _isPlaying = false;
  static bool _isInitialized = false;
  static bool _isStopping = false; // Add flag to prevent race conditions

  static Future<void> initAudio() async {
    if (!_isInitialized) {
      _audioPlayer = AudioPlayer()
        ..setVolume(1.0)
        ..setReleaseMode(ReleaseMode.loop);

      _isInitialized = true;

      // Listen to player state changes for debugging
      _audioPlayer!.onPlayerStateChanged.listen((state) {
        print('Audio Player State Changed: $state');
        _isPlaying = state == PlayerState.playing;
      });

      // Listen to logs
      _audioPlayer!.onLog.listen((log) {
        print('Audio Player Log: $log');
      });

      // iOS-specific: Listen for completion
      _audioPlayer!.onPlayerComplete.listen((event) {
        print('Audio playback completed');
        _isPlaying = false;
      });
    }
  }

  static Future<void> playSound(bool isPlay) async {
    // Prevent race conditions
    if (_isStopping) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    try {
      // Ensure AudioPlayer is initialized
      if (!_isInitialized) {
        await initAudio();
      }

      if (isPlay) {
        if (!_isPlaying) {
          final soundUrl = Preferences.getString(Preferences.orderRingtone);
          print('Playing sound from URL: $soundUrl');

          // Stop any current playback first (with retry logic for iOS)
          await _stopAudioWithRetry();

          if (soundUrl.isEmpty || !soundUrl.startsWith('http')) {
            print('Invalid sound URL, using default');
            // Use asset source as fallback
            await _audioPlayer!.play(
              AssetSource('sounds/order_alert.mp3'),
              volume: 1.0,
              mode: PlayerMode.lowLatency,
            );
          } else {
            // Use URL source
            await _audioPlayer!.play(
              UrlSource(soundUrl),
              volume: 1.0,
              mode: PlayerMode.lowLatency,
            );
          }

          _isPlaying = true;

          // Auto-stop after 10 seconds (safety measure)
          Future.delayed(Duration(seconds: 10), () async {
            if (_isPlaying) {
              print('Auto-stopping audio after 10 seconds');
              await stopSound();
            }
          });

          // Debug: Check after 1 second if it's playing
          Future.delayed(Duration(seconds: 1), () async {
            final state = _audioPlayer!.state;
            print('Audio state after 1 second: $state');
          });
        }
      } else {
        // Stop playing
        await stopSound();
      }
    } catch (e) {
      print("Error in playSound: $e");

      // Reset state on error
      _isPlaying = false;
      _isStopping = false;
    }
  }

  static Future<void> _stopAudioWithRetry() async {
    if (_audioPlayer == null) return;

    _isStopping = true;

    try {
      // For iOS, we need to be more aggressive with stopping
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Method 1: Try stop
        await _audioPlayer!.stop();

        // Method 2: Try pause and dispose if stop doesn't work
        await Future.delayed(Duration(milliseconds: 100));
        if (_isPlaying) {
          await _audioPlayer!.pause();
          await _audioPlayer!.stop();
        }

        // Method 3: Dispose and recreate if still playing
        await Future.delayed(Duration(milliseconds: 100));
        if (_isPlaying) {
          await _audioPlayer!.dispose();
          _audioPlayer = null;
          _isInitialized = false;
          await initAudio();
        }
      } else {
        // For Android, simple stop is usually enough
        await _audioPlayer!.stop();
      }

      _isPlaying = false;
    } catch (e) {
      print('Error in _stopAudioWithRetry: $e');
      // Force reset state
      _isPlaying = false;
    } finally {
      _isStopping = false;
    }
  }

  static Future<void> stopSound() async {
    if (_audioPlayer == null) return;

    await _stopAudioWithRetry();

    // Additional iOS-specific: Release resources
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await _audioPlayer!.release();
      } catch (e) {
        print('Error releasing audio: $e');
      }
    }
  }

  static Future<void> disposePlayer() async {
    try {
      await stopSound();

      if (_audioPlayer != null) {
        await _audioPlayer!.dispose();
        _audioPlayer = null;
      }

      _isPlaying = false;
      _isInitialized = false;
      _isStopping = false;
    } catch (e) {
      print('Error in disposePlayer: $e');
    }
  }

  // Test method to verify audio is working
  static Future<void> testAudio() async {
    try {
      if (!_isInitialized) {
        await initAudio();
      }

      print('Testing audio playback...');

      // Play a short test sound
      await _audioPlayer!.play(
        AssetSource('sounds/order_alert.mp3'),
        volume: 1.0,
        mode: PlayerMode.lowLatency,
      );

      // Stop after 2 seconds
      await Future.delayed(Duration(seconds: 2));
      await stopSound();

      print('Audio test completed');
    } catch (e) {
      print('Audio test failed: $e');
    }
  }
}