import '../entities/assistant_message.dart';

abstract interface class AssistantRepository {
  /// Asks [question] with the earlier [history]; returns the reply.
  Future<ChatMessage> ask(String question, List<ChatMessage> history);
}
