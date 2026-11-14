import '../../core/api/api_client.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/cultural_event.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/saved_plan.dart';
import '../../domain/entities/trail.dart';
import '../../domain/entities/trip_plan.dart';
import '../../domain/entities/user.dart';

typedef Json = Map<String, dynamic>;

double _toDouble(Object? v) =>
    v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int _toInt(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
String _toStr(Object? v) => v?.toString() ?? '';

class CategoryModel {
  static Category fromJson(Json json) =>
      Category(id: _toInt(json['id']), name: _toStr(json['name']));
}

class UserModel {
  static User fromJson(Json json) => User(
    id: _toStr(json['id']),
    name: _toStr(json['name']),
    email: _toStr(json['email']),
    avatarUrl: ApiClient.resolveMediaUrl(json['avatar_url'] as String?),
  );

  static Json toJson(User user) => {
    'id': user.id,
    'name': user.name,
    'email': user.email,
    if (user.avatarUrl != null) 'avatar_url': user.avatarUrl,
  };
}

class AuthSessionModel {
  /// Parses the API `AuthResponse` shape: `{id, name, email, token}`.
  static AuthSession fromJson(Json json) =>
      AuthSession(user: UserModel.fromJson(json), token: _toStr(json['token']));
}

class LocationModel {
  static Location fromJson(Json json) {
    final category = json['category'];
    return Location(
      id: _toStr(json['id']),
      name: _toStr(json['name']),
      description: _toStr(json['description']),
      history: _toStr(json['history']),
      imageUrl: ApiClient.resolveMediaUrl(json['image_url'] as String?),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      address: _toStr(json['address']),
      categoryId: _toInt(json['category_id']),
      category: category is Map<String, dynamic>
          ? CategoryModel.fromJson(category)
          : null,
    );
  }
}

extension LocationJson on Location {
  /// Serialises the fields needed to show a location offline (saved places,
  /// recently viewed).
  Json toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'history': history,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'category_id': categoryId,
    if (category != null)
      'category': {'id': category!.id, 'name': category!.name},
    if (imageUrl != null) 'image_url': imageUrl,
  };
}

class ReviewModel {
  static Review fromJson(Json json) {
    final user = json['user'];
    return Review(
      id: _toInt(json['id']),
      userId: _toStr(json['user_id']),
      locationId: _toStr(json['location_id']),
      rating: _toInt(json['rating']),
      comment: _toStr(json['comment']),
      user: user is Map<String, dynamic> && _toStr(user['id']).isNotEmpty
          ? UserModel.fromJson(user)
          : null,
      createdAt: DateTime.tryParse(_toStr(json['created_at'])),
    );
  }
}

/// Extracts the `data` list from a paginated response.
List<Json> dataList(dynamic response) {
  final data = response is Map ? response['data'] : null;
  if (data is! List) return const [];
  return data.whereType<Json>().toList();
}

class EventModel {
  /// Parses a "YYYY-MM-DD" date as local midnight; null when missing.
  static DateTime? _date(Object? v) {
    final text = v?.toString() ?? '';
    if (text.length < 10) return null;
    final parsed = DateTime.tryParse(text.substring(0, 10));
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }

  static CulturalEvent fromJson(Json json) {
    final location = json['location'];
    return CulturalEvent(
      id: _toInt(json['id']),
      name: _toStr(json['name']),
      description: _toStr(json['description']),
      category: _toStr(json['category']).toLowerCase(),
      startDate: _date(json['start_date']) ?? DateTime(1970),
      endDate: _date(json['end_date']),
      isEstimate: json['is_estimate'] == true,
      region: _toStr(json['region']),
      location:
          location is Map<String, dynamic> && _toStr(location['id']).isNotEmpty
          ? LocationModel.fromJson(location)
          : null,
    );
  }
}

class TrailModel {
  static Trail fromJson(Json json) {
    final stops = <TrailStop>[];
    final rawStops = json['stops'];
    if (rawStops is List) {
      for (final raw in rawStops.whereType<Json>()) {
        final location = raw['location'];
        if (location is! Map<String, dynamic>) continue;
        stops.add(
          TrailStop(
            position: _toInt(raw['position']),
            note: _toStr(raw['note']),
            location: LocationModel.fromJson(location),
          ),
        );
      }
    }
    stops.sort((a, b) => a.position.compareTo(b.position));
    return Trail(
      id: _toInt(json['id']),
      slug: _toStr(json['slug']),
      title: _toStr(json['title']),
      subtitle: _toStr(json['subtitle']),
      story: _toStr(json['story']),
      colorHex: _toStr(json['color']),
      stops: stops,
      imageUrl: ApiClient.resolveMediaUrl(json['image_url'] as String?),
    );
  }
}

class TripPlanModel {
  /// The planner's JSON shape, used to save a plan to the account.
  static Json toJson(TripPlan plan) => {
    'summary': plan.summary,
    'budget': plan.budget,
    'people': plan.people,
    'days': plan.days,
    'total_estimate': plan.totalEstimate,
    'per_person_estimate': plan.perPersonEstimate,
    'within_budget': plan.withinBudget,
    'budget_note': plan.budgetNote,
    'costs': [
      for (final c in plan.costs)
        {
          'category': c.category,
          'item': c.item,
          'amount': c.amount,
          'note': c.note,
        },
    ],
    'itinerary': [
      for (final s in plan.itinerary)
        {
          'day': s.day,
          'time': s.time,
          'activity': s.activity,
          if (s.location != null) 'location_id': s.location!.id,
          if (s.location != null) 'location': s.location!.toJson(),
        },
    ],
    'tips': plan.tips,
  };

  static TripPlan fromJson(Json json) {
    List<Json> list(Object? v) =>
        v is List ? v.whereType<Json>().toList() : const [];
    return TripPlan(
      summary: _toStr(json['summary']),
      budget: _toInt(json['budget']),
      people: _toInt(json['people']),
      days: _toInt(json['days']),
      totalEstimate: _toInt(json['total_estimate']),
      perPersonEstimate: _toInt(json['per_person_estimate']),
      withinBudget: json['within_budget'] == true,
      budgetNote: _toStr(json['budget_note']),
      costs: [
        for (final c in list(json['costs']))
          PlanCost(
            category: _toStr(c['category']),
            item: _toStr(c['item']),
            amount: _toInt(c['amount']),
            note: _toStr(c['note']),
          ),
      ],
      itinerary: [
        for (final s in list(json['itinerary']))
          PlanStep(
            day: _toInt(s['day']),
            time: _toStr(s['time']),
            activity: _toStr(s['activity']),
            location: s['location'] is Json
                ? LocationModel.fromJson(s['location'] as Json)
                : null,
          ),
      ],
      tips: [
        for (final t
            in (json['tips'] is List ? json['tips'] as List : const []))
          _toStr(t),
      ],
    );
  }
}

class SavedPlanModel {
  static SavedPlan fromJson(Json json) => SavedPlan(
    id: _toInt(json['id']),
    location: LocationModel.fromJson(
      json['location'] is Json ? json['location'] as Json : const {},
    ),
    plan: TripPlanModel.fromJson(
      json['plan'] is Json ? json['plan'] as Json : const {},
    ),
    createdAt:
        DateTime.tryParse(_toStr(json['created_at']))?.toLocal() ??
        DateTime.now(),
  );
}
