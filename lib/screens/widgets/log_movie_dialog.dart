import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../providers/movie_provider.dart';
import '../../providers/diary_provider.dart';
import '../../providers/social_provider.dart';
import '../../models/movie.dart';
import '../../models/diary_entry.dart';
import '../../models/review.dart';

class LogMovieDialog {
  static void show(BuildContext context, {Movie? preselectedMovie}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _LogMovieContent(preselectedMovie: preselectedMovie),
    );
  }
}

class _LogMovieContent extends StatefulWidget {
  final Movie? preselectedMovie;

  const _LogMovieContent({this.preselectedMovie});

  @override
  State<_LogMovieContent> createState() => _LogMovieContentState();
}

class _LogMovieContentState extends State<_LogMovieContent> {
  final _searchController = TextEditingController();
  final _reviewController = TextEditingController();
  final _tagController = TextEditingController();

  Movie? _selectedMovie;
  DateTime _watchedDate = DateTime.now();
  double _rating = 0;
  bool _isRewatch = false;
  bool _containsSpoilers = false;
  bool _publishReview = false;
  List<String> _tags = [];
  List<Movie> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedMovie = widget.preselectedMovie;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _reviewController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _searchMovies(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final provider = context.read<MovieProvider>();
      await provider.searchMovies(query);
      setState(() {
        _searchResults = provider.searchResults;
        _isSearching = false;
      });
    } catch (_) {
      setState(() => _isSearching = false);
    }
  }

  void _selectMovie(Movie movie) {
    setState(() {
      _selectedMovie = movie;
      _searchResults = [];
      _searchController.clear();
    });
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _watchedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.orange,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _watchedDate = picked);
    }
  }

  void _save() {
    if (_selectedMovie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um filme primeiro')),
      );
      return;
    }

    final movie = _selectedMovie!;
    final diaryProvider = context.read<DiaryProvider>();
    final movieProvider = context.read<MovieProvider>();

    // Create diary entry
    final entry = DiaryEntry(
      id: 'diary_${DateTime.now().millisecondsSinceEpoch}',
      movieId: movie.id,
      movieTitle: movie.title,
      moviePosterPath: movie.posterPath,
      watchedDate: _watchedDate,
      rating: _rating,
      reviewText: _reviewController.text.trim(),
      isRewatch: _isRewatch,
      tags: _tags,
    );
    diaryProvider.addEntry(entry);

    // Mark as watched
    if (!movieProvider.isWatched(movie.id)) {
      movieProvider.toggleWatched(movie.id);
    }

    // Optionally publish as review
    if (_publishReview && _reviewController.text.trim().isNotEmpty) {
      final socialProvider = context.read<SocialProvider>();
      final currentUser = socialProvider.currentUser;

      if (currentUser != null) {
        final review = Review(
          id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
          movieId: movie.id,
          movieTitle: movie.title,
          moviePosterPath: movie.posterPath,
          authorName: currentUser.name,
          authorUsername: currentUser.username,
          authorAvatar: currentUser.avatarUrl,
          rating: _rating,
          content: _reviewController.text.trim(),
          createdAt: DateTime.now(),
          containsSpoilers: _containsSpoilers,
        );
        socialProvider.addReview(review);
      }
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${movie.title} registrado no diário!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Registrar no Diário',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _save,
                    child: Text('SALVAR',
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Movie Selection
              if (_selectedMovie == null) ...[
                TextField(
                  controller: _searchController,
                  onChanged: _searchMovies,
                  decoration: InputDecoration(
                    hintText: 'Buscar filme...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_searchResults.isNotEmpty)
                  ...(_searchResults.take(5).map((movie) => ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: movie.posterUrlSmall.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: movie.posterUrlSmall,
                                  width: 35,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 35,
                                  height: 50,
                                  color: Colors.grey[800]),
                        ),
                        title: Text(movie.title),
                        subtitle: Text(movie.year,
                            style: const TextStyle(color: Colors.white54)),
                        onTap: () => _selectMovie(movie),
                      ))),
              ] else ...[
                // Selected Movie Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _selectedMovie!.posterUrlSmall.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: _selectedMovie!.posterUrlSmall,
                                width: 50,
                                height: 75,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 50,
                                height: 75,
                                color: Colors.grey[800]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedMovie!.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(_selectedMovie!.year,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () =>
                            setState(() => _selectedMovie = null),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Date Picker
              const Text('Data de Exibição',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        '${_watchedDate.day}/${_watchedDate.month}/${_watchedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, size: 16, color: Colors.white54),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Rating
              const Text('Avaliação',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = _rating == index + 1.0 ? 0 : index + 1.0;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color:
                            index < _rating ? Colors.orange : Colors.white24,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Review
              const Text('Resenha (opcional)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'O que você achou do filme?',
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Options
              SwitchListTile(
                title: const Text('Já assisti antes'),
                subtitle: const Text('Rewatch',
                    style: TextStyle(fontSize: 12, color: Colors.white54)),
                value: _isRewatch,
                onChanged: (val) => setState(() => _isRewatch = val),
                activeColor: colorScheme.primary,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Publicar como Resenha'),
                subtitle: const Text('Aparecerá no feed da comunidade',
                    style: TextStyle(fontSize: 12, color: Colors.white54)),
                value: _publishReview,
                onChanged: (val) => setState(() => _publishReview = val),
                activeColor: colorScheme.primary,
                contentPadding: EdgeInsets.zero,
              ),
              if (_publishReview)
                SwitchListTile(
                  title: const Text('Contém spoilers'),
                  value: _containsSpoilers,
                  onChanged: (val) =>
                      setState(() => _containsSpoilers = val),
                  activeColor: Colors.red,
                  contentPadding: EdgeInsets.zero,
                ),

              const SizedBox(height: 16),

              // Tags
              const Text('Tags (opcional)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      onSubmitted: (_) => _addTag(),
                      decoration: InputDecoration(
                        hintText: 'Adicionar tag...',
                        filled: true,
                        fillColor: Colors.black26,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addTag,
                    icon: Icon(Icons.add_circle,
                        color: colorScheme.primary),
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        setState(() => _tags.remove(tag));
                      },
                      backgroundColor: Colors.orange.withOpacity(0.15),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'SALVAR NO DIÁRIO',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
