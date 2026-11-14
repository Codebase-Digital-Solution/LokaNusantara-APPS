import '../../domain/entities/cultural_event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_data_source.dart';
import 'guard.dart';

class EventRepositoryImpl implements EventRepository {
  const EventRepositoryImpl(this._remote);
  final EventRemoteDataSource _remote;

  @override
  Future<List<CulturalEvent>> getEvents({
    required DateTime from,
    required DateTime to,
  }) => guard(() => _remote.getEvents(from, to));
}
