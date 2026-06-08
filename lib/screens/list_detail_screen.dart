import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/list_provider.dart';
import '../providers/movie_provider.dart';
import '../providers/social_provider.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';
import 'list_edit_screen.dart';

class ListDetailScreen extends StatefulWidget {
  final String? listId;

  const ListDetailScreen({super.key, this.listId});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  String? _listId;
  List<Movie?> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listId = widget.listId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_listId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _listId = args;
      }
    }
    if (_isLoading) {
      _loadMovies();
    }
  }

  Future<void> _loadMovies() async {
    final listProvider = context.read<ListProvider>();
    final movieProvider = context.read<MovieProvider>();
    final movieList = listProvider.getListById(_listId ?? '');

    if (movieList == null) {
      setState(() => _isLoading = false);
      return;
    }

    final movies = <Movie?>[];
    for (final id in movieList.movieIds) {
      final movie = await movieProvider.getMovieDetails(id);
      movies.add(movie);
    }

    if (mounted) {
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer2<ListProvider, MovieProvider>(
      builder: (context, listProvider, movieProvider, _) {
        final movieList = listProvider.getListById(_listId ?? '');

        if (movieList == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Lista não encontrada')),
          );
        }

        final watchedCount = movieList.movieIds
            .where((id) => movieProvider.isWatched(id))
            .length;
        final progress = movieList.movieIds.isEmpty
            ? 0.0
            : watchedCount / movieList.movieIds.length;

        final currentUser = context.read<SocialProvider>().currentUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes da Lista'),
            actions: [
              if (movieList.authorId == currentUser?.id)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ListEditScreen(existingList: movieList),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movieList.title,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person_outline,
                                    size: 16, color: Colors.white54),
                                const SizedBox(width: 4),
                                Text(
                                  movieList.authorName,
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 13),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.movie_outlined,
                                    size: 16, color: Colors.white54),
                                const SizedBox(width: 4),
                                Text(
                                  '${movieList.movieCount} filmes',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 13),
                                ),
                              ],
                            ),
                            if (movieList.description.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                movieList.description,
                                style: const TextStyle(
                                    color: Colors.white70, height: 1.5),
                              ),
                            ],

                            // Progress Bar
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.white10,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              colorScheme.primary),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$watchedCount/${movieList.movieCount}',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Você assistiu ${(progress * 100).toInt()}% desta lista',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12),
                            ),

                            const SizedBox(height: 8),
                            const Divider(color: Colors.white10),
                          ],
                        ),
                      ),
                    ),

                    // Movie Grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.6,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final movie = _movies[index];
                            if (movie == null) return const SizedBox();

                            final isWatched =
                                movieProvider.isWatched(movie.id);

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MovieDetailScreen(
                                        movieId: movie.id),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: movie.posterUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: movie.posterUrl,
                                                  fit: BoxFit.cover,
                                                  placeholder: (c, u) =>
                                                      Container(
                                                          color: Colors
                                                              .grey[800]),
                                                  errorWidget: (c, u, e) =>
                                                      Container(
                                                          color: Colors
                                                              .grey[800]),
                                                )
                                              : Container(
                                                  color: Colors.grey[800]),
                                        ),
                                        if (isWatched)
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withOpacity(0.8),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12),
                                              ),
                                              child: const Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    movie.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: _movies.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
        );
      },
    );
  }
}
