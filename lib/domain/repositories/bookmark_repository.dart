import '../entities/location.dart';

/// The signed-in user's saved places, stored on the server per account.
abstract interface class BookmarkRepository {
  Future<List<Location>> getAll();
  Future<void> add(String locationId);
  Future<void> remove(String locationId);
}
