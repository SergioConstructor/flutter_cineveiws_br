import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/cast_member.dart';
import '../services/tmdb_service.dart';
import '../services/local_storage_service.dart';

class MovieProvider extends ChangeNotifier {
  final TmdbService _tmdbService = TmdbService();
  final LocalStorageService _storageService;

  List<Movie> _popularMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _searchResults = [];
  Map<int, Movie> _movieDetailsCache = {};
  Map<int, List<CastMember>> _creditsCache = {};
  Map<int, String> _genres = {};
  Set<int> _watchedMovieIds = {};
  Set<int> _watchlistMovieIds = {};
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  MovieProvider(this._storageService);

  // Getters
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get searchResults => _searchResults;
  Map<int, String> get genres => _genres;
  Set<int> get watchedMovieIds => _watchedMovieIds;
  Set<int> get watchlistMovieIds => _watchlistMovieIds;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  bool isWatched(int movieId) => _watchedMovieIds.contains(movieId);
  bool isInWatchlist(int movieId) => _watchlistMovieIds.contains(movieId);

  /// Inicializa o provider carregando dados persistidos e da API
  Future<void> initialize() async {
    _watchedMovieIds = await _storageService.getWatchedMovieIds();
    _watchlistMovieIds = await _storageService.getWatchlistMovieIds();
    await Future.wait([
      fetchPopularMovies(),
      fetchTrendingMovies(),
      fetchGenres(),
    ]);
  }

  Future<void> fetchPopularMovies({int page = 1}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _popularMovies = await _tmdbService.getPopularMovies(page: page);
    } catch (e) {
      _error = 'Erro ao carregar filmes populares: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTrendingMovies({String timeWindow = 'week'}) async {
    try {
      _trendingMovies =
          await _tmdbService.getTrendingMovies(timeWindow: timeWindow);
    } catch (e) {
      _error = 'Erro ao carregar tendências: $e';
    }
    notifyListeners();
  }

  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    try {
      _isSearching = true;
      _error = null;
      notifyListeners();

      _searchResults = await _tmdbService.searchMovies(query);
    } catch (e) {
      _error = 'Erro na busca: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<Movie?> getMovieDetails(int movieId) async {
    if (_movieDetailsCache.containsKey(movieId)) {
      return _movieDetailsCache[movieId];
    }
    try {
      final movie = await _tmdbService.getMovieDetails(movieId);
      _movieDetailsCache[movieId] = movie;
      return movie;
    } catch (e) {
      _error = 'Erro ao carregar detalhes: $e';
      return null;
    }
  }

  Future<List<CastMember>> getMovieCredits(int movieId) async {
    if (_creditsCache.containsKey(movieId)) {
      return _creditsCache[movieId]!;
    }
    try {
      final credits = await _tmdbService.getMovieCredits(movieId);
      _creditsCache[movieId] = credits;
      return credits;
    } catch (e) {
      _error = 'Erro ao carregar elenco: $e';
      return [];
    }
  }

  Future<void> fetchGenres() async {
    try {
      _genres = await _tmdbService.getGenreList();
    } catch (e) {
      _error = 'Erro ao carregar gêneros: $e';
    }
    notifyListeners();
  }

  Future<void> toggleWatched(int movieId) async {
    if (_watchedMovieIds.contains(movieId)) {
      _watchedMovieIds.remove(movieId);
    } else {
      _watchedMovieIds.add(movieId);
    }
    await _storageService.saveWatchedMovieIds(_watchedMovieIds);
    notifyListeners();
  }

  Future<void> toggleWatchlist(int movieId) async {
    if (_watchlistMovieIds.contains(movieId)) {
      _watchlistMovieIds.remove(movieId);
    } else {
      _watchlistMovieIds.add(movieId);
    }
    await _storageService.saveWatchlistMovieIds(_watchlistMovieIds);
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}
