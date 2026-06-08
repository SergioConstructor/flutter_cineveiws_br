class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final double popularity;
  final List<String>? genres;
  final int? runtime;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    required this.popularity,
    this.genres,
    this.runtime,
  });

  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p';

  String get posterUrl => posterPath != null
      ? '$_imageBaseUrl/w500$posterPath'
      : '';

  String get posterUrlSmall => posterPath != null
      ? '$_imageBaseUrl/w200$posterPath'
      : '';

  String get backdropUrl => backdropPath != null
      ? '$_imageBaseUrl/w780$backdropPath'
      : '';

  String get year => releaseDate.length >= 4
      ? releaseDate.substring(0, 4)
      : '';

  String get runtimeFormatted {
    if (runtime == null) return '';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    return '${hours}h ${minutes}m';
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      genreIds: json['genre_ids'] != null
          ? List<int>.from(json['genre_ids'])
          : (json['genres'] != null
              ? List<int>.from((json['genres'] as List).map((g) => g['id']))
              : []),
      popularity: (json['popularity'] ?? 0).toDouble(),
      genres: json['genres'] != null
          ? List<String>.from((json['genres'] as List).map((g) => g['name']))
          : null,
      runtime: json['runtime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'genre_ids': genreIds,
      'popularity': popularity,
      'genres': genres?.map((g) => {'name': g}).toList(),
      'runtime': runtime,
    };
  }
}
