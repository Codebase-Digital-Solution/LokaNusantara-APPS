import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/error/errors.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/review_usecases.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewProvider({
    required this._getReviews,
    required this._getAverageRating,
    required this._createReview,
  });

  final GetReviewsForLocationUseCase _getReviews;
  final GetAverageRatingUseCase _getAverageRating;
  final CreateReviewUseCase _createReview;

  List<Review> _reviews = const [];
  double _averageRating = 0;
  bool _loading = false;
  AppError? _error;
  String? _locationId;

  List<Review> get reviews => _reviews;
  double get averageRating => _averageRating;
  bool get loading => _loading;
  AppError? get error => _error;

  /// The location whose reviews are currently loaded.
  String? get locationId => _locationId;

  /// Loads reviews and the average rating for [locationId].
  Future<void> loadForLocation(String locationId) async {
    _locationId = locationId;
    _reviews = const [];
    _averageRating = 0;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _getReviews.execute(locationId),
        _getAverageRating.execute(locationId),
      ]);
      if (_locationId != locationId) return;
      _reviews = results[0] as List<Review>;
      _averageRating = results[1] as double;
    } catch (e) {
      if (_locationId == locationId) _error = handleError(e);
    } finally {
      if (_locationId == locationId) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  /// Returns true on success; on failure [error] holds the reason.
  Future<bool> createReview({
    required String locationId,
    required int rating,
    required String comment,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _createReview.execute(
        locationId: locationId,
        rating: rating,
        comment: comment,
      );
    } catch (e) {
      _error = handleError(e);
      _loading = false;
      notifyListeners();
      return false;
    }
    await loadForLocation(locationId);
    return true;
  }

  void reset() {
    _locationId = null;
    _reviews = const [];
    _averageRating = 0;
    _loading = false;
    _error = null;
    notifyListeners();
  }
}
