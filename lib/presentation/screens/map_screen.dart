import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/utils/category_style.dart';
import '../../core/utils/color_hex.dart';
import '../../core/utils/directions.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/trail.dart';
import '../../domain/usecases/trail_usecases.dart';
import '../providers/location_provider.dart';
import '../navigation/location_navigation.dart';
import '../navigation/map_navigation.dart';
import '../providers/review_provider.dart';
import '../providers/shell_controller.dart';
import '../widgets/category_filter.dart';
import '../widgets/dialogs.dart';
import '../widgets/location_detail.dart';
import '../widgets/location_marker.dart';
import '../widgets/location_search_bar.dart';
import '../theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/kawung_pattern.dart';

const _defaultCenter = LatLng(-8.6705, 115.2126);

/// Rough bounding box of Bali including Nusa Penida. The map only follows the
/// user automatically inside it, so simulators (which default to California)
/// and visitors still abroad keep seeing Bali.
final _baliBounds = LatLngBounds(
  const LatLng(-8.95, 114.40),
  const LatLng(-8.05, 115.75),
);

bool _isInBali(LatLng point) => _baliBounds.contains(point);
const _defaultZoom = 13.5;
const _userZoom = 14.5;
const _searchResultZoom = 15.8;

const _osmTiles = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// The map, opened as its own page through `openMap`. [request] optionally
/// focuses a location (with a route) or draws a trail once the map is ready.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.request});

  final MapFocusRequest? request;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final _mapController = MapController();
  StreamSubscription<Position>? _positionSub;
  bool _mapReady = false;

  LatLng? _userLocation;
  List<LatLng> _route = const [];
  Color _routeColor = defaultCategoryStyle.color;
  bool _routeLoading = false;
  TransportMode _transportMode = TransportMode.driving;

  /// Branded cover shown while the map and places load.
  bool _introDone = false;

  /// Trail currently drawn on the map, if any.
  Trail? _trail;
  List<LatLng> _trailRoute = const [];

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final ShellController _shell = context.read<ShellController>();

  @override
  void initState() {
    super.initState();
    _userLocation = _shell.userLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
    // Keep the cover up briefly so it reads as a transition, not a flicker.
    Future.delayed(const Duration(milliseconds: 900), _maybeFinishIntro);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _pulse.dispose();
    _mapController.dispose();
    super.dispose();
  }

  bool _minIntroElapsed = false;

  /// Hides the loading cover once the map is ready, places have loaded and
  /// the minimum display time has passed.
  void _maybeFinishIntro([bool timer = true]) {
    if (!mounted || _introDone) return;
    if (timer) _minIntroElapsed = true;
    final places = context.read<LocationProvider>();
    final placesReady = !places.loading || places.locations.isNotEmpty;
    if (_minIntroElapsed && _mapReady && placesReady) {
      setState(() => _introDone = true);
    } else {
      // Check again shortly; covers a slow network without a listener.
      Future.delayed(const Duration(milliseconds: 250), () {
        _maybeFinishIntro(false);
      });
    }
  }

  /// Focuses what the page was opened for, once the map can move.
  void _applyRequest() {
    final request = widget.request;
    if (request == null) return;
    final trail = request.trail;
    if (trail != null) {
      _showTrail(trail);
      return;
    }
    final location = request.location!;
    _moveTo(LatLng(location.latitude, location.longitude), _searchResultZoom);
    _selectLocation(location).then((_) {
      if (request.withRoute && mounted) _showRoute(_transportMode);
    });
  }

  Color _trailColor(Trail trail) =>
      colorFromHex(trail.colorHex, fallback: AppColors.terakota);

  /// Draws [trail]: straight segments right away, then the road route once
  /// OSRM answers.
  Future<void> _showTrail(Trail trail) async {
    context.read<LocationProvider>().clearSelection();
    context.read<ReviewProvider>().reset();
    final points = [
      for (final s in trail.stops)
        LatLng(s.location.latitude, s.location.longitude),
    ];
    setState(() {
      _route = const [];
      _trail = trail;
      _trailRoute = points;
    });
    if (_mapReady) {
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: points,
          padding: const EdgeInsets.fromLTRB(48, 190, 48, 200),
        ),
      );
    }
    try {
      final road = await context.read<DirectionsService>().fetchRoute(points);
      if (mounted && _trail == trail && road.isNotEmpty) {
        setState(() => _trailRoute = road);
      }
    } catch (e) {
      debugPrint('[MapScreen] trail route unavailable: $e');
    }
  }

  void _closeTrail() => setState(() {
    _trail = null;
    _trailRoute = const [];
  });

  void _setUserLocation(LatLng here) {
    _shell.userLocation = here;
    setState(() => _userLocation = here);
  }

  Future<void> _initialize() async {
    try {
      if (!await _ensureLocationPermission()) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (!mounted) return;
      final here = LatLng(position.latitude, position.longitude);
      _setUserLocation(here);
      if (_isInBali(here)) _moveTo(here, _userZoom);

      _positionSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              distanceFilter: 10,
            ),
          ).listen(
            (p) {
              if (mounted) {
                _setUserLocation(LatLng(p.latitude, p.longitude));
              }
            },
            onError: (Object e) =>
                debugPrint('[MapScreen] position stream: $e'),
          );
    } catch (e) {
      debugPrint('[MapScreen] location unavailable: $e');
    }
  }

  Future<bool> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  void _moveTo(LatLng center, double zoom) {
    if (_mapReady) _mapController.move(center, zoom);
  }

  void _zoomBy(double delta) {
    if (!_mapReady) return;
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom + delta);
  }

  /// Filters by category, then zooms out so every place in it is in view.
  Future<void> _onSelectCategory(int? categoryId) async {
    final locations = context.read<LocationProvider>();
    await locations.selectCategory(categoryId);
    if (!mounted || !_mapReady || locations.selectedCategory != categoryId) {
      return;
    }
    final points = [
      for (final l in locations.filteredLocations)
        LatLng(l.latitude, l.longitude),
    ];
    if (points.isEmpty) return;
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: EdgeInsets.fromLTRB(
          48,
          MediaQuery.paddingOf(context).top + 90,
          48,
          MediaQuery.paddingOf(context).bottom + 120,
        ),
        // A single place would otherwise zoom all the way in.
        maxZoom: _userZoom,
      ),
    );
  }

  Future<void> _selectLocation(Location location) async {
    context.read<LocationProvider>().selectLocation(location);
    setState(() => _route = const []);
    await context.read<ReviewProvider>().loadForLocation(location.id);
  }

  void _closeDetail() {
    context.read<LocationProvider>().clearSelection();
    context.read<ReviewProvider>().reset();
    setState(() => _route = const []);
  }

  Future<void> _showRoute(TransportMode mode) async {
    final origin = _userLocation;
    final target = context.read<LocationProvider>().selectedLocation;
    if (origin == null || target == null) return;

    setState(() {
      _transportMode = mode;
      _routeLoading = true;
      _routeColor = categoryStyleOf(target.category?.name).color;
    });
    try {
      final coords = await context.read<DirectionsService>().fetchDirections(
        origin,
        LatLng(target.latitude, target.longitude),
        mode: mode,
      );
      if (!mounted) return;
      setState(() => _route = coords);
      if (coords.isEmpty) {
        await showMessageDialog(
          context,
          context.l10n.mapRouteUnavailableTitle,
          context.l10n.mapRouteUnavailableBody,
        );
      } else {
        _mapController.fitCamera(
          CameraFit.coordinates(
            coordinates: coords,
            padding: const EdgeInsets.fromLTRB(40, 140, 40, 420),
          ),
        );
      }
    } catch (e) {
      debugPrint('[MapScreen] route error: $e');
      if (mounted) {
        await showMessageDialog(
          context,
          context.l10n.mapRouteFailedTitle,
          context.l10n.mapRouteFailedBody,
        );
      }
    } finally {
      if (mounted) setState(() => _routeLoading = false);
    }
  }

  void _onSearchChanged(String text) {
    final locations = context.read<LocationProvider>();
    if (text.length > 2) {
      locations.searchLocations(text);
    } else if (text.isEmpty) {
      locations.clearSearch();
    } else {
      locations.setSearchKeyword(text);
    }
  }

  Future<void> _onSearchResult(Location location) async {
    context.read<LocationProvider>().clearSearch();
    _moveTo(LatLng(location.latitude, location.longitude), _searchResultZoom);
    await _selectLocation(location);
  }

  Future<void> _openDetailPage() async {
    final location = context.read<LocationProvider>().selectedLocation;
    if (location == null) return;
    await openLocationDetail(
      context,
      location,
      onRoute: () => _showRoute(_transportMode),
    );
  }

  void _openReview() {
    final location = context.read<LocationProvider>().selectedLocation;
    if (location != null) showReviewFlow(context, location);
  }

  @override
  Widget build(BuildContext context) {
    final locations = context.watch<LocationProvider>();
    final reviews = context.watch<ReviewProvider>();
    final selected = locations.selectedLocation;
    // Another tab may have loaded reviews for a different place meanwhile.
    if (selected != null &&
        reviews.locationId != selected.id &&
        !reviews.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) reviews.loadForLocation(selected.id);
      });
    }
    final visible = locations.filteredLocations;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: _defaultZoom,
              minZoom: 5,
              maxZoom: 19,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onMapReady: () {
                _mapReady = true;
                if (widget.request != null) {
                  _applyRequest();
                } else {
                  final here = _userLocation;
                  if (here != null && _isInBali(here)) {
                    _moveTo(here, _userZoom);
                  }
                }
              },
              onTap: (_, _) => FocusScope.of(context).unfocus(),
            ),
            children: [
              TileLayer(
                urlTemplate: _osmTiles,
                userAgentPackageName: 'id.semotif.mobile',
                maxNativeZoom: 19,
              ),
              if (_trail != null && _trailRoute.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _trailRoute,
                      color: _trailColor(_trail!),
                      strokeWidth: 5,
                      borderColor: Colors.white,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              if (_route.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _route,
                      color: _routeColor,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (final location in visible)
                    Marker(
                      key: ValueKey(location.id),
                      point: LatLng(location.latitude, location.longitude),
                      width: LocationMarker.size,
                      height: LocationMarker.size,
                      child: LocationMarker(
                        location: location,
                        onTap: () => _selectLocation(location),
                      ),
                    ),
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 22,
                      height: 22,
                      child: const _UserDot(),
                    ),
                ],
              ),
              if (_trail != null)
                MarkerLayer(
                  markers: [
                    for (final stop in _trail!.stops)
                      Marker(
                        point: LatLng(
                          stop.location.latitude,
                          stop.location.longitude,
                        ),
                        width: 34,
                        height: 34,
                        child: GestureDetector(
                          onTap: () => _selectLocation(stop.location),
                          child: _TrailStopMarker(
                            number: stop.position,
                            color: _trailColor(_trail!),
                          ),
                        ),
                      ),
                  ],
                ),
              RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          if (_trail != null)
            Positioned(
              top: topInset + 72,
              left: 10,
              right: 10,
              child: _TrailBanner(
                trail: _trail!,
                color: _trailColor(_trail!),
                onClose: _closeTrail,
              ),
            ),

          // Search bar
          Positioned(
            top: topInset + 10,
            left: 10,
            right: 10,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RoundButton(
                  icon: Icons.close_rounded,
                  tooltip: context.l10n.mapClose,
                  margin: const EdgeInsets.only(right: 8, top: 2),
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: LocationSearchBar(
                    value: locations.searchKeyword,
                    onChanged: _onSearchChanged,
                    searching: locations.loading,
                    results: locations.searchKeyword.length > 2
                        ? visible
                        : const [],
                    onSelectResult: _onSearchResult,
                  ),
                ),
              ],
            ),
          ),

          // Map controls
          Positioned(
            right: 16,
            bottom: 220,
            child: Column(
              children: [
                _RoundButton(
                  icon: Icons.my_location,
                  tooltip: context.l10n.mapMyLocation,
                  onTap: () {
                    final here = _userLocation;
                    if (here != null) _moveTo(here, _userZoom);
                  },
                ),
                _RoundButton(
                  icon: Icons.refresh,
                  tooltip: context.l10n.mapReload,
                  onTap: () => locations.fetchLocations(limit: 100),
                ),
                _RoundButton(
                  icon: Icons.add,
                  tooltip: context.l10n.mapZoomIn,
                  onTap: () => _zoomBy(1),
                ),
                _RoundButton(
                  icon: Icons.remove,
                  tooltip: context.l10n.mapZoomOut,
                  onTap: () => _zoomBy(-1),
                ),
              ],
            ),
          ),

          if (locations.loading && _introDone)
            const Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Color(0x33000000),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.terakota),
                  ),
                ),
              ),
            ),

          if (selected != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LocationDetail(
                location: selected,
                reviews: reviews.reviews,
                averageRating: reviews.averageRating,
                loading: reviews.loading,
                userLocation: _userLocation,
                transportMode: _transportMode,
                routeLoading: _routeLoading,
                onRoutePress: _showRoute,
                onReviewPress: _openReview,
                onClosePress: _closeDetail,
                onOpenDetail: _openDetailPage,
              ),
            )
          else
            Positioned(
              left: 0,
              right: 0,
              bottom: 30 + MediaQuery.paddingOf(context).bottom,
              child: CategoryFilter(
                categories: locations.categories,
                selectedCategory: locations.selectedCategory,
                onSelectCategory: _onSelectCategory,
              ),
            ),

          // Loading cover: fades away once the map is ready.
          Positioned.fill(
            child: IgnorePointer(
              ignoring: _introDone,
              child: AnimatedOpacity(
                opacity: _introDone ? 0 : 1,
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOut,
                child: _MapLoadingCover(pulse: _pulse),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.margin = const EdgeInsets.only(bottom: 8),
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 4,
          shadowColor: Colors.black45,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: 44,
              child: Icon(icon, size: 22, color: const Color(0xFF374151)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen cover shown while the map opens: brand gradient, kawung
/// texture and a breathing logo.
class _MapLoadingCover extends StatelessWidget {
  const _MapLoadingCover({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.terakota, AppColors.sogan],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: KawungPattern(color: Color(0x1AF6D98A), tileSize: 72),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: Tween(begin: 0.9, end: 1.06).animate(
                  CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
                ),
                child: SvgPicture.asset(
                  'assets/brand/logo_mark.svg',
                  height: 88,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                context.l10n.mapPreparing,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.mapLoadingNearby,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    color: AppColors.pradaLight,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x553B82F6), blurRadius: 8, spreadRadius: 4),
        ],
      ),
    );
  }
}

class _TrailStopMarker extends StatelessWidget {
  const _TrailStopMarker({required this.number, required this.color});

  final int number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TrailBanner extends StatelessWidget {
  const _TrailBanner({
    required this.trail,
    required this.color,
    required this.onClose,
  });

  final Trail trail;
  final Color color;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final km = trailDistanceKm(trail);
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trail.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    context.l10n.mapTrailSummary(
                      trail.stops.length,
                      km.round(),
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: context.l10n.mapCloseTrail,
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
