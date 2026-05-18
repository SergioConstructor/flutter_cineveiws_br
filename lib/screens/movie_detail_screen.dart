import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  double _userRating = 0.0;
  bool _watched = false;
  bool _watchlist = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                  CachedNetworkImage(
                    imageUrl: 'https://picsum.photos/seed/movie_backdrop/800/600',
                    fit: BoxFit.cover,
                  ),
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
                      child: CachedNetworkImage(
                        imageUrl: 'https://picsum.photos/seed/movie_poster/200/300',
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Blade Runner 2049',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '2017 • 2h 44m',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: ['Ficção Científica', 'Drama', 'Mistério'].map((g) {
                              return Chip(
                                label: Text(g, style: const TextStyle(fontSize: 10)),
                                backgroundColor: colorScheme.surface,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: _watched ? Icons.check_circle : Icons.check_circle_outline,
                      label: 'Assistido',
                      isActive: _watched,
                      onTap: () => setState(() => _watched = !_watched),
                    ),
                    _ActionButton(
                      icon: _watchlist ? Icons.bookmark : Icons.bookmark_border,
                      label: 'Quero Ver',
                      isActive: _watchlist,
                      onTap: () => setState(() => _watchlist = !_watchlist),
                    ),
                    _ActionButton(
                      icon: Icons.list,
                      label: 'Listas',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                const Text('Sinopse', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Trinta anos após os eventos do primeiro filme, um novo blade runner, o oficial K do LAPD, descobre um segredo enterrado há muito tempo que tem o potencial de mergulhar o que resta da sociedade no caos.',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 32),

                const Text('Elenco Principal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildCastList(),
                const SizedBox(height: 32),

                // User Rating Section
                _buildUserRatingSection(colorScheme),
                const SizedBox(height: 32),

                // Community Rating Section
                _buildCommunitySection(),
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
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=actor$index'),
                ),
                const SizedBox(height: 8),
                const Text('Ator ${index + 1}', style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserRatingSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Sua Avaliação', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _userRating = index + 1.0),
                icon: Icon(
                  index < _userRating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: index < _userRating ? Colors.orange : Colors.white24,
                  size: 36,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escreva sua resenha...',
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('SALVAR RESENHA'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('O que a comunidade achou', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Column(
              children: [
                Text('4.2', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.orange)),
                const Text('de 5', style: TextStyle(color: Colors.white54)),
              ],
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text('${5 - index}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (5 - index) / 5,
                              backgroundColor: Colors.white10,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.withOpacity(0.7)),
                              minHeight: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
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
          Icon(icon, color: isActive ? Colors.orange : Colors.white70, size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? Colors.orange : Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
