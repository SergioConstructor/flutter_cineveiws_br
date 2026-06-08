import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/cast_member.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _bearerToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNDJlMTVjZDUxYTlkM2Q4YzkxNjI2ZGY5YzVjZTA4OSIsIm5iZiI6MTc4MDg3OTM3Ny43MDU5OTk5LCJzdWIiOiI2YTI2MTAxMWM5ZmQ3M2MwZTUxMTNhZTMiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.7KjzLcTf4Sa2npcv39HhgY5BoDrnvacK84-aoT2j4OM';
  static const String _language = 'pt-BR';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_bearerToken',
        'Content-Type': 'application/json;charset=utf-8',
      };

  Future<Map<String, dynamic>> _get(String endpoint,
      {Map<String, String>? queryParams}) async {
    final params = {
      'language': _language,
      ...?queryParams,
    };
    final uri = Uri.parse('$_baseUrl$endpoint')
        .replace(queryParameters: params);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Erro na API TMDb: ${response.statusCode} - ${response.body}');
    }
  }

  /// Retorna filmes populares
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final data = await _get('/movie/popular', queryParams: {
      'page': page.toString(),
    });
    final List<dynamic> results = data['results'] ?? [];
    return results.map((json) => Movie.fromJson(json)).toList();
  }

  /// Retorna filmes em tendência (day ou week)
  Future<List<Movie>> getTrendingMovies({String timeWindow = 'week'}) async {
    final data = await _get('/trending/movie/$timeWindow');
    final List<dynamic> results = data['results'] ?? [];
    return results.map((json) => Movie.fromJson(json)).toList();
  }

  /// Retorna detalhes completos de um filme
  Future<Movie> getMovieDetails(int movieId) async {
    final data = await _get('/movie/$movieId');
    return Movie.fromJson(data);
  }

  /// Retorna elenco e equipe de um filme
  Future<List<CastMember>> getMovieCredits(int movieId) async {
    final data = await _get('/movie/$movieId/credits');
    final List<dynamic> cast = data['cast'] ?? [];
    return cast.map((json) => CastMember.fromJson(json)).toList();
  }

  /// Busca filmes por texto
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final data = await _get('/search/movie', queryParams: {
      'query': query,
      'page': page.toString(),
    });
    final List<dynamic> results = data['results'] ?? [];
    return results.map((json) => Movie.fromJson(json)).toList();
  }

  /// Retorna filmes por gênero
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    final data = await _get('/discover/movie', queryParams: {
      'with_genres': genreId.toString(),
      'sort_by': 'popularity.desc',
      'page': page.toString(),
    });
    final List<dynamic> results = data['results'] ?? [];
    return results.map((json) => Movie.fromJson(json)).toList();
  }

  /// Retorna a lista de gêneros de filmes
  Future<Map<int, String>> getGenreList() async {
    final data = await _get('/genre/movie/list');
    final List<dynamic> genres = data['genres'] ?? [];
    return {
      for (var g in genres) g['id'] as int: g['name'] as String,
    };
  }

  /// Retorna filmes de uma década específica
  Future<List<Movie>> getMoviesByDecade(String decade,
      {int page = 1}) async {
    final startYear = decade.replaceAll('s', '');
    final endYear = (int.parse(startYear) + 9).toString();

    final data = await _get('/discover/movie', queryParams: {
      'primary_release_date.gte': '$startYear-01-01',
      'primary_release_date.lte': '$endYear-12-31',
      'sort_by': 'popularity.desc',
      'page': page.toString(),
    });
    final List<dynamic> results = data['results'] ?? [];
    return results.map((json) => Movie.fromJson(json)).toList();
  }
}
