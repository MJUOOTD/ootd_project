import 'dart:convert';
import 'package:http/http.dart' as http;

class PinterestApiService {
  static const String _baseUrl = 'https://api.pinterest.com/v5';
  static String? _accessToken;

  // 액세스 토큰 설정
  static void setAccessToken(String token) {
    _accessToken = token;
  }

  // Pinterest API 헤더
  static Map<String, String> get _headers {
    if (_accessToken == null) {
      throw Exception('Pinterest 액세스 토큰이 설정되지 않았습니다.');
    }
    return {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };
  }

  // 상황별 패션 핀 검색
  static Future<List<PinterestPin>> searchFashionPins({
    required String situation,
    int limit = 20,
  }) async {
    try {
      // 상황별 검색 키워드 매핑
      final searchQuery = _getSearchQuery(situation);
      
      final url = Uri.parse(
        '$_baseUrl/search/pins?query=$searchQuery&limit=$limit'
      );

      final response = await http.get(url, headers: _headers);

      print('Pinterest API 응답 상태: ${response.statusCode}');
      print('Pinterest API 응답 본문: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('파싱된 데이터: $data');
        return _parsePinsFromResponse(data);
      } else {
        print('Pinterest API 오류 응답: ${response.body}');
        throw Exception('Pinterest API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('Pinterest API 오류: $e');
      return _getMockPins(situation);
    }
  }

  // 사용자 보드에서 패션 핀 가져오기
  static Future<List<PinterestPin>> getUserFashionPins({
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/user_account');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final userId = userData['id'];
        
        // 사용자의 핀 가져오기
        final pinsUrl = Uri.parse('$_baseUrl/users/$userId/pins?limit=$limit');
        final pinsResponse = await http.get(pinsUrl, headers: _headers);
        
        if (pinsResponse.statusCode == 200) {
          final pinsData = json.decode(pinsResponse.body);
          return _parsePinsFromResponse(pinsData);
        }
      }
      
      return _getMockPins('일반');
    } catch (e) {
      print('사용자 핀 가져오기 오류: $e');
      return _getMockPins('일반');
    }
  }

  // 상황별 검색 쿼리 생성
  static String _getSearchQuery(String situation) {
    switch (situation) {
      case '출근':
        return 'business outfit professional work fashion';
      case '데이트':
        return 'date night outfit romantic fashion';
      case '운동':
        return 'workout outfit gym fashion sportswear';
      case '여행':
        return 'travel outfit vacation fashion';
      default:
        return 'fashion outfit style';
    }
  }

  // API 응답에서 핀 데이터 파싱
  static List<PinterestPin> _parsePinsFromResponse(Map<String, dynamic> data) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) => PinterestPin.fromJson(item)).toList();
  }

  // API 실패 시 사용할 모의 데이터
  static List<PinterestPin> _getMockPins(String situation) {
    switch (situation) {
      case '출근':
        return [
          PinterestPin(
            id: '1',
            title: 'Professional Business Look',
            description: 'Clean and sophisticated office outfit',
            imageUrl: 'https://via.placeholder.com/300x400/4A90E2/FFFFFF?text=Business+Look',
            link: 'https://pinterest.com/pin/1',
            rating: 4.8,
            tags: ['프로페셔널', '깔끔한'],
          ),
          PinterestPin(
            id: '2',
            title: 'Business Casual Style',
            description: 'Modern office wear for professionals',
            imageUrl: 'https://via.placeholder.com/300x400/7ED321/FFFFFF?text=Casual+Business',
            link: 'https://pinterest.com/pin/2',
            rating: 4.6,
            tags: ['프로페셔널', '깔끔한'],
          ),
        ];
      case '데이트':
        return [
          PinterestPin(
            id: '3',
            title: 'Romantic Date Night',
            description: 'Elegant and charming date outfit',
            imageUrl: 'https://via.placeholder.com/300x400/F5A623/FFFFFF?text=Date+Night',
            link: 'https://pinterest.com/pin/3',
            rating: 4.9,
            tags: ['우아한', '로맨틱'],
          ),
        ];
      case '운동':
        return [
          PinterestPin(
            id: '4',
            title: 'Gym Workout Outfit',
            description: 'Comfortable and functional sportswear',
            imageUrl: 'https://via.placeholder.com/300x400/BD10E0/FFFFFF?text=Gym+Outfit',
            link: 'https://pinterest.com/pin/4',
            rating: 4.7,
            tags: ['편안한', '기능성'],
          ),
        ];
      case '여행':
        return [
          PinterestPin(
            id: '5',
            title: 'Travel Adventure Look',
            description: 'Practical and stylish travel outfit',
            imageUrl: 'https://via.placeholder.com/300x400/50E3C2/FFFFFF?text=Travel+Look',
            link: 'https://pinterest.com/pin/5',
            rating: 4.8,
            tags: ['편안한', '실용적'],
          ),
        ];
      default:
        return [];
    }
  }
}

// Pinterest 핀 데이터 모델
class PinterestPin {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String link;
  final double rating;
  final List<String> tags;

  PinterestPin({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
    required this.rating,
    required this.tags,
  });

  factory PinterestPin.fromJson(Map<String, dynamic> json) {
    return PinterestPin(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Fashion Pin',
      description: json['description'] ?? '',
      imageUrl: json['media']?['images']?['564x']?['url'] ?? 
                json['media']?['images']?['originals']?['url'] ?? 
                'https://via.placeholder.com/300x400',
      link: json['link'] ?? '',
      rating: 4.0 + ((json['id']?.hashCode ?? 0) % 10) / 10, // 임시 평점 생성
      tags: _extractTags(json['title'] ?? ''),
    );
  }

  // 제목에서 태그 추출
  static List<String> _extractTags(String title) {
    final List<String> tags = [];
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('business') || lowerTitle.contains('professional')) {
      tags.addAll(['프로페셔널', '깔끔한']);
    }
    if (lowerTitle.contains('casual') || lowerTitle.contains('relaxed')) {
      tags.addAll(['편안한', '캐주얼']);
    }
    if (lowerTitle.contains('romantic') || lowerTitle.contains('date')) {
      tags.addAll(['우아한', '로맨틱']);
    }
    if (lowerTitle.contains('workout') || lowerTitle.contains('gym')) {
      tags.addAll(['편안한', '기능성']);
    }
    if (lowerTitle.contains('travel') || lowerTitle.contains('vacation')) {
      tags.addAll(['편안한', '실용적']);
    }
    
    return tags.isNotEmpty ? tags : ['스타일리시'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'link': link,
      'rating': rating,
      'tags': tags,
    };
  }
}
