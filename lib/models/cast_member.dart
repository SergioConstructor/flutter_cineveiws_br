class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final String? department;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    this.department,
  });

  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p';

  String get profileUrl => profilePath != null
      ? '$_imageBaseUrl/w185$profilePath'
      : '';

  bool get hasImage => profilePath != null && profilePath!.isNotEmpty;

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? json['job'] ?? '',
      profilePath: json['profile_path'],
      department: json['known_for_department'],
    );
  }
}
