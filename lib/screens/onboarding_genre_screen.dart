import 'package:flutter/material.dart';
import 'discover_screen.dart';

class OnboardingGenreScreen extends StatefulWidget {
  const OnboardingGenreScreen({super.key});

  @override
  State<OnboardingGenreScreen> createState() => _OnboardingGenreScreenState();
}

class _OnboardingGenreScreenState extends State<OnboardingGenreScreen> {
  final List<Map<String, dynamic>> _genres = [
    {'name': 'Ação', 'icon': Icons.local_movies},
    {'name': 'Comédia', 'icon': Icons.emoji_emotions},
    {'name': 'Drama', 'icon': Icons.theater_comedy},
    {'name': 'Terror', 'icon': Icons.scuba_diving}, // Just placeholder icons
    {'name': 'Ficção Científica', 'icon': Icons.rocket_launch},
    {'name': 'Romance', 'icon': Icons.favorite},
    {'name': 'Animação', 'icon': Icons.animation},
    {'name': 'Documentário', 'icon': Icons.videocam},
    {'name': 'Suspense', 'icon': Icons.visibility},
    {'name': 'Crime', 'icon': Icons.gavel},
    {'name': 'Fantasia', 'icon': Icons.auto_fix_high},
    {'name': 'Musical', 'icon': Icons.music_note},
  ];

  final List<String> _decades = [
    '1970s', '1980s', '1990s', '2000s', '2010s', '2020s'
  ];

  final Set<String> _selectedGenres = {};
  final Set<String> _selectedDecades = {};

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  void _toggleDecade(String decade) {
    setState(() {
      if (_selectedDecades.contains(decade)) {
        _selectedDecades.remove(decade);
      } else {
        _selectedDecades.add(decade);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isButtonEnabled = _selectedGenres.length >= 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passo 1 de 2'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 0.5,
            backgroundColor: colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'O que você curte assistir?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecione ao menos 3 gêneros para personalizarmos seu feed.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            
            // Genres Grid
            const Text(
              'Gêneros Favoritos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = _selectedGenres.contains(genre['name']);
                return InkWell(
                  onTap: () => _toggleGenre(genre['name']),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary.withOpacity(0.2) : colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          genre['icon'],
                          color: isSelected ? colorScheme.primary : Colors.white70,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          genre['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? colorScheme.primary : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Decades Section
            const Text(
              'Décadas Favoritas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _decades.map((decade) {
                final isSelected = _selectedDecades.contains(decade);
                return FilterChip(
                  label: Text(decade),
                  selected: isSelected,
                  onSelected: (_) => _toggleDecade(decade),
                  selectedColor: colorScheme.primary.withOpacity(0.3),
                  checkmarkColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? colorScheme.primary : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? colorScheme.primary : Colors.white24,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 48),
            
            // Selection count and button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedGenres.length} de 12 selecionados',
                  style: const TextStyle(color: Colors.white54),
                ),
                ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const DiscoverScreen()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CONTINUAR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
