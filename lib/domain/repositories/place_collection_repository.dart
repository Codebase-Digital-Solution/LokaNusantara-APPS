import '../entities/location.dart';

/// Locations kept on this device. Recently viewed lives here; saved places
/// now live on the server (`BookmarkRepository`), and the device copy only
/// holds bookmarks from older versions until they are uploaded.
abstract interface class PlaceCollectionRepository {
  Future<List<Location>> getSaved();
  Future<void> setSaved(List<Location> places);
  Future<List<Location>> getRecent();
  Future<void> setRecent(List<Location> places);
}
