import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

enum TransportMode { driving, walking, cycling }

/// Free routing via public OSRM servers, no API key required.
class DirectionsService {
  DirectionsService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              // OSRM answers NoRoute with a 4xx; read the body instead of throwing.
              validateStatus: (_) => true,
            ),
          );

  final Dio _dio;

  static const _profiles = {
    TransportMode.driving: 'https://router.project-osrm.org/route/v1/driving',
    TransportMode.walking:
        'https://routing.openstreetmap.de/routed-foot/route/v1/foot',
    TransportMode.cycling:
        'https://routing.openstreetmap.de/routed-bike/route/v1/bike',
  };

  /// Returns the route polyline, or an empty list when no route exists.
  Future<List<LatLng>> fetchDirections(
    LatLng origin,
    LatLng destination, {
    TransportMode mode = TransportMode.driving,
  }) => fetchRoute([origin, destination], mode: mode);

  /// Route through every point in order (at least two). Returns an empty list
  /// when no route exists.
  Future<List<LatLng>> fetchRoute(
    List<LatLng> points, {
    TransportMode mode = TransportMode.driving,
  }) async {
    if (points.length < 2) return [];
    final waypoints = points
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');
    final url =
        '${_profiles[mode]}/$waypoints?overview=full&geometries=geojson';

    final response = await _dio.get<dynamic>(url);
    final data = response.data;
    if (data is! Map) {
      throw Exception('OSRM error: HTTP ${response.statusCode}');
    }

    final routes = data['routes'];
    if (data['code'] == 'NoRoute' || routes is! List || routes.isEmpty) {
      return [];
    }
    if (data['code'] != 'Ok') {
      throw Exception('OSRM error: ${data['code']}');
    }

    // GeoJSON coordinates are [longitude, latitude].
    final coords = routes.first['geometry']['coordinates'] as List;
    return [
      for (final c in coords)
        LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
    ];
  }
}
