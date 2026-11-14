import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;

import '../../core/audio/speech_engine.dart';
import '../../domain/entities/location.dart';

enum AudioGuideState { idle, playing, paused }

/// Speech rates; the UI names them in the app language.
enum NarrationSpeed {
  slow(0.4),
  normal(0.5),
  fast(0.6);

  const NarrationSpeed(this.rate);
  final double rate;
}

/// One spoken chunk. [historySentence] is the index of the sentence in the
/// history text it reads, so the UI can highlight it.
class GuideSegment {
  const GuideSegment(this.text, {this.historySentence});

  final String text;
  final int? historySentence;
}

/// Splits text into sentences, keeping the punctuation.
List<String> splitSentences(String text) => text
    .split(RegExp(r'(?<=[.!?])\s+'))
    .map((s) => s.trim())
    .where((s) => s.isNotEmpty)
    .toList();

/// Narration script for a location: name, short description, then the
/// history one sentence at a time.
List<GuideSegment> narrationFor(Location location) {
  final history = splitSentences(location.history);
  return [
    GuideSegment('${location.name}.'),
    if (location.description.isNotEmpty) GuideSegment(location.description),
    for (var i = 0; i < history.length; i++)
      GuideSegment(history[i], historySentence: i),
  ];
}

/// Plays a narration sentence by sentence. Pausing stops the current
/// sentence; resuming restarts it so speech never starts mid-word.
class AudioGuide extends ChangeNotifier {
  AudioGuide({
    required this.segments,
    required this._createEngine,
    this.languageTag = 'id-ID',
  });

  final List<GuideSegment> segments;
  final String languageTag;
  final SpeechEngine Function() _createEngine;

  SpeechEngine? _engine;
  AudioGuideState _state = AudioGuideState.idle;
  NarrationSpeed _speed = NarrationSpeed.normal;
  int _index = 0;
  bool? _voiceAvailable;

  /// Bumped on every pause/stop so an older playback loop exits.
  int _session = 0;
  bool _disposed = false;

  AudioGuideState get state => _state;
  NarrationSpeed get speed => _speed;
  int get index => _index;
  int get total => segments.length;

  /// False once we know the device lacks a voice for [languageTag].
  bool? get voiceAvailable => _voiceAvailable;

  double get progress => total == 0 ? 0 : _index / total;

  /// History sentence being read, for highlighting; null when idle.
  int? get activeHistorySentence => _state == AudioGuideState.idle
      ? null
      : segments[_index.clamp(0, total - 1)].historySentence;

  Future<SpeechEngine> _ready() async {
    final existing = _engine;
    if (existing != null) return existing;
    final engine = _createEngine();
    _engine = engine;
    _voiceAvailable = await engine.configure(languageTag);
    await engine.setRate(_speed.rate);
    return engine;
  }

  Future<void> play() async {
    if (_state == AudioGuideState.playing || segments.isEmpty) return;
    final session = ++_session;
    _setState(AudioGuideState.playing);
    try {
      final engine = await _ready();
      while (_index < segments.length) {
        if (session != _session) return;
        _notify();
        await engine.speak(segments[_index].text);
        if (session != _session) return;
        _index++;
      }
      _index = 0;
      _setState(AudioGuideState.idle);
    } catch (e) {
      debugPrint('[AudioGuide] $e');
      if (session == _session) _setState(AudioGuideState.idle);
    }
  }

  Future<void> pause() async {
    if (_state != AudioGuideState.playing) return;
    _session++;
    _setState(AudioGuideState.paused);
    await _engine?.stop();
  }

  Future<void> stop() async {
    _session++;
    _index = 0;
    _setState(AudioGuideState.idle);
    await _engine?.stop();
  }

  Future<void> toggle() => _state == AudioGuideState.playing ? pause() : play();

  Future<void> setSpeed(NarrationSpeed speed) async {
    if (speed == _speed) return;
    _speed = speed;
    _notify();
    await _engine?.setRate(speed.rate);
    // Restart the current sentence so the new speed applies immediately.
    if (_state == AudioGuideState.playing) {
      await pause();
      await play();
    }
  }

  void _setState(AudioGuideState state) {
    _state = state;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _session++;
    _engine?.stop();
    super.dispose();
  }
}
