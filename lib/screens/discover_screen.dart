import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import 'search_results_screen.dart';
import 'widgets/log_movie_dialog.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            automaticallyImplyLeading: false,
            title: TextField(
              controller: _searchController,
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SearchResultsScreen(query: query.trim()),
                    ),
                  );
                  _searchController.clear();
                }
              },
              decoration: InputDecoration(
                hintText: 'Buscar filmes, séries, diretores...',
                prefixIcon: const Icon(Icons.search),
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
          Consumer<MovieProvider>(
            builder: (context, movieProvider, child) {
              if (movieProvider.isLoading &&
                  movieProvider.trendingMovies.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionHeader('Destaques'),
                    const SizedBox(height: 12),
                    _buildHighlightsCarousel(movieProvider.trendingMovies),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Populares'),
                    const SizedBox(height: 12),
                    _buildHorizontalList(movieProvider.popularMovies),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Em alta na comunidade'),
                    const SizedBox(height: 12),
                  ]),
                ),
              );
            },
          ),
          Consumer<MovieProvider>(
            builder: (context, movieProvider, child) {
              if (movieProvider.trendingMovies.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: _buildTrendingGrid(movieProvider.trendingMovies),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: () => LogMovieDialog.show(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == _selectedIndex) return;
          setState(() => _selectedIndex = index);
          if (index == 1) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const FeedScreen()));
            setState(() => _selectedIndex = 0);
          } else if (index == 2) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
            setState(() => _selectedIndex = 0);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore), label: 'Descoberta'),
          NavigationDestination(icon: Icon(Icons.rss_feed), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Ver tudo'),
        ),
      ],
    );
  }

  Widget _buildHighlightsCarousel(List<Movie> movies) {
    if (movies.isEmpty) {
      return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
    }
    final displayMovies = movies.take(5).toList();
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayMovies.length,
        itemBuilder: (context, index) {
          final movie = displayMovies[index];
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _navigateToDetail(context, movie.id),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    movie.backdropUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: movie.backdropUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[800]),
                            errorWidget: (context, url, error) =>
                                Container(color: Colors.grey[800]),
                          )
                        : Container(color: Colors.grey[800]),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8)
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    color: Colors.orange[400], size: 16),
                                const SizedBox(width: 4),
                                Text(movie.voteAverage.toStringAsFixed(1)),
                                const SizedBox(width: 8),
                                Text(
                                  movie.year,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalList(List<Movie> movies) {
    if (movies.isEmpty) {
      return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
    }
    final displayMovies = movies.take(10).toList();
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayMovies.length,
        itemBuilder: (context, index) {
          final movie = displayMovies[index];
          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToDetail(context, movie.id),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: movie.posterUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: movie.posterUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[800]),
                              errorWidget: (context, url, error) =>
                                  Container(color: Colors.grey[800]),
                            )
                          : Container(color: Colors.grey[800]),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange[400], size: 12),
                    const SizedBox(width: 2),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      movie.year,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingGrid(List<Movie> movies) {
    final displayMovies = movies.skip(5).take(6).toList();
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final movie = displayMovies[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _navigateToDetail(context, movie.id),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: movie.posterUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: movie.posterUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[800]),
                                errorWidget: (context, url, error) =>
                                    Container(color: Colors.grey[800]),
                              )
                            : Container(color: Colors.grey[800]),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          context
                              .read<MovieProvider>()
                              .toggleWatchlist(movie.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Consumer<MovieProvider>(
                            builder: (context, mp, _) {
                              return Icon(
                                mp.isInWatchlist(movie.id)
                                    ? Icons.bookmark
                                    : Icons.add,
                                color: Colors.orange,
                                size: 20,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.orange[400], size: 12),
                  const SizedBox(width: 2),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ],
          );
        },
        childCount: displayMovies.length,
      ),
    );
  }

  void _navigateToDetail(BuildContext context, int movieId) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => MovieDetailScreen(movieId: movieId)),
    );
  }
}
