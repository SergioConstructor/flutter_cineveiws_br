import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorscheme = Theme.of(context).colorScheme;

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
        body: TabBarView(
          children: [
            _buildFeedList(context, 'amigo'),
            _buildFeedList(context, 'comunidade'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedList(BuildContext context, String type) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildFeedItem(context, index);
      },
    );
  }

  Widget _buildFeedItem(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isReview = index % 3 == 0;
    final bool isList = index % 3 == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${index + 50}'),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Usuário ${index + 1} ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: isReview 
                                  ? 'escreveu uma resenha' 
                                  : (isList ? 'criou uma lista' : 'avaliou'),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'há 2 horas',
                        style: TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: 'https://picsum.photos/seed/${index + 40}/100/150',
                    width: 70,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Interestelar',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (!isList) ...[
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: starIndex < 4 ? Colors.orange : Colors.white24,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (isReview) 
                        const Text(
                          'Uma obra-prima visual e emocional. Christopher Nolan consegue misturar física teórica com uma jornada humana profunda...',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      if (isList)
                        const Text(
                          'Lista: "Ficção Científica de Pirar o Cabeção"',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
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
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
                const Text('24', style: TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
                const Text('5', style: TextStyle(fontSize: 12, color: Colors.white70)),
                const Spacer(),
                if (isReview)
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver mais'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
