import '../entities/trail.dart';

abstract interface class TrailRepository {
  Future<List<Trail>> getTrails();
}
