import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import '../providers/list_provider.dart';
import '../models/user_profile.dart';
import '../models/review.dart';
import 'review_detail_screen.dart';
import 'followers_screen.dart';
import 'list_detail_screen.dart';

class PublicProfileScreen extends StatelessWidget {
  final String? userId;

  const PublicProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<SocialProvider>(
      builder: (context, socialProvider, _) {
        final effectiveId = userId ??
            (ModalRoute.of(context)?.settings.arguments as String? ?? '');
        final user = socialProvider.getProfileById(effectiveId);

        if (user == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Usuário não encontrado')),
          );
        }

        final isFollowing = socialProvider.isFollowing(user.id);
        final reviews = socialProvider.getReviewsByUser(user.username);

        return Scaffold(
          body: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 380,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 80),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: colorScheme.primary, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(user.avatarUrl),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user.username,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 14),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 12),
                            child: Text(
                              user.bio,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white70),
                            ),
                          ),
                          // Follow Button
                          ElevatedButton(
                            onPressed: () =>
                                socialProvider.toggleFollow(user.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing
                                  ? colorScheme.surface
                                  : colorScheme.primary,
                              foregroundColor: isFollowing
                                  ? Colors.white
                                  : Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: isFollowing
                                    ? BorderSide(color: Colors.white24)
                                    : BorderSide.none,
                              ),
                            ),
                            child: Text(
                              isFollowing ? 'Seguindo' : 'Seguir',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStats(context, user),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      const TabBar(
                        tabs: [
                          Tab(text: 'Resenhas'),
                          Tab(text: 'Listas'),
                          Tab(text: 'Info'),
                        ],
                        indicatorSize: TabBarIndicatorSize.tab,
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _ReviewsTab(reviews: reviews),
                  _ListsTab(authorId: user.id),
                  _InfoTab(user: user),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStats(BuildContext context, UserProfile user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(label: 'Filmes', value: '${user.moviesWatched}'),
        _StatItem(label: 'Resenhas', value: '${user.reviewsCount}'),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FollowersScreen(userId: user.id),
              ),
            );
          },
          child: _StatItem(
              label: 'Seguidores', value: '${user.followersCount}'),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    FollowersScreen(userId: user.id, initialTab: 1),
              ),
            );
          },
          child: _StatItem(
              label: 'Seguindo', value: '${user.followingCount}'),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final List<Review> reviews;

  const _ReviewsTab({required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(
        child: Text('Nenhuma resenha ainda.',
            style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReviewDetailScreen(reviewId: review.id),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (review.moviePosterUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: review.moviePosterUrl,
                            width: 40,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review.movieTitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(Icons.star_rounded,
                                    size: 14,
                                    color: i < review.rating
                                        ? Colors.orange
                                        : Colors.white24);
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
          ),
        );
      },
    );
  }
}

class _ListsTab extends StatelessWidget {
  final String authorId;

  const _ListsTab({required this.authorId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ListProvider>(
      builder: (context, listProvider, _) {
        final lists = listProvider
            .getListsByAuthor(authorId)
            .where((l) => l.isPublic)
            .toList();

        if (lists.isEmpty) {
          return const Center(
            child: Text('Nenhuma lista pública.',
                style: TextStyle(color: Colors.white54)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lists.length,
          itemBuilder: (context, index) {
            final list = lists[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ListDetailScreen(listId: list.id),
                  ),
                );
              },
              child: Container(
                height: 80,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(list.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('${list.movieCount} filmes',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoTab extends StatelessWidget {
  final UserProfile user;

  const _InfoTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sobre',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(user.bio,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 24),
          _infoRow(Icons.movie, '${user.moviesWatched} filmes assistidos'),
          _infoRow(Icons.rate_review, '${user.reviewsCount} resenhas escritas'),
          _infoRow(Icons.list, '${user.listsCount} listas criadas'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white54),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
