import 'package:flutter/material.dart';
import 'dart:async';
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
  final FocusNode _searchFocusNode = FocusNode();
  List<PlaceInfo> _searchResults = [];
  List<PlaceInfo> _favorites = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _debounce;

  // 추천 도시 (자주 검색되는 도시)
  final List<PlaceInfo> _recommendedCities = [
    PlaceInfo(
      id: 'seoul',
      placeName: '서울특별시',
      addressName: '서울특별시',
      roadAddressName: '서울특별시',
      categoryName: '지역',
      latitude: 37.5665,
      longitude: 126.9780,
    ),
    PlaceInfo(
      id: 'busan',
      placeName: '부산광역시',
      addressName: '부산광역시',
      roadAddressName: '부산광역시',
      categoryName: '지역',
      latitude: 35.1796,
      longitude: 129.0756,
    ),
    PlaceInfo(
      id: 'jeju',
      placeName: '제주시',
      addressName: '제주특별자치도 제주시',
      roadAddressName: '제주특별자치도 제주시',
      categoryName: '지역',
      latitude: 33.4996,
      longitude: 126.5312,
    ),
    PlaceInfo(
      id: 'incheon',
      placeName: '인천광역시',
      addressName: '인천광역시',
      roadAddressName: '인천광역시',
      categoryName: '지역',
      latitude: 37.4563,
      longitude: 126.7052,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
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

  void _onChangedDebounced(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (value.length >= 2) {
        _searchCities(value);
      }
    });
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
    print('[CitySearchScreen] ===== SELECT CITY START =====');
    print('[CitySearchScreen] Selected place: ${place.placeName} (${place.latitude}, ${place.longitude})');
    
    try {
      // 선택한 도시의 날씨 정보 가져오기
      print('[CitySearchScreen] Calling getWeatherForLocation...');
      await ref.read(weatherProvider.notifier).getWeatherForLocation(
        place.latitude,
        place.longitude,
      );
      print('[CitySearchScreen] Weather data fetched successfully');
      
      // 즐겨찾기에 추가
      await FavoritesService.addFavorite(place);
      print('[CitySearchScreen] Added to favorites');
      
      // 상태 업데이트가 완료될 때까지 잠시 대기
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 화면 닫기
      if (mounted) {
        print('[CitySearchScreen] Closing screen...');
        Navigator.of(context).pop();
      }
      print('[CitySearchScreen] ===== SELECT CITY SUCCESS =====');
    } catch (e) {
      print('[CitySearchScreen] ===== SELECT CITY ERROR =====');
      print('[CitySearchScreen] Error: $e');
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
        elevation: 0.5,
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: '도시/구/동 검색 (카카오 주소 검색)',
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _searchResults.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF6F7FB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
              onChanged: _onChangedDebounced,
            ),
          ),
          // 현재 위치(캐시) 복원 섹션
          _buildCurrentLocationRestore(ref),
          // 자동완성 드롭다운 제안 패널
          if (_searchFocusNode.hasFocus && _searchController.text.length >= 2)
            _buildSuggestionDropdown(),
          // 빈 검색어일 때 추천 도시 섹션
          if (_searchController.text.isEmpty)
            _buildRecommendedCities(),
          
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

  Widget _buildCurrentLocationRestore(WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);
    final cached = weatherState.currentLocationCache;
    if (cached == null) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: Color(0xFF4F46E5), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '현재 위치 (마지막 업데이트) · ${cached.location.city}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
            ),
          ),
          Text('${cached.temperature.round()}°', style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => _selectCity(PlaceInfo(
              id: 'current_${cached.location.latitude}_${cached.location.longitude}',
              placeName: cached.location.city,
              addressName: cached.location.city,
              roadAddressName: cached.location.city,
              categoryName: '현재 위치(캐시)',
              latitude: cached.location.latitude,
              longitude: cached.location.longitude,
            )),
            child: const Text('복원'),
          )
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // 자동완성 사용 시 메인 리스트 감춤
    if (_searchFocusNode.hasFocus && _searchController.text.length >= 2) {
      return const SizedBox.shrink();
    }
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final place = _searchResults[index];
        final isFavorite = FavoritesService.isFavorite(place.id);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _selectCity(place),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.place_outlined, color: Color(0xFF4F46E5)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.placeName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            place.addressName,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _toggleFavorite(place),
                      icon: Icon(
                        FavoritesService.isFavorite(place.id) ? Icons.star : Icons.star_border,
                        color: FavoritesService.isFavorite(place.id) ? Colors.amber[700] : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 4),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _selectCity(place),
                      child: const Text('선택', style: TextStyle(fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionDropdown() {
    final suggestions = _searchResults.take(8).toList();

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    if (suggestions.isEmpty && _searchController.text.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('검색 결과가 없습니다', style: TextStyle(color: Colors.grey[600])),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 320),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEDEDED)),
        itemBuilder: (context, index) {
          final place = suggestions[index];
          final isFavorite = FavoritesService.isFavorite(place.id);
          return ListTile(
            dense: true,
            leading: Icon(Icons.location_on, color: Colors.blue[400], size: 20),
            title: Text(
              place.placeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              place.addressName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: IconButton(
              icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: isFavorite ? Colors.amber[700] : Colors.grey[600], size: 20),
              onPressed: () => _toggleFavorite(place),
            ),
            onTap: () => _selectCity(place),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedCities() {
    if (_recommendedCities.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.trending_up, color: Color(0xFF4F46E5), size: 18),
              SizedBox(width: 8),
              Text('추천 도시', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2C3E50))),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recommendedCities.map((city) {
              return InkWell(
                onTap: () => _selectCity(city),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_city, size: 16, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 6),
                      Text(city.placeName, style: const TextStyle(fontSize: 13, color: Color(0xFF2C3E50))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
