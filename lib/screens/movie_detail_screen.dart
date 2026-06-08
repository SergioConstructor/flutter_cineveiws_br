import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../providers/social_provider.dart';
import '../models/movie.dart';
import '../models/cast_member.dart';
import '../models/review.dart';
import 'review_detail_screen.dart';
import 'widgets/log_movie_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Movie? _movie;
  List<CastMember> _cast = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final movieProvider = context.read<MovieProvider>();
    final movie = await movieProvider.getMovieDetails(widget.movieId);
    final cast = await movieProvider.getMovieCredits(widget.movieId);

    if (mounted) {
      setState(() {
        _movie = movie;
        _cast = cast.take(10).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_movie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Erro ao carregar filme')),
      );
    }

    final movie = _movie!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  movie.backdropUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: movie.backdropUrl,
                          fit: BoxFit.cover,
                          placeholder: (c, u) =>
                              Container(color: Colors.grey[900]),
                          errorWidget: (c, u, e) =>
                              Container(color: Colors.grey[900]),
                        )
                      : Container(color: Colors.grey[900]),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF121212)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: movie.posterUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: movie.posterUrl,
                              width: 120,
                              height: 180,
                              fit: BoxFit.cover,
                              placeholder: (c, u) =>
                                  Container(width: 120, height: 180, color: Colors.grey[800]),
                              errorWidget: (c, u, e) =>
                                  Container(width: 120, height: 180, color: Colors.grey[800]),
                            )
                          : Container(
                              width: 120, height: 180, color: Colors.grey[800]),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${movie.year} • ${movie.runtimeFormatted}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star_rounded,
                                  color: Colors.orange[400], size: 18),
                              const SizedBox(width: 4),
                              Text(
                                movie.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                ' (${movie.voteCount})',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (movie.genres != null)
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: movie.genres!.map((g) {
                                return Chip(
                                  label: Text(g,
                                      style: const TextStyle(fontSize: 10)),
                                  backgroundColor: colorScheme.surface,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Consumer<MovieProvider>(
                  builder: (context, mp, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionButton(
                          icon: mp.isWatched(movie.id)
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          label: 'Assistido',
                          isActive: mp.isWatched(movie.id),
                          onTap: () => mp.toggleWatched(movie.id),
                        ),
                        _ActionButton(
                          icon: mp.isInWatchlist(movie.id)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          label: 'Quero Ver',
                          isActive: mp.isInWatchlist(movie.id),
                          onTap: () => mp.toggleWatchlist(movie.id),
                        ),
                        _ActionButton(
                          icon: Icons.edit_calendar,
                          label: 'Diário',
                          onTap: () => LogMovieDialog.show(
                            context,
                            preselectedMovie: movie,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                const Text('Sinopse',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  movie.overview.isNotEmpty
                      ? movie.overview
                      : 'Sinopse não disponível em português.',
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 32),

                if (_cast.isNotEmpty) ...[
                  const Text('Elenco Principal',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildCastList(),
                  const SizedBox(height: 32),
                ],

                // Community Reviews
                _buildCommunityReviews(colorScheme),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _cast.length,
        itemBuilder: (context, index) {
          final member = _cast[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: member.hasImage
                      ? NetworkImage(member.profileUrl)
                      : null,
                  child: member.hasImage
                      ? null
                      : const Icon(Icons.person, size: 30),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    member.name,
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommunityReviews(ColorScheme colorScheme) {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, _) {
        final reviews = socialProvider.getReviewsByMovie(widget.movieId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Resenhas da Comunidade',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (reviews.length > 2)
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver todas'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (reviews.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Nenhuma resenha ainda. Seja o primeiro!',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              ...reviews.take(3).map((review) => _buildReviewCard(review)),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReviewDetailScreen(reviewId: review.id),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(review.authorAvatar),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(review.authorName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              Icons.star_rounded,
                              size: 14,
                              color:
                                  i < review.rating ? Colors.orange : Colors.white24,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                review.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.favorite,
                      size: 14,
                      color: review.isLikedByCurrentUser
                          ? Colors.red
                          : Colors.white54),
                  const SizedBox(width: 4),
                  Text('${review.likes}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white54)),
                  const SizedBox(width: 16),
                  const Icon(Icons.chat_bubble_outline,
                      size: 14, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text('${review.comments.length}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white54)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Icon(icon,
              color: isActive ? Colors.orange : Colors.white70, size: 28),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: isActive ? Colors.orange : Colors.white70,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
