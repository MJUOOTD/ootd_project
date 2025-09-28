import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'kakao_api_service.dart';

/// 즐겨찾기 도시 관리 서비스
class FavoritesService {
  static const String _favoritesKey = 'favorite_cities';
  static List<PlaceInfo> _favorites = [];
  static final List<Function()> _listeners = [];

  /// 즐겨찾기 목록 초기화
  static Future<void> initialize() async {
    await _loadFavorites();
  }

  /// 즐겨찾기 목록 가져오기
  static List<PlaceInfo> get favorites => List.unmodifiable(_favorites);

  /// 변경 리스너 추가
  static void addListener(Function() listener) {
    _listeners.add(listener);
  }

  /// 변경 리스너 제거
  static void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  /// 모든 리스너에게 변경 알림
  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// 즐겨찾기에 도시 추가
  static Future<bool> addFavorite(PlaceInfo place) async {
    if (_favorites.any((fav) => fav.id == place.id)) {
      return false; // 이미 존재
    }

    _favorites.add(place);
    await _saveFavorites();
    _notifyListeners();
    return true;
  }

  /// 즐겨찾기에서 도시 제거
  static Future<bool> removeFavorite(String placeId) async {
    final initialLength = _favorites.length;
    _favorites.removeWhere((fav) => fav.id == placeId);

    if (_favorites.length < initialLength) {
      await _saveFavorites();
      _notifyListeners();
      return true;
    }
    return false;
  }

  /// 즐겨찾기 여부 확인
  static bool isFavorite(String placeId) {
    return _favorites.any((fav) => fav.id == placeId);
  }

  /// 즐겨찾기 토글
  static Future<bool> toggleFavorite(PlaceInfo place) async {
    if (isFavorite(place.id)) {
      return await removeFavorite(place.id);
    } else {
      return await addFavorite(place);
    }
  }

  /// 즐겨찾기 목록 저장
  static Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favorites.map((fav) => fav.toJson()).toList();
      await prefs.setString(_favoritesKey, json.encode(favoritesJson));
      print('[FavoritesService] Saved ${_favorites.length} favorites');
    } catch (e) {
      print('[FavoritesService] Error saving favorites: $e');
    }
  }

  /// 즐겨찾기 목록 로드
  static Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = prefs.getString(_favoritesKey);
      
      if (favoritesString != null) {
        final List<dynamic> favoritesJson = json.decode(favoritesString);
        _favorites = favoritesJson.map((json) => PlaceInfo.fromJson(json)).toList();
        print('[FavoritesService] Loaded ${_favorites.length} favorites');
      } else {
        // 기본 즐겨찾기 도시 추가
        _favorites = [
          PlaceInfo(
            id: 'seoul',
            placeName: '서울특별시',
            addressName: '서울특별시',
            roadAddressName: '서울특별시',
            categoryName: '지역',
            latitude: 37.5665,
            longitude: 126.9780,
          ),
        ];
        await _saveFavorites();
      }
    } catch (e) {
      print('[FavoritesService] Error loading favorites: $e');
      _favorites = [];
    }
  }

}
