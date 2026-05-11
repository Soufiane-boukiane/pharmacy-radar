import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_pharmacies';
  late final SharedPreferences _prefs;

  FavoritesService._();
  static final FavoritesService _instance = FavoritesService._();

  factory FavoritesService() {
    return _instance;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> addFavorite(String pharmacyId) async {
    final favorites = getFavoritesSync();
    favorites.add(pharmacyId);
    await _prefs.setStringList(_favoritesKey, favorites.toList());
  }

  Future<void> removeFavorite(String pharmacyId) async {
    final favorites = getFavoritesSync();
    favorites.remove(pharmacyId);
    await _prefs.setStringList(_favoritesKey, favorites.toList());
  }

  bool isFavoriteSync(String pharmacyId) {
    return getFavoritesSync().contains(pharmacyId);
  }

  Set<String> getFavoritesSync() {
    final list = _prefs.getStringList(_favoritesKey) ?? [];
    return list.toSet();
  }

  Future<Set<String>> getFavorites() async {
    final list = _prefs.getStringList(_favoritesKey) ?? [];
    return list.toSet();
  }

  Future<void> clearFavorites() async {
    await _prefs.remove(_favoritesKey);
  }
}
