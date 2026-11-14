import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetReviewsForLocationUseCase {
  const GetReviewsForLocationUseCase(this._repository);
  final ReviewRepository _repository;

  Future<List<Review>> execute(
    String locationId, {
    int limit = 10,
    int offset = 0,
  }) => _repository.getByLocation(locationId, limit: limit, offset: offset);
}

class GetAverageRatingUseCase {
  const GetAverageRatingUseCase(this._repository);
  final ReviewRepository _repository;

  Future<double> execute(String locationId) =>
      _repository.getAverageRating(locationId);
}

class CreateReviewUseCase {
  const CreateReviewUseCase(this._repository);
  final ReviewRepository _repository;

  Future<Review> execute({
    required String locationId,
    required int rating,
    String comment = '',
  }) {
    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating must be between 1 and 5');
    }
    return _repository.create(
      locationId: locationId,
      rating: rating,
      comment: comment,
    );
  }
}
