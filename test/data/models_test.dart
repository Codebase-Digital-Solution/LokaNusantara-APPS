import 'package:bali_guide_map/core/api/api_client.dart';
import 'package:bali_guide_map/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a location from the API shape', () {
    final location = LocationModel.fromJson({
      'id': 'abc',
      'name': 'Tanah Lot',
      'description': 'Pura di atas batu karang',
      'latitude': -8.6212,
      'longitude': 115.0868,
      'address': 'Tabanan',
      'category_id': 5,
      'category': {'id': 5, 'name': 'pura'},
      'history': 'Didirikan oleh Dang Hyang Nirartha.',
      'created_at': '2026-01-01T00:00:00Z',
    });
    expect(location.id, 'abc');
    expect(location.latitude, -8.6212);
    expect(location.category?.name, 'pura');
    expect(location.history, startsWith('Didirikan'));
  });

  test('accepts integer coordinates and missing category', () {
    final location = LocationModel.fromJson({
      'id': 'x',
      'name': 'n',
      'latitude': -8,
      'longitude': 115,
    });
    expect(location.latitude, -8.0);
    expect(location.category, isNull);
    expect(location.history, isEmpty);
  });

  test('ignores an empty embedded user on reviews', () {
    final review = ReviewModel.fromJson({
      'id': 1,
      'user_id': 'u',
      'location_id': 'l',
      'rating': 4,
      'comment': 'ok',
      'user': {'id': '', 'name': '', 'email': ''},
    });
    expect(review.rating, 4);
    expect(review.user, isNull);
  });

  test('parses an auth response into a session', () {
    final session = AuthSessionModel.fromJson({
      'id': 'u1',
      'name': 'Wayan',
      'email': 'w@x.id',
      'token': 't',
    });
    expect(session.token, 't');
    expect(session.user.name, 'Wayan');
  });

  test('dataList tolerates missing data', () {
    expect(dataList({'data': null}), isEmpty);
    expect(dataList(null), isEmpty);
  });

  test(
    'resolveMediaUrl makes uploaded paths absolute against the API host',
    () {
      const base = 'https://api.example.com/api/v1';
      expect(ApiClient.resolveMediaUrl(null, base: base), isNull);
      expect(ApiClient.resolveMediaUrl('  ', base: base), isNull);
      expect(
        ApiClient.resolveMediaUrl('/uploads/locations/a.jpg', base: base),
        'https://api.example.com/uploads/locations/a.jpg',
      );
      expect(
        ApiClient.resolveMediaUrl('https://cdn.example.com/b.png', base: base),
        'https://cdn.example.com/b.png',
      );
    },
  );

  test('TrailModel reads the cover photo, absolute or not set', () {
    final withPhoto = TrailModel.fromJson({
      'id': 1,
      'title': 'Jejak',
      'image_url': '/uploads/trails/a.jpg',
    });
    expect(withPhoto.imageUrl, endsWith('/uploads/trails/a.jpg'));
    expect(withPhoto.imageUrl, startsWith('http'));
    expect(TrailModel.fromJson({'id': 2, 'image_url': ''}).imageUrl, isNull);
  });

  test('UserModel keeps the Google photo through the saved session', () {
    final user = UserModel.fromJson({
      'id': 'u1',
      'name': 'Eka',
      'email': 'e@x.com',
      'avatar_url': 'https://lh3.googleusercontent.com/a/abc=s96-c',
    });
    expect(user.avatarUrl, 'https://lh3.googleusercontent.com/a/abc=s96-c');
    final restored = UserModel.fromJson(UserModel.toJson(user));
    expect(restored.avatarUrl, user.avatarUrl);

    final emailUser = UserModel.fromJson({
      'id': 'u2',
      'name': 'B',
      'email': 'b@x',
    });
    expect(emailUser.avatarUrl, isNull);
    expect(UserModel.toJson(emailUser).containsKey('avatar_url'), isFalse);
  });
}
