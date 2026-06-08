import 'package:flutter/material.dart';
import '../models/review.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';

class SocialProvider extends ChangeNotifier {
  final LocalStorageService _storageService;

  UserProfile? _currentUser;
  List<UserProfile> _allProfiles = [];
  List<Review> _allReviews = [];
  bool _isLoading = false;

  SocialProvider(this._storageService);

  // Getters
  UserProfile? get currentUser => _currentUser;
  List<UserProfile> get allProfiles => _allProfiles;
  List<Review> get allReviews => _allReviews;
  bool get isLoading => _isLoading;

  List<Review> get feedReviews {
    final sorted = List<Review>.from(_allReviews);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  List<Review> getReviewsByMovie(int movieId) {
    return _allReviews.where((r) => r.movieId == movieId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Review> getReviewsByUser(String username) {
    return _allReviews.where((r) => r.authorUsername == username).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<UserProfile> getFollowers(String userId) {
    final user = _allProfiles.firstWhere(
      (p) => p.id == userId,
      orElse: () => _currentUser!,
    );
    return _allProfiles
        .where((p) => user.followerIds.contains(p.id))
        .toList();
  }

  List<UserProfile> getFollowing(String userId) {
    final user = _allProfiles.firstWhere(
      (p) => p.id == userId,
      orElse: () => _currentUser!,
    );
    return _allProfiles
        .where((p) => user.followingIds.contains(p.id))
        .toList();
  }

  /// Inicializa com dados persistidos ou cria dados seed
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _storageService.getCurrentUser();
    _allProfiles = await _storageService.getProfiles();
    _allReviews = await _storageService.getReviews();

    if (_currentUser == null) {
      await _seedData();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Dados de seed para popular o app na primeira abertura
  Future<void> _seedData() async {
    _currentUser = UserProfile(
      id: 'user_current',
      name: 'Alex Silva',
      username: '@alex_cinephile',
      avatarUrl: 'https://i.pravatar.cc/150?u=user_current',
      bio: 'Amante de cinema, viciado em café e ficção científica. Tentando assistir 365 filmes este ano.',
      moviesWatched: 0,
      reviewsCount: 0,
      listsCount: 0,
      followerIds: ['user_2', 'user_3', 'user_5'],
      followingIds: ['user_1', 'user_2', 'user_4', 'user_6'],
    );

    _allProfiles = [
      _currentUser!,
      UserProfile(
        id: 'user_1',
        name: 'Marina Costa',
        username: '@marina_films',
        avatarUrl: 'https://i.pravatar.cc/150?u=user_1',
        bio: 'Crítica de cinema nas horas vagas. Apaixonada por filmes franceses e terror psicológico.',
        moviesWatched: 287,
        reviewsCount: 64,
        listsCount: 8,
        followerIds: ['user_current', 'user_3', 'user_4'],
        followingIds: ['user_2', 'user_5'],
      ),
      UserProfile(
        id: 'user_2',
        name: 'Pedro Henrique',
        username: '@pedro_cine',
        avatarUrl: 'https://i.pravatar.cc/150?u=user_2',
        bio: 'Diretor de curtas e cinéfilo incurável. Tarantino é meu guru.',
        moviesWatched: 512,
        reviewsCount: 123,
        listsCount: 15,
        followerIds: ['user_current', 'user_1', 'user_5'],
        followingIds: ['user_current', 'user_3'],
      ),
      UserProfile(
        id: 'user_3',
        name: 'Juliana Mendes',
        username: '@juju_movies',
        avatarUrl: 'https://i.pravatar.cc/150?u=user_3',
        bio: 'Atriz e roteirista. Adoro analisar cada detalhe de fotografia.',
        moviesWatched: 198,
        reviewsCount: 41,
        listsCount: 5,
        followerIds: ['user_2'],
        followingIds: ['user_current', 'user_1'],
      ),
      UserProfile(
        id: 'user_4',
        name: 'Rafael Oliveira',
        username: '@rafa_cinema',
        avatarUrl: 'https://i.pravatar.cc/150?u=user_4',
        bio: 'Fã de filmes de ação e ficção científica. Marvel vs DC? Assisto os dois!',
        moviesWatched: 340,
        reviewsCount: 55,
        listsCount: 10,
        followerIds: ['user_1'],
        followingIds: ['user_current'],
      ),
      UserProfile(
        id: 'user_5',
        name: 'Camila Santos',
        username: '@cami_filmada',
        avatarUrl: 'https://i.pravatar.cc/150?u=user_5',
        bio: 'Documentarista. Cinema é a arte de contar histórias reais.',
        moviesWatched: 156,
        reviewsCount: 28,
        listsCount: 4,
        followerIds: ['user_2'],
        followingIds: ['user_current'],
      ),
      UserProfile(
        id: 'user_6',
        name: 'Lucas Ferreira',
        username: '@lucas_tela',
        avatarUrl: 'https://i.pravatar.cc/150?u=user_6',
        bio: 'Músico e compositor de trilhas sonoras. Hans Zimmer é rei.',
        moviesWatched: 220,
        reviewsCount: 37,
        listsCount: 6,
        followerIds: ['user_current'],
        followingIds: ['user_3'],
      ),
    ];

    // Resenhas seed com movieIds reais do TMDb
    _allReviews = [
      Review(
        id: 'rev_1',
        movieId: 157336, // Interstellar
        movieTitle: 'Interestelar',
        moviePosterPath: '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        authorName: 'Pedro Henrique',
        authorUsername: '@pedro_cine',
        authorAvatar: 'https://i.pravatar.cc/150?u=user_2',
        rating: 5.0,
        content:
            'Uma obra-prima visual e emocional. Christopher Nolan consegue misturar física teórica com uma jornada humana profunda. A cena do vídeo do Cooper é de chorar copiosamente. Hans Zimmer entregou uma das melhores trilhas da história do cinema. TARS é o melhor robô do cinema.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 24,
        comments: [
          ReviewComment(
            id: 'com_1',
            authorName: 'Marina Costa',
            authorUsername: '@marina_films',
            authorAvatar: 'https://i.pravatar.cc/150?u=user_1',
            content: 'Concordo totalmente! A trilha sonora é absurda.',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      Review(
        id: 'rev_2',
        movieId: 335984, // Blade Runner 2049
        movieTitle: 'Blade Runner 2049',
        moviePosterPath: '/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg',
        authorName: 'Marina Costa',
        authorUsername: '@marina_films',
        authorAvatar: 'https://i.pravatar.cc/150?u=user_1',
        rating: 4.5,
        content:
            'Denis Villeneuve prova mais uma vez que é um mestre da ficção científica contemplativa. Roger Deakins merecia 10 Oscars pela fotografia deste filme. Cada frame poderia ser um quadro.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 18,
      ),
      Review(
        id: 'rev_3',
        movieId: 550, // Fight Club
        movieTitle: 'Clube da Luta',
        moviePosterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
        authorName: 'Juliana Mendes',
        authorUsername: '@juju_movies',
        authorAvatar: 'https://i.pravatar.cc/150?u=user_3',
        rating: 4.0,
        content:
            'Fincher é um gênio da narrativa não-linear. O plot twist ainda funciona mesmo quando você já sabe. A crítica ao consumismo é mais relevante hoje do que em 1999.',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        likes: 32,
      ),
      Review(
        id: 'rev_4',
        movieId: 27205, // Inception
        movieTitle: 'A Origem',
        moviePosterPath: '/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg',
        authorName: 'Rafael Oliveira',
        authorUsername: '@rafa_cinema',
        authorAvatar: 'https://i.pravatar.cc/150?u=user_4',
        rating: 4.5,
        content:
            'Nolan criou um labirinto cinematográfico brilhante. A trilha do Hans Zimmer é hipnótica. A cena do corredor giratório é uma das melhores cenas de ação já filmadas.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 41,
      ),
      Review(
        id: 'rev_5',
        movieId: 496243, // Parasite
        movieTitle: 'Parasita',
        moviePosterPath: '/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
        authorName: 'Camila Santos',
        authorUsername: '@cami_filmada',
        authorAvatar: 'https://i.pravatar.cc/150?u=user_5',
        rating: 5.0,
        content:
            'Bong Joon-ho criou uma obra-prima que transita entre gêneros com uma naturalidade assustadora. É comédia, é thriller, é drama social. A metáfora da escada é genial.',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        likes: 56,
      ),
      Review(
        id: 'rev_6',
        movieId: 346698, // Barbie
        movieTitle: 'Barbie',
        moviePosterPath: '/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg',
        authorName: 'Lucas Ferreira',
        authorUsername: '@lucas_tela',
        authorAvatar: 'https://i.pravatar.cc/150?u=user_6',
        rating: 3.5,
        content:
            'Greta Gerwig surpreendeu com uma comédia inteligente e cheia de camadas. A trilha sonora é contagiante. Ryan Gosling rouba cada cena como Ken.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        likes: 15,
      ),
    ];

    await _storageService.saveCurrentUser(_currentUser!);
    await _storageService.saveProfiles(_allProfiles);
    await _storageService.saveReviews(_allReviews);
  }

  // ─── Actions ───

  Future<void> addReview(Review review) async {
    _allReviews.insert(0, review);
    await _storageService.saveReviews(_allReviews);

    // Atualizar contagem de resenhas do autor
    if (review.authorUsername == _currentUser?.username) {
      _currentUser = _currentUser!.copyWith(
        reviewsCount: _currentUser!.reviewsCount + 1,
      );
      await _storageService.saveCurrentUser(_currentUser!);
    }

    notifyListeners();
  }

  Future<void> toggleLikeReview(String reviewId) async {
    final index = _allReviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return;

    final review = _allReviews[index];
    _allReviews[index] = review.copyWith(
      isLikedByCurrentUser: !review.isLikedByCurrentUser,
      likes: review.isLikedByCurrentUser ? review.likes - 1 : review.likes + 1,
    );

    await _storageService.saveReviews(_allReviews);
    notifyListeners();
  }

  Future<void> addCommentToReview(
      String reviewId, ReviewComment comment) async {
    final index = _allReviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return;

    final review = _allReviews[index];
    final updatedComments = [...review.comments, comment];
    _allReviews[index] = review.copyWith(comments: updatedComments);

    await _storageService.saveReviews(_allReviews);
    notifyListeners();
  }

  Future<void> toggleFollow(String targetUserId) async {
    if (_currentUser == null) return;

    final targetIndex =
        _allProfiles.indexWhere((p) => p.id == targetUserId);
    if (targetIndex == -1) return;

    final isFollowing = _currentUser!.followingIds.contains(targetUserId);
    final updatedFollowing = List<String>.from(_currentUser!.followingIds);
    final targetProfile = _allProfiles[targetIndex];
    final updatedFollowers = List<String>.from(targetProfile.followerIds);

    if (isFollowing) {
      updatedFollowing.remove(targetUserId);
      updatedFollowers.remove(_currentUser!.id);
    } else {
      updatedFollowing.add(targetUserId);
      updatedFollowers.add(_currentUser!.id);
    }

    _currentUser = _currentUser!.copyWith(followingIds: updatedFollowing);
    _allProfiles[targetIndex] =
        targetProfile.copyWith(followerIds: updatedFollowers);

    // Atualizar o perfil do current user na lista também
    final currentIdx =
        _allProfiles.indexWhere((p) => p.id == _currentUser!.id);
    if (currentIdx != -1) {
      _allProfiles[currentIdx] = _currentUser!;
    }

    await _storageService.saveCurrentUser(_currentUser!);
    await _storageService.saveProfiles(_allProfiles);
    notifyListeners();
  }

  bool isFollowing(String userId) {
    return _currentUser?.followingIds.contains(userId) ?? false;
  }

  UserProfile? getProfileById(String userId) {
    try {
      return _allProfiles.firstWhere((p) => p.id == userId);
    } catch (_) {
      return null;
    }
  }
}
