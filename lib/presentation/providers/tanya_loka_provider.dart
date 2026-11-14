import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/error/errors.dart';
import '../../domain/entities/assistant_message.dart';
import '../../domain/usecases/assistant_usecases.dart';

/// Conversation state for Tanya Loka. Each place starts a fresh chat through
/// [reset]; an answer to a chat that was reset meanwhile is dropped.
class TanyaLokaProvider extends ChangeNotifier {
  TanyaLokaProvider({required this._ask});

  final AskLokaUseCase _ask;

  final List<ChatMessage> _messages = [];
  bool _sending = false;
  AppError? _error;

  /// Bumped by [reset] so a late answer cannot land in a newer chat.
  int _generation = 0;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get sending => _sending;
  AppError? get error => _error;

  /// Returns true when an answer arrived for the current chat.
  Future<bool> send(String question) async {
    final q = question.trim();
    if (q.isEmpty || _sending) return false;
    final generation = _generation;
    final history = List<ChatMessage>.of(_messages);
    _messages.add(ChatMessage(role: ChatRole.user, text: q));
    _sending = true;
    _error = null;
    notifyListeners();
    try {
      final answer = await _ask.execute(q, history);
      if (generation != _generation) return false;
      _messages.add(answer);
      return true;
    } catch (e) {
      if (generation != _generation) return false;
      // Drop the unanswered question so history keeps alternating roles.
      _messages.removeLast();
      _error = handleError(e);
      return false;
    } finally {
      if (generation == _generation) _sending = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Starts an empty chat, abandoning any answer still on its way.
  void reset() {
    _generation++;
    _messages.clear();
    _sending = false;
    _error = null;
    notifyListeners();
  }
}
