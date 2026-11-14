import '../entities/cultural_event.dart';

abstract interface class EventRepository {
  Future<List<CulturalEvent>> getEvents({
    required DateTime from,
    required DateTime to,
  });
}
