import 'dart:async';

import 'package:bali_guide_map/core/audio/speech_engine.dart';
import 'package:bali_guide_map/domain/entities/location.dart';
import 'package:bali_guide_map/presentation/providers/audio_guide.dart';
import 'package:flutter_test/flutter_test.dart';

/// Speaks instantly unless [hold] is set, in which case each sentence waits
/// until released or stopped.
class FakeSpeech implements SpeechEngine {
  final spoken = <String>[];
  final rates = <double>[];
  bool hold = false;
  bool hasVoice = true;
  Completer<void>? _current;

  @override
  Future<bool> configure(String languageTag) async => hasVoice;

  @override
  Future<void> setRate(double rate) async => rates.add(rate);

  @override
  Future<void> speak(String text) {
    spoken.add(text);
    if (!hold) return Future.value();
    _current = Completer<void>();
    return _current!.future;
  }

  void finishSentence() => _current?.complete();

  @override
  Future<void> stop() async {
    final c = _current;
    _current = null;
    if (c != null && !c.isCompleted) c.complete();
  }
}

const _place = Location(
  id: 'x',
  name: 'Pura Tanah Lot',
  description: 'Pura di atas karang.',
  latitude: 0,
  longitude: 0,
  address: '',
  categoryId: 1,
  history: 'Kalimat satu. Kalimat dua! Kalimat tiga?',
);

void main() {
  test('splitSentences keeps punctuation', () {
    expect(splitSentences('A satu. B dua!  C tiga?'), [
      'A satu.',
      'B dua!',
      'C tiga?',
    ]);
  });

  test('narration reads name, description, then each history sentence', () {
    final segments = narrationFor(_place);
    expect(segments.map((s) => s.text), [
      'Pura Tanah Lot.',
      'Pura di atas karang.',
      'Kalimat satu.',
      'Kalimat dua!',
      'Kalimat tiga?',
    ]);
    expect(segments.map((s) => s.historySentence), [null, null, 0, 1, 2]);
  });

  test('plays to the end and returns to idle', () async {
    final engine = FakeSpeech();
    final guide = AudioGuide(
      segments: narrationFor(_place),
      createEngine: () => engine,
    );
    await guide.play();
    expect(engine.spoken, hasLength(5));
    expect(guide.state, AudioGuideState.idle);
    expect(guide.index, 0);
  });

  test('pause keeps the position and resume repeats that sentence', () async {
    final engine = FakeSpeech()..hold = true;
    final guide = AudioGuide(
      segments: narrationFor(_place),
      createEngine: () => engine,
    );
    unawaited(guide.play());
    await pumpEventQueue();
    engine.finishSentence(); // name
    await pumpEventQueue();
    engine.finishSentence(); // description
    await pumpEventQueue();
    expect(guide.activeHistorySentence, 0);

    await guide.pause();
    expect(guide.state, AudioGuideState.paused);
    expect(guide.activeHistorySentence, 0);

    engine.hold = false;
    await guide.play();
    expect(engine.spoken.where((s) => s == 'Kalimat satu.'), hasLength(2));
    expect(guide.state, AudioGuideState.idle);
  });

  test('speed change is applied to the engine', () async {
    final engine = FakeSpeech();
    final guide = AudioGuide(
      segments: narrationFor(_place),
      createEngine: () => engine,
    );
    await guide.play();
    await guide.setSpeed(NarrationSpeed.fast);
    expect(engine.rates.last, NarrationSpeed.fast.rate);
  });

  test('reports a missing Indonesian voice', () async {
    final engine = FakeSpeech()..hasVoice = false;
    final guide = AudioGuide(
      segments: narrationFor(_place),
      createEngine: () => engine,
    );
    await guide.play();
    expect(guide.voiceAvailable, isFalse);
  });
}
