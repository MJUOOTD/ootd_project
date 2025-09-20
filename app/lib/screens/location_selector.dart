import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';

class LocationSelector extends ConsumerStatefulWidget {
  const LocationSelector({super.key});

  @override
  ConsumerState<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends ConsumerState<LocationSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  // 주요 도시 목록 (실제로는 지오코딩 API 사용)
  final List<Map<String, dynamic>> _popularCities = [
    {'name': '서울', 'lat': 37.5665, 'lon': 126.9780, 'country': '대한민국'},
    {'name': '부산', 'lat': 35.1796, 'lon': 129.0756, 'country': '대한민국'},
    {'name': '대구', 'lat': 35.8714, 'lon': 128.6014, 'country': '대한민국'},
    {'name': '인천', 'lat': 37.4563, 'lon': 126.7052, 'country': '대한민국'},
    {'name': '광주', 'lat': 35.1595, 'lon': 126.8526, 'country': '대한민국'},
    {'name': '대전', 'lat': 36.3504, 'lon': 127.3845, 'country': '대한민국'},
    {'name': '울산', 'lat': 35.5384, 'lon': 129.3114, 'country': '대한민국'},
    {'name': '세종', 'lat': 36.4800, 'lon': 127.2890, 'country': '대한민국'},
  ];

  @override
  void initState() {
    super.initState();
    _searchResults = _popularCities;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '위치 선택',
          style: TextStyle(
            color: Color(0xFF030213),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF030213)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '도시명을 검색하세요',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF666666)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF666666)),
                        onPressed: () {
                          _searchController.clear();
                          _searchCities('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF030213)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _searchCities,
            ),
          ),
          
          // Current Location Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: _useCurrentLocation,
              icon: const Icon(Icons.my_location, color: Color(0xFF030213)),
              label: const Text(
                '현재 위치 사용',
                style: TextStyle(color: Color(0xFF030213)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF030213)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          // Search Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final city = _searchResults[index];
                          return _buildCityItem(city);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 키워드로 검색해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityItem(Map<String, dynamic> city) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF030213).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.location_on,
            color: Color(0xFF030213),
            size: 20,
          ),
        ),
        title: Text(
          city['name'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF030213),
          ),
        ),
        subtitle: Text(
          city['country'],
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF666666),
        ),
        onTap: () => _selectLocation(city),
      ),
    );
  }

  void _searchCities(String query) {
    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          if (query.isEmpty) {
            _searchResults = _popularCities;
          } else {
            _searchResults = _popularCities
                .where((city) => 
                    city['name'].toLowerCase().contains(query.toLowerCase()) ||
                    city['country'].toLowerCase().contains(query.toLowerCase()))
                .toList();
          }
          _isSearching = false;
        });
      }
    });
  }

  void _useCurrentLocation() async {
    try {
      final weatherProvider = ref.read(weatherProviderProvider.notifier);
      await weatherProvider.fetchCurrentWeather();
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('현재 위치의 날씨 정보를 불러왔습니다'),
            backgroundColor: Color(0xFF030213),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('위치 정보를 가져올 수 없습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectLocation(Map<String, dynamic> city) async {
    try {
      final weatherProvider = ref.read(weatherProviderProvider.notifier);
      await weatherProvider.getWeatherForLocation(
        city['lat'] as double,
        city['lon'] as double,
      );
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${city['name']}의 날씨 정보를 불러왔습니다'),
            backgroundColor: const Color(0xFF030213),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('날씨 정보를 가져올 수 없습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
