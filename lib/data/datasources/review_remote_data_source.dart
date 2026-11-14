import '../../core/api/api_client.dart';
import '../../domain/entities/review.dart';
import '../models/models.dart';

class ReviewRemoteDataSource {
  const ReviewRemoteDataSource(this._api);
  final ApiClient _api;

  Future<List<Review>> getByLocation(
    String locationId,
    int limit,
    int offset,
  ) async {
    final res = await _api.get(
      '/locations/$locationId/reviews',
      query: {'limit': limit, 'offset': offset},
    );
    return dataList(res).map(ReviewModel.fromJson).toList();
  }

  Future<double> getAverageRating(String locationId) async {
    final res = await _api.get('/locations/$locationId/reviews/rating');
    final value = res is Map ? res['average_rating'] : null;
    return value is num ? value.toDouble() : 0;
  }

  Future<Review> create(String locationId, int rating, String comment) async {
    final res = await _api.post(
      '/reviews',
      data: {'location_id': locationId, 'rating': rating, 'comment': comment},
    );
    return ReviewModel.fromJson(res as Json);
  }
}
