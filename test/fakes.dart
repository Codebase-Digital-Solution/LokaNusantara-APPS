import 'package:bali_guide_map/core/error/errors.dart';
import 'package:bali_guide_map/domain/entities/category.dart';
import 'package:bali_guide_map/domain/entities/location.dart';
import 'package:bali_guide_map/domain/entities/review.dart';
import 'package:bali_guide_map/domain/entities/auth_session.dart';
import 'package:bali_guide_map/domain/entities/user.dart';
import 'package:bali_guide_map/domain/repositories/auth_repository.dart';
import 'package:bali_guide_map/domain/repositories/bookmark_repository.dart';
import 'package:bali_guide_map/domain/repositories/category_repository.dart';
import 'package:bali_guide_map/domain/repositories/location_repository.dart';
import 'package:bali_guide_map/domain/repositories/review_repository.dart';

Location loc(
  String id, {
  double lat = -8.65,
  double lng = 115.2,
  String category = 'wisata',
}) => Location(
  id: id,
  name: 'Place $id',
  description: '',
  latitude: lat,
  longitude: lng,
  address: '',
  categoryId: 1,
  category: Category(id: 1, name: category),
);

class FakeLocationRepository implements LocationRepository {
  List<Location> all = [loc('1'), loc('2')];
  List<Location> byCategory = [loc('3')];
  List<Location> searchResult = [loc('4')];
  AppError? failWith;
  String? lastKeyword;

  Future<T> _maybeFail<T>(T value) async {
    if (failWith != null) throw failWith!;
    return value;
  }

  @override
  Future<List<Location>> getAll({required int limit, required int offset}) =>
      _maybeFail(all);

  @override
  Future<Location> getById(String id) => _maybeFail(all.first);

  @override
  Future<List<Location>> getByCategory(
    int categoryId, {
    required int limit,
    required int offset,
  }) => _maybeFail(byCategory);

  @override
  Future<List<Location>> search(
    String keyword, {
    required int limit,
    required int offset,
  }) {
    lastKeyword = keyword;
    return _maybeFail(searchResult);
  }

  @override
  Future<List<Location>> getNearby(
    double latitude,
    double longitude,
    double radiusKm,
  ) => _maybeFail(all);
}

class FakeCategoryRepository implements CategoryRepository {
  @override
  Future<List<Category>> getAll({
    required int limit,
    required int offset,
  }) async => const [
    Category(id: 1, name: 'wisata'),
    Category(id: 2, name: 'hotel'),
  ];
}

class FakeReviewRepository implements ReviewRepository {
  final reviews = <Review>[];
  AppError? createError;

  @override
  Future<List<Review>> getByLocation(
    String locationId, {
    required int limit,
    required int offset,
  }) async => reviews.where((r) => r.locationId == locationId).toList();

  @override
  Future<double> getAverageRating(String locationId) async {
    final list = reviews.where((r) => r.locationId == locationId).toList();
    if (list.isEmpty) return 0;
    return list.map((r) => r.rating).reduce((a, b) => a + b) / list.length;
  }

  @override
  Future<Review> create({
    required String locationId,
    required int rating,
    required String comment,
  }) async {
    if (createError != null) throw createError!;
    final review = Review(
      id: reviews.length + 1,
      userId: 'u1',
      locationId: locationId,
      rating: rating,
      comment: comment,
    );
    reviews.add(review);
    return review;
  }
}

/// In-memory server-side bookmarks. Keeps newest first like the API.
class FakeBookmarkRepository implements BookmarkRepository {
  final List<Location> places = [];
  final Map<String, Location> known = {};
  AppError? failWith;
  int getAllCalls = 0;

  @override
  Future<List<Location>> getAll() async {
    getAllCalls++;
    if (failWith != null) throw failWith!;
    return List.of(places);
  }

  @override
  Future<void> add(String locationId) async {
    if (failWith != null) throw failWith!;
    if (places.any((p) => p.id == locationId)) return;
    places.insert(0, known[locationId] ?? loc(locationId));
  }

  @override
  Future<void> remove(String locationId) async {
    if (failWith != null) throw failWith!;
    places.removeWhere((p) => p.id == locationId);
  }
}

/// Auth that is already signed in as [user] (or signed out when null).
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.user});
  User? user;

  AuthSession? get _session =>
      user == null ? null : AuthSession(user: user!, token: 't');

  @override
  Future<AuthSession?> restoreSession() async => _session;

  @override
  Future<AuthSession?> loginWithGoogle() async => _session;

  @override
  Future<void> logout() async => user = null;
}
