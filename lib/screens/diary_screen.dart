import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import 'movie_detail_screen.dart';
import 'widgets/log_movie_dialog.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário'),
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, diaryProvider, _) {
          final entries = diaryProvider.currentMonthEntries;
          final monthNames = [
            '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
            'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
          ];

          return Column(
            children: [
              // Month Navigator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: colorScheme.surface,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => diaryProvider.navigateMonth(-1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Column(
                          children: [
                            Text(
                              monthNames[diaryProvider.selectedMonth],
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${diaryProvider.selectedYear}',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 14),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => diaryProvider.navigateMonth(1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Month Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatChip(
                          icon: Icons.movie,
                          label: 'Filmes',
                          value: '${diaryProvider.currentMonthCount}',
                        ),
                        _StatChip(
                          icon: Icons.star,
                          label: 'Média',
                          value: diaryProvider.currentMonthAverageRating > 0
                              ? diaryProvider.currentMonthAverageRating
                                  .toStringAsFixed(1)
                              : '-',
                        ),
                        _StatChip(
                          icon: Icons.replay,
                          label: 'Rewatches',
                          value: '${diaryProvider.currentMonthRewatches}',
                        ),
                        _StatChip(
                          icon: Icons.calendar_today,
                          label: 'No Ano',
                          value: '${diaryProvider.totalMoviesThisYear}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Entries List
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month,
                                size: 64,
                                color: Colors.white.withOpacity(0.15)),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum filme registrado em\n${monthNames[diaryProvider.selectedMonth]} ${diaryProvider.selectedYear}',
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final dateFormat =
                              DateFormat('dd MMM', 'pt_BR');
                          String formattedDate;
                          try {
                            formattedDate =
                                dateFormat.format(entry.watchedDate);
                          } catch (_) {
                            formattedDate =
                                '${entry.watchedDate.day}/${entry.watchedDate.month}';
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MovieDetailScreen(
                                      movieId: entry.movieId),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  // Date Column
                                  SizedBox(
                                    width: 50,
                                    child: Column(
                                      children: [
                                        Text(
                                          '${entry.watchedDate.day}',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        Text(
                                          formattedDate.split(' ').length > 1
                                              ? formattedDate.split(' ')[1]
                                              : '',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.white54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Poster
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: entry.moviePosterUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: entry.moviePosterUrl,
                                            width: 40,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 40,
                                            height: 60,
                                            color: Colors.grey[800]),
                                  ),
                                  const SizedBox(width: 12),

                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.movieTitle,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (entry.hasRating)
                                              ...List.generate(5, (i) {
                                                return Icon(
                                                  Icons.star_rounded,
                                                  size: 14,
                                                  color: i < entry.rating
                                                      ? Colors.orange
                                                      : Colors.white24,
                                                );
                                              }),
                                            if (entry.isRewatch) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 6,
                                                    vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(4),
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.replay,
                                                        size: 10,
                                                        color:
                                                            Colors.blue),
                                                    SizedBox(width: 2),
                                                    Text('Rewatch',
                                                        style: TextStyle(
                                                            fontSize: 9,
                                                            color: Colors
                                                                .blue)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (entry.hasReview) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            entry.reviewText,
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white54),
                                          ),
                                        ],
                                        if (entry.tags.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 4,
                                            children: entry.tags.map((t) {
                                              return Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 6,
                                                    vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(4),
                                                ),
                                                child: Text(
                                                  '#$t',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors
                                                          .orange[300]),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Delete button
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.white24),
                                    onPressed: () {
                                      diaryProvider
                                          .deleteEntry(entry.id);
                                    },
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: () => LogMovieDialog.show(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
