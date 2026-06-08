import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import '../providers/list_provider.dart';
import '../providers/movie_provider.dart';
import '../providers/diary_provider.dart';
import 'movie_detail_screen.dart';
import 'review_detail_screen.dart';
import 'followers_screen.dart';
import 'list_detail_screen.dart';
import 'list_edit_screen.dart';
import 'diary_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<SocialProvider>(
      builder: (context, socialProvider, _) {
        final user = socialProvider.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final watchedCount =
            context.watch<MovieProvider>().watchedMovieIds.length;
        final reviewsCount =
            socialProvider.getReviewsByUser(user.username).length;
        final listsCount =
            context.watch<ListProvider>().getListsByAuthor(user.id).length;

        return Scaffold(
          body: DefaultTabController(
            length: 4,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 340,
                    floating: false,
                    pinned: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () {},
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
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
                          _buildStats(context, watchedCount, reviewsCount,
                              listsCount, user.followersCount),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      const TabBar(
                        tabs: [
                          Tab(text: 'Filmes'),
                          Tab(text: 'Resenhas'),
                          Tab(text: 'Listas'),
                          Tab(text: 'Diário'),
                        ],
                        indicatorSize: TabBarIndicatorSize.tab,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _MoviesTab(),
                  _ReviewsTab(username: user.username),
                  _ListsTab(authorId: user.id),
                  _DiaryTab(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStats(BuildContext context, int movies, int reviews, int lists,
      int followers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(label: 'Filmes', value: '$movies'),
        _StatItem(label: 'Resenhas', value: '$reviews'),
        _StatItem(label: 'Listas', value: '$lists'),
        GestureDetector(
          onTap: () {
            final userId =
                context.read<SocialProvider>().currentUser?.id ?? '';
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FollowersScreen(userId: userId),
              ),
            );
          },
          child: _StatItem(label: 'Seguidores', value: '$followers'),
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

class _MoviesTab extends StatefulWidget {
  const _MoviesTab();

  @override
  State<_MoviesTab> createState() => _MoviesTabState();
}

class _MoviesTabState extends State<_MoviesTab> with AutomaticKeepAliveClientMixin {
  Future<List<Map<String, dynamic>>>? _watchedMoviesFuture;
  List<int>? _cachedIds;

  @override
  bool get wantKeepAlive => true;

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<List<Map<String, dynamic>>> _loadWatchedMovies(
      MovieProvider provider, List<int> ids) async {
    final results = <Map<String, dynamic>>[];
    for (final id in ids.take(20)) {
      final movie = await provider.getMovieDetails(id);
      if (movie != null) {
        results.add({'id': movie.id, 'posterUrl': movie.posterUrl});
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, _) {
        final watchedIds = movieProvider.watchedMovieIds.toList();

        if (watchedIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie_outlined,
                    size: 64, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                const Text(
                  'Nenhum filme assistido ainda.\nComece marcando filmes como assistidos!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          );
        }

        if (_cachedIds == null || !_listEquals(_cachedIds!, watchedIds)) {
          _cachedIds = watchedIds;
          _watchedMoviesFuture = _loadWatchedMovies(movieProvider, watchedIds);
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _watchedMoviesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Erro ao carregar filmes'));
            }

            final movies = snapshot.data!;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            MovieDetailScreen(movieId: movie['id']),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: movie['posterUrl'] != null &&
                            (movie['posterUrl'] as String).isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: movie['posterUrl'],
                            fit: BoxFit.cover,
                            placeholder: (c, u) =>
                                Container(color: Colors.grey[800]),
                            errorWidget: (c, u, e) =>
                                Container(color: Colors.grey[800]),
                          )
                        : Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.movie, size: 30)),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ReviewsTab extends StatefulWidget {
  final String username;

  const _ReviewsTab({required this.username});

  @override
  State<_ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<_ReviewsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, _) {
        final reviews = socialProvider.getReviewsByUser(widget.username);

        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined,
                    size: 64, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                const Text(
                  'Nenhuma resenha ainda.',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
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
                    builder: (_) =>
                        ReviewDetailScreen(reviewId: review.id),
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
                                placeholder: (c, u) => Container(color: Colors.grey[800]),
                                errorWidget: (c, u, e) => Container(color: Colors.grey[800]),
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
                                    return Icon(
                                      Icons.star_rounded,
                                      size: 14,
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
      },
    );
  }
}

class _ListsTab extends StatefulWidget {
  final String authorId;

  const _ListsTab({required this.authorId});

  @override
  State<_ListsTab> createState() => _ListsTabState();
}

class _ListsTabState extends State<_ListsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ListProvider>(
      builder: (context, listProvider, _) {
        final lists = listProvider.getListsByAuthor(widget.authorId);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ListEditScreen()),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Nova Lista'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: lists.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list_alt,
                              size: 64,
                              color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhuma lista criada ainda.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: lists.length,
                      itemBuilder: (context, index) {
                        final list = lists[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ListDetailScreen(listId: list.id),
                              ),
                            );
                          },
                          child: Container(
                            height: 100,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        const BorderRadius.horizontal(
                                            left: Radius.circular(12)),
                                    color:
                                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${list.movieCount}',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(list.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      Text(
                                        '${list.movieCount} filmes • ${list.isPublic ? "Público" : "Privado"}',
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _DiaryTab extends StatefulWidget {
  const _DiaryTab();

  @override
  State<_DiaryTab> createState() => _DiaryTabState();
}

class _DiaryTabState extends State<_DiaryTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<DiaryProvider>(
      builder: (context, diaryProvider, _) {
        final entries = diaryProvider.allEntriesSorted;

        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month_outlined,
                    size: 64, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                const Text(
                  'Seu diário está vazio.\nComece registrando filmes!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const DiaryScreen()),
                    );
                  },
                  child: const Text('Abrir Diário'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const DiaryScreen()),
                    );
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Ver Diário Completo'),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: entries.take(10).length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: entry.moviePosterUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: entry.moviePosterUrl,
                              width: 35,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder: (c, u) => Container(color: Colors.grey[800]),
                              errorWidget: (c, u, e) => Container(color: Colors.grey[800]),
                            )
                          : Container(
                              width: 35,
                              height: 50,
                              color: Colors.grey[800]),
                    ),
                    title: Text(entry.movieTitle,
                        style: const TextStyle(fontSize: 14)),
                    subtitle: Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(Icons.star_rounded,
                              size: 12,
                              color: i < entry.rating
                                  ? Colors.orange
                                  : Colors.white24);
                        }),
                        if (entry.isRewatch) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.replay,
                              size: 12, color: Colors.white54),
                        ],
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              MovieDetailScreen(movieId: entry.movieId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
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
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
