import 'dart:convert';

class UserProfile {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final String bio;
  final int moviesWatched;
  final int reviewsCount;
  final int listsCount;
  final List<String> followerIds;
  final List<String> followingIds;

  UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.bio,
    this.moviesWatched = 0,
    this.reviewsCount = 0,
    this.listsCount = 0,
    this.followerIds = const [],
    this.followingIds = const [],
  });

  int get followersCount => followerIds.length;
  int get followingCount => followingIds.length;

  bool isFollowedBy(String userId) => followerIds.contains(userId);
  bool isFollowing(String userId) => followingIds.contains(userId);

  UserProfile copyWith({
    String? id,
    String? name,
    String? username,
    String? avatarUrl,
    String? bio,
    int? moviesWatched,
    int? reviewsCount,
    int? listsCount,
    List<String>? followerIds,
    List<String>? followingIds,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      moviesWatched: moviesWatched ?? this.moviesWatched,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      listsCount: listsCount ?? this.listsCount,
      followerIds: followerIds ?? this.followerIds,
      followingIds: followingIds ?? this.followingIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'moviesWatched': moviesWatched,
      'reviewsCount': reviewsCount,
      'listsCount': listsCount,
      'followerIds': followerIds,
      'followingIds': followingIds,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      bio: json['bio'] ?? '',
      moviesWatched: json['moviesWatched'] ?? 0,
      reviewsCount: json['reviewsCount'] ?? 0,
      listsCount: json['listsCount'] ?? 0,
      followerIds: json['followerIds'] != null
          ? List<String>.from(json['followerIds'])
          : [],
      followingIds: json['followingIds'] != null
          ? List<String>.from(json['followingIds'])
          : [],
    );
  }

  static List<UserProfile> listFromJsonString(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((item) => UserProfile.fromJson(item)).toList();
  }

  static String listToJsonString(List<UserProfile> profiles) {
    return jsonEncode(profiles.map((p) => p.toJson()).toList());
  }
}
