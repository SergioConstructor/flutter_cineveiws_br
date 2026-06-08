import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/local_storage_service.dart';

class DiaryProvider extends ChangeNotifier {
  final LocalStorageService _storageService;

  List<DiaryEntry> _entries = [];
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  bool _isLoading = false;

  DiaryProvider(this._storageService);

  List<DiaryEntry> get entries => _entries;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;

  List<DiaryEntry> get currentMonthEntries {
    return _entries
        .where((e) =>
            e.watchedDate.year == _selectedYear &&
            e.watchedDate.month == _selectedMonth)
        .toList()
      ..sort((a, b) => b.watchedDate.compareTo(a.watchedDate));
  }

  List<DiaryEntry> get allEntriesSorted {
    return List<DiaryEntry>.from(_entries)
      ..sort((a, b) => b.watchedDate.compareTo(a.watchedDate));
  }

  int get currentMonthCount => currentMonthEntries.length;

  double get currentMonthAverageRating {
    final rated = currentMonthEntries.where((e) => e.hasRating).toList();
    if (rated.isEmpty) return 0;
    return rated.map((e) => e.rating).reduce((a, b) => a + b) / rated.length;
  }

  int get currentMonthRewatches {
    return currentMonthEntries.where((e) => e.isRewatch).length;
  }

  int get totalMoviesThisYear {
    return _entries.where((e) => e.watchedDate.year == _selectedYear).length;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _entries = await _storageService.getDiaryEntries();

    _isLoading = false;
    notifyListeners();
  }

  void navigateMonth(int direction) {
    _selectedMonth += direction;
    if (_selectedMonth > 12) {
      _selectedMonth = 1;
      _selectedYear++;
    } else if (_selectedMonth < 1) {
      _selectedMonth = 12;
      _selectedYear--;
    }
    notifyListeners();
  }

  Future<void> addEntry(DiaryEntry entry) async {
    _entries.add(entry);
    await _storageService.saveDiaryEntries(_entries);
    notifyListeners();
  }

  Future<void> updateEntry(DiaryEntry updatedEntry) async {
    final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      _entries[index] = updatedEntry;
      await _storageService.saveDiaryEntries(_entries);
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String entryId) async {
    _entries.removeWhere((e) => e.id == entryId);
    await _storageService.saveDiaryEntries(_entries);
    notifyListeners();
  }
}
