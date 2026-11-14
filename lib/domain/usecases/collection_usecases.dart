import '../entities/location.dart';
import '../repositories/bookmark_repository.dart';
import '../repositories/place_collection_repository.dart';

/// Loads the signed-in user's saved places from the server. Bookmarks made
/// before saving moved to the account (kept on the device) are uploaded once
/// and then removed from the device.
class LoadSavedPlacesUseCase {
  const LoadSavedPlacesUseCase(this._bookmarks, this._device);
  final BookmarkRepository _bookmarks;
  final PlaceCollectionRepository _device;

  Future<List<Location>> execute() async {
    final legacy = await _device.getSaved();
    if (legacy.isNotEmpty) {
      // Oldest first, so the server keeps the original newest-first order.
      for (final place in legacy.reversed) {
        try {
          await _bookmarks.add(place.id);
        } catch (_) {
          // The place may have been deleted since; skip it.
        }
      }
      await _device.setSaved(const []);
    }
    return _bookmarks.getAll();
  }
}

/// Saves or unsaves a place on the server.
class ToggleSavedPlaceUseCase {
  const ToggleSavedPlaceUseCase(this._bookmarks);
  final BookmarkRepository _bookmarks;

  Future<void> execute(Location place, {required bool save}) =>
      save ? _bookmarks.add(place.id) : _bookmarks.remove(place.id);
}

/// Moves [place] to the front of the recently viewed list, keeping at most
/// [maxItems] entries. Returns the new list.
class RecordRecentPlaceUseCase {
  const RecordRecentPlaceUseCase(this._repository, {this.maxItems = 30});
  final PlaceCollectionRepository _repository;
  final int maxItems;

  Future<List<Location>> execute(List<Location> current, Location place) async {
    final next = [
      place,
      ...current.where((p) => p.id != place.id),
    ].take(maxItems).toList();
    await _repository.setRecent(next);
    return next;
  }
}
