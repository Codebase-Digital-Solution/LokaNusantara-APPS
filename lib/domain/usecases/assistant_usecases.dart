import '../entities/assistant_message.dart';
import '../repositories/assistant_repository.dart';

class AskLokaUseCase {
  const AskLokaUseCase(this._repository);
  final AssistantRepository _repository;

  static const maxQuestionLength = 500;

  Future<ChatMessage> execute(String question, List<ChatMessage> history) {
    final q = question.trim();
    if (q.isEmpty) throw ArgumentError('Tulis pertanyaanmu terlebih dahulu');
    if (q.length > maxQuestionLength) {
      throw ArgumentError('Pertanyaan maksimal $maxQuestionLength karakter');
    }
    return _repository.ask(q, history);
  }
}
