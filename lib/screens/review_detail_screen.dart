import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import '../models/review.dart';
import 'movie_detail_screen.dart';
import 'public_profile_screen.dart';

class ReviewDetailScreen extends StatefulWidget {
  final String? reviewId;

  const ReviewDetailScreen({super.key, this.reviewId});

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  final _commentController = TextEditingController();
  String? _reviewId;

  @override
  void initState() {
    super.initState();
    _reviewId = widget.reviewId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reviewId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _reviewId = args;
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<SocialProvider>(
      builder: (context, socialProvider, _) {
        if (_reviewId == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Resenha não encontrada')),
          );
        }

        final review = socialProvider.allReviews.firstWhere(
          (r) => r.id == _reviewId,
          orElse: () => Review(
            id: '',
            movieId: 0,
            movieTitle: '',
            authorName: '',
            authorUsername: '',
            authorAvatar: '',
            rating: 0,
            content: 'Resenha não encontrada',
            createdAt: DateTime.now(),
          ),
        );

        if (review.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Resenha não encontrada')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Resenha'),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie Info
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MovieDetailScreen(
                                  movieId: review.movieId),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: review.moviePosterUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: review.moviePosterUrl,
                                      width: 60,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 90,
                                      color: Colors.grey[800]),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.movieTitle,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        Icons.star_rounded,
                                        size: 20,
                                        color: i < review.rating
                                            ? Colors.orange
                                            : Colors.white24,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 16),

                      // Author Info
                      GestureDetector(
                        onTap: () {
                          final profile =
                              socialProvider.allProfiles.firstWhere(
                            (p) => p.username == review.authorUsername,
                            orElse: () => socialProvider.currentUser!,
                          );
                          if (profile.id !=
                              socialProvider.currentUser?.id) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PublicProfileScreen(
                                    userId: profile.id),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  NetworkImage(review.authorAvatar),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.authorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  review.authorUsername,
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Review Content
                      if (review.containsSpoilers) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.red.withOpacity(0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber,
                                  color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Text('Esta resenha contém spoilers',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],

                      Text(
                        review.content,
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            height: 1.7),
                      ),

                      const SizedBox(height: 20),

                      // Like + stats
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => socialProvider
                                .toggleLikeReview(review.id),
                            child: Row(
                              children: [
                                Icon(
                                  review.isLikedByCurrentUser
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: review.isLikedByCurrentUser
                                      ? Colors.red
                                      : Colors.white54,
                                  size: 22,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${review.likes} curtidas',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Icon(Icons.chat_bubble_outline,
                              size: 18, color: Colors.white54),
                          const SizedBox(width: 6),
                          Text(
                            '${review.comments.length} comentários',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: Colors.white10),

                      // Comments Section
                      const SizedBox(height: 16),
                      const Text('Comentários',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      if (review.comments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'Nenhum comentário ainda. Seja o primeiro!',
                              style: TextStyle(color: Colors.white38),
                            ),
                          ),
                        )
                      else
                        ...review.comments.map((comment) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage:
                                        NetworkImage(comment.authorAvatar),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              comment.authorName,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 13),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatTimeAgo(
                                                  comment.createdAt),
                                              style: const TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 11),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comment.content,
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
              ),

              // Comment Input
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: const Border(
                    top: BorderSide(color: Colors.white10),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Escreva um comentário...',
                            filled: true,
                            fillColor: Colors.black26,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          if (_commentController.text.trim().isEmpty) return;

                          final currentUser = socialProvider.currentUser;
                          if (currentUser == null) return;

                          final comment = ReviewComment(
                            id: 'com_${DateTime.now().millisecondsSinceEpoch}',
                            authorName: currentUser.name,
                            authorUsername: currentUser.username,
                            authorAvatar: currentUser.avatarUrl,
                            content: _commentController.text.trim(),
                            createdAt: DateTime.now(),
                          );

                          socialProvider.addCommentToReview(
                              review.id, comment);
                          _commentController.clear();
                        },
                        icon: Icon(Icons.send_rounded,
                            color: colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays < 7) return 'há ${diff.inDays}d';
    return 'há ${diff.inDays ~/ 7} sem';
  }
}
