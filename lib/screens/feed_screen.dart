import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import '../models/review.dart';
import 'review_detail_screen.dart';
import 'public_profile_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.movie_filter_rounded, size: 30),
          ),
          title: const Text('CineViews'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Amigos'),
              Tab(text: 'Comunidade'),
            ],
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        body: Consumer<SocialProvider>(
          builder: (context, socialProvider, _) {
            if (socialProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final reviews = socialProvider.feedReviews;

            return TabBarView(
              children: [
                _buildFeedList(context, reviews, socialProvider, true),
                _buildFeedList(context, reviews, socialProvider, false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedList(BuildContext context, List<Review> reviews,
      SocialProvider socialProvider, bool friendsOnly) {
    List<Review> displayReviews = reviews;

    if (friendsOnly && socialProvider.currentUser != null) {
      final followingUsernames = socialProvider
          .getFollowing(socialProvider.currentUser!.id)
          .map((p) => p.username)
          .toSet();
      displayReviews = reviews
          .where((r) => followingUsernames.contains(r.authorUsername))
          .toList();
    }

    if (displayReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter_outlined,
                size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              friendsOnly
                  ? 'Nenhuma atividade de amigos ainda.\nSiga mais pessoas para ver seu feed!'
                  : 'Nenhuma atividade na comunidade ainda.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayReviews.length,
      itemBuilder: (context, index) {
        return _buildFeedItem(context, displayReviews[index], socialProvider);
      },
    );
  }

  Widget _buildFeedItem(
      BuildContext context, Review review, SocialProvider socialProvider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                final profile = socialProvider.allProfiles.firstWhere(
                  (p) => p.username == review.authorUsername,
                  orElse: () => socialProvider.currentUser!,
                );
                if (profile.id != socialProvider.currentUser?.id) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PublicProfileScreen(userId: profile.id),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(review.authorAvatar),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            children: [
                              TextSpan(
                                text: '${review.authorName} ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(
                                text: 'escreveu uma resenha',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatTimeAgo(review.createdAt),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: review.moviePosterUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: review.moviePosterUrl,
                          width: 70,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (c, u) =>
                              Container(width: 70, height: 100, color: Colors.grey[800]),
                          errorWidget: (c, u, e) =>
                              Container(width: 70, height: 100, color: Colors.grey[800]),
                        )
                      : Container(
                          width: 70, height: 100, color: Colors.grey[800]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.movieTitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: starIndex < review.rating
                                ? Colors.orange
                                : Colors.white24,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<SocialProvider>().toggleLikeReview(review.id);
                  },
                  icon: Icon(
                    review.isLikedByCurrentUser
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 20,
                    color:
                        review.isLikedByCurrentUser ? Colors.red : null,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                Text('${review.likes}',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70)),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ReviewDetailScreen(reviewId: review.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded,
                      size: 20),
                  visualDensity: VisualDensity.compact,
                ),
                Text('${review.comments.length}',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ReviewDetailScreen(reviewId: review.id),
                      ),
                    );
                  },
                  child: const Text('Ver mais'),
                ),
              ],
            ),
          ],
        ),
      ),
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
