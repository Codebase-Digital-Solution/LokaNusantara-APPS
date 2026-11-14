/// Text-to-speech abstraction so the audio guide can be tested without the
/// platform plugin.
abstract interface class SpeechEngine {
  /// Prepares the engine for [languageTag] (e.g. "id-ID"). Returns false when
  /// the device has no voice for that language; speech still works with the
  /// default voice.
  Future<bool> configure(String languageTag);

  Future<void> setRate(double rate);

  /// Speaks [text] and completes when it has finished or was stopped.
  Future<void> speak(String text);

  Future<void> stop();
}
