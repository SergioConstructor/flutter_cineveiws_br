import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';
import '../models/user_profile.dart';
import '../models/movie_list.dart';
import '../models/diary_entry.dart';

class LocalStorageService {
  static const String _reviewsKey = 'cineview_reviews';
  static const String _profilesKey = 'cineview_profiles';
  static const String _currentUserKey = 'cineview_current_user';
  static const String _listsKey = 'cineview_lists';
  static const String _diaryKey = 'cineview_diary';
  static const String _watchedKey = 'cineview_watched';
  static const String _watchlistKey = 'cineview_watchlist';
  static const String _initializedKey = 'cineview_initialized';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isInitialized => _prefs.getBool(_initializedKey) ?? false;
  Future<void> markInitialized() async =>
      await _prefs.setBool(_initializedKey, true);

  // ─── Reviews ───

  Future<List<Review>> getReviews() async {
    final data = _prefs.getString(_reviewsKey);
    if (data == null) return [];
    return Review.listFromJsonString(data);
  }

  Future<void> saveReviews(List<Review> reviews) async {
    await _prefs.setString(_reviewsKey, Review.listToJsonString(reviews));
  }

  // ─── User Profiles ───

  Future<List<UserProfile>> getProfiles() async {
    final data = _prefs.getString(_profilesKey);
    if (data == null) return [];
    return UserProfile.listFromJsonString(data);
  }

  Future<void> saveProfiles(List<UserProfile> profiles) async {
    await _prefs.setString(
        _profilesKey, UserProfile.listToJsonString(profiles));
  }

  Future<UserProfile?> getCurrentUser() async {
    final data = _prefs.getString(_currentUserKey);
    if (data == null) return null;
    return UserProfile.fromJson(jsonDecode(data));
  }

  Future<void> saveCurrentUser(UserProfile user) async {
    await _prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  // ─── Movie Lists ───

  Future<List<MovieList>> getLists() async {
    final data = _prefs.getString(_listsKey);
    if (data == null) return [];
    return MovieList.listFromJsonString(data);
  }

  Future<void> saveLists(List<MovieList> lists) async {
    await _prefs.setString(_listsKey, MovieList.listToJsonString(lists));
  }

  // ─── Diary ───

  Future<List<DiaryEntry>> getDiaryEntries() async {
    final data = _prefs.getString(_diaryKey);
    if (data == null) return [];
    return DiaryEntry.listFromJsonString(data);
  }

  Future<void> saveDiaryEntries(List<DiaryEntry> entries) async {
    await _prefs.setString(_diaryKey, DiaryEntry.listToJsonString(entries));
  }

  // ─── Watched / Watchlist ───

  Future<Set<int>> getWatchedMovieIds() async {
    final data = _prefs.getStringList(_watchedKey);
    if (data == null) return {};
    return data.map((e) => int.parse(e)).toSet();
  }

  Future<void> saveWatchedMovieIds(Set<int> ids) async {
    await _prefs.setStringList(
        _watchedKey, ids.map((e) => e.toString()).toList());
  }

  Future<Set<int>> getWatchlistMovieIds() async {
    final data = _prefs.getStringList(_watchlistKey);
    if (data == null) return {};
    return data.map((e) => int.parse(e)).toSet();
  }

  Future<void> saveWatchlistMovieIds(Set<int> ids) async {
    await _prefs.setStringList(
        _watchlistKey, ids.map((e) => e.toString()).toList());
  }

  // ─── Clear All ───

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
