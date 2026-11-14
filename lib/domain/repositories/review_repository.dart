import '../entities/review.dart';

abstract interface class ReviewRepository {
  Future<List<Review>> getByLocation(
    String locationId, {
    required int limit,
    required int offset,
  });
  Future<double> getAverageRating(String locationId);
  Future<Review> create({
    required String locationId,
    required int rating,
    required String comment,
  });
}
