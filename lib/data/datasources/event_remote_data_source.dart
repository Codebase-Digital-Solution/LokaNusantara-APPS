import '../../core/api/api_client.dart';
import '../../domain/entities/cultural_event.dart';
import '../models/models.dart';

class EventRemoteDataSource {
  const EventRemoteDataSource(this._api);
  final ApiClient _api;

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<List<CulturalEvent>> getEvents(DateTime from, DateTime to) async {
    final res = await _api.get(
      '/events',
      query: {'from': _date(from), 'to': _date(to), 'limit': 200},
    );
    return dataList(res).map(EventModel.fromJson).toList();
  }
}
