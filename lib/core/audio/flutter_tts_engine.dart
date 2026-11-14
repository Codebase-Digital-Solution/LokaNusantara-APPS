import 'package:flutter_tts/flutter_tts.dart';

import 'speech_engine.dart';

class FlutterTtsEngine implements SpeechEngine {
  final FlutterTts _tts = FlutterTts();

  @override
  Future<bool> configure(String languageTag) async {
    // Play through the speaker even when the iPhone's silent switch is on.
    await _tts.setSharedInstance(true);
    await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
      IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
    ]);
    await _tts.awaitSpeakCompletion(true);
    final available = await _tts.isLanguageAvailable(languageTag);
    if (available == true) await _tts.setLanguage(languageTag);
    return available == true;
  }

  @override
  Future<void> setRate(double rate) => _tts.setSpeechRate(rate);

  @override
  Future<void> speak(String text) => _tts.speak(text);

  @override
  Future<void> stop() => _tts.stop();
}
