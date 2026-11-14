import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';
import 'guard.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  const ReviewRepositoryImpl(this._remote);
  final ReviewRemoteDataSource _remote;

  @override
  Future<List<Review>> getByLocation(
    String locationId, {
    required int limit,
    required int offset,
  }) => guard(() => _remote.getByLocation(locationId, limit, offset));

  @override
  Future<double> getAverageRating(String locationId) =>
      guard(() => _remote.getAverageRating(locationId));

  @override
  Future<Review> create({
    required String locationId,
    required int rating,
    required String comment,
  }) => guard(() => _remote.create(locationId, rating, comment));
}
