import 'package:flutter/material.dart';
import '../models/movie_list.dart';
import '../services/local_storage_service.dart';

class ListProvider extends ChangeNotifier {
  final LocalStorageService _storageService;

  List<MovieList> _lists = [];
  bool _isLoading = false;

  ListProvider(this._storageService);

  List<MovieList> get lists => _lists;
  bool get isLoading => _isLoading;

  List<MovieList> getListsByAuthor(String authorId) {
    return _lists.where((l) => l.authorId == authorId).toList();
  }

  List<MovieList> get publicLists {
    return _lists.where((l) => l.isPublic).toList();
  }

  MovieList? getListById(String listId) {
    try {
      return _lists.firstWhere((l) => l.id == listId);
    } catch (_) {
      return null;
    }
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _lists = await _storageService.getLists();

    if (_lists.isEmpty) {
      await _seedLists();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _seedLists() async {
    _lists = [
      MovieList(
        id: 'list_1',
        title: 'Ficção Científica de Pirar o Cabeção',
        description:
            'Os melhores filmes de ficção científica que vão expandir sua mente.',
        authorId: 'user_2',
        authorName: 'Pedro Henrique',
        isPublic: true,
        movieIds: [157336, 335984, 27205, 264660], // Interstellar, Blade Runner 2049, Inception, Ex Machina
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        likes: 42,
      ),
      MovieList(
        id: 'list_2',
        title: 'Obras-Primas do Terror',
        description: 'Filmes de terror que são verdadeira arte cinematográfica.',
        authorId: 'user_1',
        authorName: 'Marina Costa',
        isPublic: true,
        movieIds: [694, 346364, 493922], // The Shining, It, Hereditary
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        likes: 28,
      ),
      MovieList(
        id: 'list_3',
        title: 'Cinema Coreano Essencial',
        description:
            'Filmes coreanos que todo cinéfilo precisa assistir.',
        authorId: 'user_5',
        authorName: 'Camila Santos',
        isPublic: true,
        movieIds: [496243, 578], // Parasite, Jaws (placeholder)
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        likes: 35,
      ),
    ];

    await _storageService.saveLists(_lists);
  }

  Future<void> createList(MovieList newList) async {
    _lists.insert(0, newList);
    await _storageService.saveLists(_lists);
    notifyListeners();
  }

  Future<void> updateList(MovieList updatedList) async {
    final index = _lists.indexWhere((l) => l.id == updatedList.id);
    if (index != -1) {
      _lists[index] = updatedList;
      await _storageService.saveLists(_lists);
      notifyListeners();
    }
  }

  Future<void> deleteList(String listId) async {
    _lists.removeWhere((l) => l.id == listId);
    await _storageService.saveLists(_lists);
    notifyListeners();
  }

  Future<void> addMovieToList(String listId, int movieId) async {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index != -1) {
      final list = _lists[index];
      if (!list.movieIds.contains(movieId)) {
        final updatedIds = [...list.movieIds, movieId];
        _lists[index] = list.copyWith(movieIds: updatedIds);
        await _storageService.saveLists(_lists);
        notifyListeners();
      }
    }
  }

  Future<void> removeMovieFromList(String listId, int movieId) async {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index != -1) {
      final list = _lists[index];
      final updatedIds = list.movieIds.where((id) => id != movieId).toList();
      _lists[index] = list.copyWith(movieIds: updatedIds);
      await _storageService.saveLists(_lists);
      notifyListeners();
    }
  }

  Future<void> reorderMoviesInList(
      String listId, int oldIndex, int newIndex) async {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index != -1) {
      final list = _lists[index];
      final updatedIds = List<int>.from(list.movieIds);
      final item = updatedIds.removeAt(oldIndex);
      updatedIds.insert(newIndex, item);
      _lists[index] = list.copyWith(movieIds: updatedIds);
      await _storageService.saveLists(_lists);
      notifyListeners();
    }
  }
}
