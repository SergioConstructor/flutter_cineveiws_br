import 'dart:convert';

class Review {
  final String id;
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final String authorName;
  final String authorUsername;
  final String authorAvatar;
  final double rating;
  final String content;
  final DateTime createdAt;
  final int likes;
  final List<ReviewComment> comments;
  final bool containsSpoilers;
  final bool isLikedByCurrentUser;

  Review({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatar,
    required this.rating,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.comments = const [],
    this.containsSpoilers = false,
    this.isLikedByCurrentUser = false,
  });

  String get moviePosterUrl => moviePosterPath != null
      ? 'https://image.tmdb.org/t/p/w200$moviePosterPath'
      : '';

  Review copyWith({
    String? id,
    int? movieId,
    String? movieTitle,
    String? moviePosterPath,
    String? authorName,
    String? authorUsername,
    String? authorAvatar,
    double? rating,
    String? content,
    DateTime? createdAt,
    int? likes,
    List<ReviewComment>? comments,
    bool? containsSpoilers,
    bool? isLikedByCurrentUser,
  }) {
    return Review(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterPath: moviePosterPath ?? this.moviePosterPath,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      containsSpoilers: containsSpoilers ?? this.containsSpoilers,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterPath': moviePosterPath,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'authorAvatar': authorAvatar,
      'rating': rating,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments.map((c) => c.toJson()).toList(),
      'containsSpoilers': containsSpoilers,
      'isLikedByCurrentUser': isLikedByCurrentUser,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      movieId: json['movieId'],
      movieTitle: json['movieTitle'] ?? '',
      moviePosterPath: json['moviePosterPath'],
      authorName: json['authorName'] ?? '',
      authorUsername: json['authorUsername'] ?? '',
      authorAvatar: json['authorAvatar'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'] ?? 0,
      comments: json['comments'] != null
          ? List<ReviewComment>.from(
              (json['comments'] as List).map((c) => ReviewComment.fromJson(c)))
          : [],
      containsSpoilers: json['containsSpoilers'] ?? false,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
    );
  }

  static List<Review> listFromJsonString(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((item) => Review.fromJson(item)).toList();
  }

  static String listToJsonString(List<Review> reviews) {
    return jsonEncode(reviews.map((r) => r.toJson()).toList());
  }
}

class ReviewComment {
  final String id;
  final String authorName;
  final String authorUsername;
  final String authorAvatar;
  final String content;
  final DateTime createdAt;

  ReviewComment({
    required this.id,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatar,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'authorAvatar': authorAvatar,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReviewComment.fromJson(Map<String, dynamic> json) {
    return ReviewComment(
      id: json['id'],
      authorName: json['authorName'] ?? '',
      authorUsername: json['authorUsername'] ?? '',
      authorAvatar: json['authorAvatar'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
