import 'dart:convert';

class DiaryEntry {
  final String id;
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final DateTime watchedDate;
  final double rating;
  final String reviewText;
  final bool isRewatch;
  final List<String> tags;

  DiaryEntry({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    required this.watchedDate,
    this.rating = 0,
    this.reviewText = '',
    this.isRewatch = false,
    this.tags = const [],
  });

  String get moviePosterUrl => moviePosterPath != null
      ? 'https://image.tmdb.org/t/p/w200$moviePosterPath'
      : '';

  bool get hasReview => reviewText.isNotEmpty;
  bool get hasRating => rating > 0;

  DiaryEntry copyWith({
    String? id,
    int? movieId,
    String? movieTitle,
    String? moviePosterPath,
    DateTime? watchedDate,
    double? rating,
    String? reviewText,
    bool? isRewatch,
    List<String>? tags,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterPath: moviePosterPath ?? this.moviePosterPath,
      watchedDate: watchedDate ?? this.watchedDate,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      isRewatch: isRewatch ?? this.isRewatch,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterPath': moviePosterPath,
      'watchedDate': watchedDate.toIso8601String(),
      'rating': rating,
      'reviewText': reviewText,
      'isRewatch': isRewatch,
      'tags': tags,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] ?? '',
      movieId: json['movieId'] ?? 0,
      movieTitle: json['movieTitle'] ?? '',
      moviePosterPath: json['moviePosterPath'],
      watchedDate: json['watchedDate'] != null
          ? DateTime.parse(json['watchedDate'])
          : DateTime.now(),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewText: json['reviewText'] ?? '',
      isRewatch: json['isRewatch'] ?? false,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : [],
    );
  }

  static List<DiaryEntry> listFromJsonString(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((item) => DiaryEntry.fromJson(item)).toList();
  }

  static String listToJsonString(List<DiaryEntry> entries) {
    return jsonEncode(entries.map((e) => e.toJson()).toList());
  }
}
