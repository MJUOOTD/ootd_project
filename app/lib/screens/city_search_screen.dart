import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/kakao_api_service.dart';
import '../services/favorites_service.dart';
import '../providers/weather_provider.dart';

class CitySearchScreen extends ConsumerStatefulWidget {
  const CitySearchScreen({super.key});

  @override
  ConsumerState<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends ConsumerState<CitySearchScreen> {
  final _searchController = TextEditingController();
  List<PlaceInfo> _searchResults = [];
  List<PlaceInfo> _favorites = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _favorites = FavoritesService.favorites;
    });
    
    // 기본 도시 목록도 로드
    _loadDefaultCities();
  }

  void _loadDefaultCities() {
    // 기본 도시 목록 제거 - 검색 시에만 결과 표시
    setState(() {
      _searchResults = [];
    });
  }

  Future<void> _searchCities(String query) async {
    if (query.trim().isEmpty) {
      _loadDefaultCities();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await KakaoApiService.searchPlaces(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('[CitySearchScreen] Search error: $e');
      // API 오류 시 기본 도시 목록 표시
      _loadDefaultCities();
    }
  }

  Future<void> _toggleFavorite(PlaceInfo place) async {
    final wasFavorite = FavoritesService.isFavorite(place.id);
    await FavoritesService.toggleFavorite(place);
    await _loadFavorites();
    setState(() {}); // UI 업데이트
    
    // 피드백 메시지 표시
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasFavorite 
                ? '${place.placeName}을(를) 즐겨찾기에서 제거했습니다'
                : '${place.placeName}을(를) 즐겨찾기에 추가했습니다',
          ),
          backgroundColor: wasFavorite ? Colors.orange : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _selectCity(PlaceInfo place) async {
    try {
      // 선택한 도시의 날씨 정보 가져오기
      await ref.read(weatherProvider.notifier).getWeatherForLocation(
        place.latitude,
        place.longitude,
      );
      
      // 즐겨찾기에 추가
      await FavoritesService.addFavorite(place);
      
      // 화면 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('날씨 정보를 가져올 수 없습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '도시 검색',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // 검색 바
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '도시명을 입력하세요 (예: 서울, 부산)',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _searchResults.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                if (value.length >= 2) {
                  _searchCities(value);
                } else if (value.isEmpty) {
                  setState(() {
                    _searchResults.clear();
                  });
                }
              },
            ),
          ),
          
          // 즐겨찾기 섹션
          if (_favorites.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '즐겨찾기',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 80,
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final favorite = _favorites[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 8),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () => _selectCity(favorite),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                favorite.cityName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                favorite.districtName,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          
          // 검색 결과
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _searchCities(_searchController.text),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '도시명을 검색해주세요',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '예: 서울, 부산, 대구, 인천, 광주, 대전',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }


    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final place = _searchResults[index];
        final isFavorite = FavoritesService.isFavorite(place.id);
        
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              place.placeName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF2C3E50),
                letterSpacing: 0.5,
              ),
            ),
            subtitle: Text(
              place.addressName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _toggleFavorite(place),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isFavorite ? Colors.amber[100] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.amber[700] : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _selectCity(place),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue[700],
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () => _selectCity(place),
          ),
        );
      },
    );
  }
}
