import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import 'movie_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String? query;

  const SearchResultsScreen({super.key, this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    if (widget.query != null && widget.query!.isNotEmpty) {
      _searchController.text = widget.query!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.query!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    setState(() => _hasSearched = true);
    context.read<MovieProvider>().searchMovies(query.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: widget.query == null,
          onSubmitted: _performSearch,
          decoration: InputDecoration(
            hintText: 'Buscar filmes...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<MovieProvider>().clearSearch();
                      setState(() => _hasSearched = false);
                    },
                  )
                : null,
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, _) {
          if (movieProvider.isSearching) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_hasSearched) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search,
                      size: 80, color: Colors.white.withOpacity(0.15)),
                  const SizedBox(height: 16),
                  const Text(
                    'Digite o nome do filme que deseja buscar',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            );
          }

          final results = movieProvider.searchResults;

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_filter_outlined,
                      size: 80, color: Colors.white.withOpacity(0.15)),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum filme encontrado.',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tente um termo diferente.',
                    style: TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.55,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final movie = results[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MovieDetailScreen(movieId: movie.id),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: movie.posterUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: movie.posterUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (c, u) =>
                                    Container(color: Colors.grey[800]),
                                errorWidget: (c, u, e) =>
                                    Container(color: Colors.grey[800]),
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: const Center(
                                    child: Icon(Icons.movie, size: 30))),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange[400], size: 11),
                        const SizedBox(width: 2),
                        Text(
                          '${movie.voteAverage.toStringAsFixed(1)} • ${movie.year}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white54),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
