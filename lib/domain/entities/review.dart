import 'user.dart';

class Review {
  const Review({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.rating,
    required this.comment,
    this.user,
    this.createdAt,
  });

  final int id;
  final String userId;
  final String locationId;
  final int rating;
  final String comment;
  final User? user;
  final DateTime? createdAt;
}
