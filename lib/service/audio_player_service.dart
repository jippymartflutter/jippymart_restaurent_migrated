import 'package:audioplayers/audioplayers.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

class AudioPlayerService {
  static AudioPlayer? _audioPlayer;

  static initAudio() async {
    // If player already exists, reuse it (don't create new one)
    if (_audioPlayer == null) {
      _audioPlayer = AudioPlayer(playerId: "playerId");
    }
  }

  static Future<void> playSound(bool isPlay) async {
    try {
      // Ensure AudioPlayer is initialized
      if (_audioPlayer == null) {
        await initAudio();
      }
      
      if (isPlay) {
        if (_audioPlayer!.state != PlayerState.playing) {
          await _audioPlayer!.setSource(
              UrlSource(Preferences.getString(Preferences.orderRingtone)));
          await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
          await _audioPlayer!.resume();
        }
      } else {
        // Always try to stop, regardless of current state
        try {
          await _audioPlayer!.stop();
        } catch (stopError) {
          // Try to pause as fallback
          try {
            await _audioPlayer!.pause();
            await _audioPlayer!.stop();
          } catch (pauseError) {
            // Ignore errors - sound may already be stopped
          }
        }
      }
    } catch (e) {
      print("Error in playSound: $e");
    }
  }
}
