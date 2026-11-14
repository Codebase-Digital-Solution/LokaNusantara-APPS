import '../../domain/entities/assistant_message.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../datasources/assistant_remote_data_source.dart';
import 'guard.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  const AssistantRepositoryImpl(this._remote);
  final AssistantRemoteDataSource _remote;

  @override
  Future<ChatMessage> ask(String question, List<ChatMessage> history) =>
      guard(() => _remote.ask(question, history));
}
