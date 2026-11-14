import '../entities/cultural_event.dart';
import '../repositories/event_repository.dart';

/// Events that have not ended yet, within the coming [days].
class GetUpcomingEventsUseCase {
  const GetUpcomingEventsUseCase(this._repository);
  final EventRepository _repository;

  Future<List<CulturalEvent>> execute({DateTime? today, int days = 400}) {
    final now = today ?? DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    return _repository.getEvents(
      from: from,
      to: from.add(Duration(days: days)),
    );
  }
}
