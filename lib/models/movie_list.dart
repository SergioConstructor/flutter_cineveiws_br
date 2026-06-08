import 'dart:convert';

class MovieList {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final String authorName;
  final bool isPublic;
  final List<int> movieIds;
  final DateTime createdAt;
  final int likes;

  MovieList({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.authorName,
    this.isPublic = true,
    this.movieIds = const [],
    required this.createdAt,
    this.likes = 0,
  });

  int get movieCount => movieIds.length;

  MovieList copyWith({
    String? id,
    String? title,
    String? description,
    String? authorId,
    String? authorName,
    bool? isPublic,
    List<int>? movieIds,
    DateTime? createdAt,
    int? likes,
  }) {
    return MovieList(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isPublic: isPublic ?? this.isPublic,
      movieIds: movieIds ?? this.movieIds,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'isPublic': isPublic,
      'movieIds': movieIds,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
    };
  }

  factory MovieList.fromJson(Map<String, dynamic> json) {
    return MovieList(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      isPublic: json['isPublic'] ?? true,
      movieIds: json['movieIds'] != null
          ? List<int>.from(json['movieIds'])
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      likes: json['likes'] ?? 0,
    );
  }

  static List<MovieList> listFromJsonString(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((item) => MovieList.fromJson(item)).toList();
  }

  static String listToJsonString(List<MovieList> lists) {
    return jsonEncode(lists.map((l) => l.toJson()).toList());
  }
}
