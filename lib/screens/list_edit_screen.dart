import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/list_provider.dart';
import '../providers/movie_provider.dart';
import '../providers/social_provider.dart';
import '../models/movie_list.dart';
import '../models/movie.dart';

class ListEditScreen extends StatefulWidget {
  final MovieList? existingList;

  const ListEditScreen({super.key, this.existingList});

  @override
  State<ListEditScreen> createState() => _ListEditScreenState();
}

class _ListEditScreenState extends State<ListEditScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  bool _isPublic = true;
  List<_MovieItem> _selectedMovies = [];
  List<Movie> _searchResults = [];
  bool _isSearching = false;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingList != null) {
      final list = widget.existingList!;
      _titleController.text = list.title;
      _descriptionController.text = list.description;
      _isPublic = list.isPublic;
      _loadExistingMovies(list.movieIds);
    }
  }

  Future<void> _loadExistingMovies(List<int> movieIds) async {
    final movieProvider = context.read<MovieProvider>();
    for (final id in movieIds) {
      final movie = await movieProvider.getMovieDetails(id);
      if (movie != null && mounted) {
        setState(() {
          _selectedMovies.add(_MovieItem(
            id: movie.id,
            title: movie.title,
            posterUrl: movie.posterUrlSmall,
            year: movie.year,
          ));
        });
      }
    }
  }

  Future<void> _searchMovies(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final movieProvider = context.read<MovieProvider>();
      await movieProvider.searchMovies(query);
      setState(() {
        _searchResults = movieProvider.searchResults;
        _isSearching = false;
      });
    } catch (_) {
      setState(() => _isSearching = false);
    }
  }

  void _addMovie(Movie movie) {
    if (_selectedMovies.any((m) => m.id == movie.id)) return;

    setState(() {
      _selectedMovies.add(_MovieItem(
        id: movie.id,
        title: movie.title,
        posterUrl: movie.posterUrlSmall,
        year: movie.year,
      ));
      _showSearch = false;
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _removeMovie(int movieId) {
    setState(() {
      _selectedMovies.removeWhere((m) => m.id == movieId);
    });
  }

  void _saveList() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um título para a lista')),
      );
      return;
    }

    final listProvider = context.read<ListProvider>();
    final socialProvider = context.read<SocialProvider>();
    final currentUser = socialProvider.currentUser;

    if (widget.existingList != null) {
      final updated = widget.existingList!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        isPublic: _isPublic,
        movieIds: _selectedMovies.map((m) => m.id).toList(),
      );
      listProvider.updateList(updated);
    } else {
      final newList = MovieList(
        id: 'list_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        authorId: currentUser?.id ?? '',
        authorName: currentUser?.name ?? '',
        isPublic: _isPublic,
        movieIds: _selectedMovies.map((m) => m.id).toList(),
        createdAt: DateTime.now(),
      );
      listProvider.createList(newList);
    }

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.existingList != null ? 'Editar Lista' : 'Nova Lista'),
        actions: [
          TextButton(
            onPressed: _saveList,
            child: Text('SALVAR',
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título da Lista',
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Public/Private toggle
            SwitchListTile(
              title: const Text('Lista Pública'),
              subtitle: Text(
                _isPublic
                    ? 'Visível para todos os usuários'
                    : 'Apenas você pode ver',
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
              value: _isPublic,
              onChanged: (val) => setState(() => _isPublic = val),
              activeColor: colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),

            // Movie List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filmes (${_selectedMovies.length})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _showSearch = !_showSearch),
                  icon: Icon(_showSearch ? Icons.close : Icons.add),
                  label: Text(_showSearch ? 'Fechar' : 'Adicionar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Section
            if (_showSearch) ...[
              TextField(
                controller: _searchController,
                onChanged: _searchMovies,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar filme para adicionar...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_isSearching) const Center(child: CircularProgressIndicator()),
              if (_searchResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.take(8).length,
                    itemBuilder: (context, index) {
                      final movie = _searchResults[index];
                      final alreadyAdded =
                          _selectedMovies.any((m) => m.id == movie.id);

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: movie.posterUrlSmall.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: movie.posterUrlSmall,
                                  width: 35,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 35,
                                  height: 50,
                                  color: Colors.grey[800]),
                        ),
                        title: Text(movie.title,
                            style: const TextStyle(fontSize: 14)),
                        subtitle: Text(movie.year,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white54)),
                        trailing: alreadyAdded
                            ? const Icon(Icons.check,
                                color: Colors.green)
                            : IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    color: Colors.orange),
                                onPressed: () => _addMovie(movie),
                              ),
                        onTap: alreadyAdded
                            ? null
                            : () => _addMovie(movie),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Selected Movies
            if (_selectedMovies.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Center(
                  child: Text(
                    'Nenhum filme adicionado.\nClique em "Adicionar" para buscar filmes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedMovies.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _selectedMovies.removeAt(oldIndex);
                    _selectedMovies.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final movie = _selectedMovies[index];
                  return ListTile(
                    key: ValueKey(movie.id),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${index + 1}',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12)),
                        const SizedBox(width: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: movie.posterUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: movie.posterUrl,
                                  width: 35,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 35,
                                  height: 50,
                                  color: Colors.grey[800]),
                        ),
                      ],
                    ),
                    title: Text(movie.title,
                        style: const TextStyle(fontSize: 14)),
                    subtitle: Text(movie.year,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white54)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          onPressed: () => _removeMovie(movie.id),
                        ),
                        const Icon(Icons.drag_handle, color: Colors.white38),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MovieItem {
  final int id;
  final String title;
  final String posterUrl;
  final String year;

  _MovieItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.year,
  });
}
