import 'dart:async';

import 'package:bali_guide_map/domain/entities/assistant_message.dart';
import 'package:bali_guide_map/domain/entities/cultural_event.dart';
import 'package:bali_guide_map/domain/repositories/assistant_repository.dart';
import 'package:bali_guide_map/domain/usecases/assistant_usecases.dart';
import 'package:bali_guide_map/presentation/providers/tanya_loka_provider.dart';
import 'package:bali_guide_map/presentation/screens/notifications_screen.dart';
import 'package:bali_guide_map/presentation/screens/tanya_loka_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../fakes.dart';

/// Answers only when [complete] is called, to test late answers.
class _SlowAssistant implements AssistantRepository {
  final asked = <String>[];
  Completer<ChatMessage>? pending;

  @override
  Future<ChatMessage> ask(String question, List<ChatMessage> history) {
    asked.add(question);
    return (pending = Completer<ChatMessage>()).future;
  }

  void complete(String text) =>
      pending!.complete(ChatMessage(role: ChatRole.assistant, text: text));
}

void main() {
  test('an answer to a chat that was reset is dropped', () async {
    final repo = _SlowAssistant();
    final chat = TanyaLokaProvider(ask: AskLokaUseCase(repo));
    final sent = chat.send('Tentang Pura A?');
    chat.reset(); // user opened another place meanwhile
    repo.complete('Jawaban untuk Pura A');
    expect(await sent, isFalse);
    expect(chat.messages, isEmpty);
    expect(chat.sending, isFalse);
  });

  testWidgets('asking about a place starts a fresh chat and sends at once', (
    tester,
  ) async {
    final repo = _SlowAssistant();
    final chat = TanyaLokaProvider(ask: AskLokaUseCase(repo));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: chat,
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => openTanyaLokaAbout(context, loc('9')),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    // An old conversation from another place.
    final old = chat.send('Pertanyaan lama');
    repo.complete('Jawaban lama');
    await old;
    expect(chat.messages, hasLength(2));

    await tester.tap(find.text('open'));
    // The typing indicator animates while waiting, so pump a fixed time.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(repo.asked.last, contains('Place 9'));
    expect(chat.messages.single.text, contains('Place 9'));
    expect(find.text('Pertanyaan lama'), findsNothing);

    repo.complete('Ini cerita tentang Place 9.');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Ini cerita tentang Place 9.'), findsOneWidget);
  });

  test(
    'notifications list events from today up to the window, soonest first',
    () {
      final now = DateTime(2026, 11, 12, 15);
      CulturalEvent ev(int id, DateTime start, [DateTime? end]) =>
          CulturalEvent(
            id: id,
            name: 'E$id',
            description: '',
            category: 'pura',
            startDate: start,
            endDate: end,
          );
      final events = [
        ev(1, DateTime(2026, 11, 20)),
        ev(2, DateTime(2026, 11, 1)), // already over
        ev(3, DateTime(2026, 11, 10), DateTime(2026, 11, 13)), // ongoing
        ev(4, DateTime(2026, 12, 30)), // too far
        ev(5, DateTime(2026, 11, 12)), // today
      ];
      expect(upcomingEvents(events, now: now).map((e) => e.id), [3, 5, 1]);
      expect(upcomingEvents(events, days: 1, now: now).map((e) => e.id), [
        3,
        5,
      ]);
    },
  );
}
