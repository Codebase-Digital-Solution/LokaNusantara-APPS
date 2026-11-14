import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/error/errors.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/location.dart';
import '../../domain/usecases/category_usecases.dart';
import '../../domain/usecases/location_usecases.dart';

class LocationProvider extends ChangeNotifier {
  LocationProvider({
    required this._getLocations,
    required this._getLocationsByCategory,
    required this._searchLocations,
    required this._getNearbyLocations,
    required this._getCategories,
  });

  final GetLocationsUseCase _getLocations;
  final GetLocationsByCategoryUseCase _getLocationsByCategory;
  final SearchLocationsUseCase _searchLocations;
  final GetNearbyLocationsUseCase _getNearbyLocations;
  final GetCategoriesUseCase _getCategories;

  List<Location> _locations = const [];
  List<Location> _filteredLocations = const [];
  Location? _selectedLocation;
  List<Category> _categories = const [];
  int? _selectedCategory;
  bool _loading = false;
  AppError? _error;
  String _searchKeyword = '';

  /// Incremented per filtering request so stale responses are dropped.
  int _requestSeq = 0;

  List<Location> get locations => _locations;
  List<Location> get filteredLocations => _filteredLocations;
  Location? get selectedLocation => _selectedLocation;
  List<Category> get categories => _categories;
  int? get selectedCategory => _selectedCategory;
  bool get loading => _loading;
  AppError? get error => _error;
  String get searchKeyword => _searchKeyword;

  Future<void> fetchLocations({int limit = 20, int offset = 0}) =>
      _load(() => _getLocations.execute(limit: limit, offset: offset), (data) {
        _locations = data;
        _filteredLocations = data;
      });

  Future<void> fetchLocationsByCategory(
    int categoryId, {
    int limit = 20,
    int offset = 0,
  }) => _load(
    () => _getLocationsByCategory.execute(
      categoryId,
      limit: limit,
      offset: offset,
    ),
    (data) => _filteredLocations = data,
  );

  Future<void> searchLocations(
    String keyword, {
    int limit = 20,
    int offset = 0,
  }) {
    _searchKeyword = keyword;
    return _load(
      () => _searchLocations.execute(keyword, limit: limit, offset: offset),
      (data) => _filteredLocations = data,
    );
  }

  Future<void> fetchNearbyLocations(
    double latitude,
    double longitude, {
    double radiusKm = 5,
  }) => _load(
    () => _getNearbyLocations.execute(latitude, longitude, radiusKm: radiusKm),
    (data) => _filteredLocations = data,
  );

  Future<void> fetchCategories({int limit = 10, int offset = 0}) async {
    _error = null;
    try {
      _categories = await _getCategories.execute(limit: limit, offset: offset);
    } catch (e) {
      _error = handleError(e);
    }
    notifyListeners();
  }

  Future<void> selectCategory(int? categoryId) async {
    _selectedCategory = categoryId;
    if (categoryId != null) {
      await fetchLocationsByCategory(categoryId);
    } else {
      _requestSeq++;
      _filteredLocations = _locations;
      notifyListeners();
    }
  }

  void selectLocation(Location location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  /// Clears the search text and restores the full list, keeping the selection.
  void clearSearch() {
    _requestSeq++;
    _searchKeyword = '';
    _filteredLocations = _locations;
    notifyListeners();
  }

  void clearSelection() {
    _requestSeq++;
    _selectedLocation = null;
    _selectedCategory = null;
    _searchKeyword = '';
    _filteredLocations = _locations;
    notifyListeners();
  }

  Future<void> _load(
    Future<List<Location>> Function() request,
    void Function(List<Location> data) apply,
  ) async {
    final seq = ++_requestSeq;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await request();
      if (seq == _requestSeq) apply(data);
    } catch (e) {
      if (seq == _requestSeq) _error = handleError(e);
    } finally {
      if (seq == _requestSeq) _loading = false;
      notifyListeners();
    }
  }
}
