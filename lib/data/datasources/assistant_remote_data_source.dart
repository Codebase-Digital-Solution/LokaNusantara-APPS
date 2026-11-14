import '../../core/api/api_client.dart';
import '../../domain/entities/assistant_message.dart';
import '../models/models.dart';

class AssistantRemoteDataSource {
  const AssistantRemoteDataSource(this._api);
  final ApiClient _api;

  Future<ChatMessage> ask(String question, List<ChatMessage> history) async {
    final res = await _api.post(
      '/assistant/ask',
      data: {
        'question': question,
        'history': [
          for (final m in history)
            {
              'role': m.role == ChatRole.user ? 'user' : 'assistant',
              'content': m.text,
            },
        ],
      },
      // The model can take a while; the server itself gives up after 90s.
      timeout: const Duration(seconds: 95),
    );
    final json = res as Json;
    final locations = json['locations'];
    return ChatMessage(
      role: ChatRole.assistant,
      text: (json['answer'] ?? '').toString(),
      locations: locations is List
          ? locations.whereType<Json>().map(LocationModel.fromJson).toList()
          : const [],
    );
  }
}
