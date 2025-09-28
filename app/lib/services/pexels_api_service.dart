import 'dart:convert';
import 'package:http/http.dart' as http;

class PexelsApiService {
  static const String _baseUrl = 'https://api.pexels.com/v1';
  static String? _apiKey;

  // API 키 설정
  static void setApiKey(String key) {
    _apiKey = key;
  }

  // Pexels API 헤더
  static Map<String, String> get _headers {
    if (_apiKey == null) {
      throw Exception('Pexels API 키가 설정되지 않았습니다.');
    }
    return {
      'Authorization': _apiKey!,
      'Content-Type': 'application/json',
    };
  }

  // 상황별 패션 이미지 검색
  static Future<List<PexelsPhoto>> searchFashionPhotos({
    required String situation,
    int perPage = 20,
  }) async {
    try {
      // 상황별 검색 키워드 매핑
      final searchQuery = _getSearchQuery(situation);
      
      final url = Uri.parse(
        '$_baseUrl/search?query=$searchQuery&per_page=$perPage&orientation=portrait'
      );

      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parsePhotosFromResponse(data);
      } else {
        throw Exception('Pexels API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      return _getMockPhotos(situation);
    }
  }

  // 인기 패션 이미지 가져오기
  static Future<List<PexelsPhoto>> getPopularFashionPhotos({
    int perPage = 20,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/curated?per_page=$perPage&orientation=portrait'
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parsePhotosFromResponse(data);
      }
      
      return _getMockPhotos('일반');
    } catch (e) {
      return _getMockPhotos('일반');
    }
  }

  // 상황별 검색 쿼리 생성
  static String _getSearchQuery(String situation) {
    switch (situation) {
      case '출근':
        return 'business outfit professional work fashion office';
      case '데이트':
        return 'date night outfit romantic fashion couple';
      case '운동':
        return 'workout outfit gym fashion sportswear fitness';
      case '여행':
        return 'travel outfit vacation fashion casual';
      default:
        return 'fashion outfit style clothing';
    }
  }

  // API 응답에서 사진 데이터 파싱
  static List<PexelsPhoto> _parsePhotosFromResponse(Map<String, dynamic> data) {
    final List<dynamic> photos = data['photos'] ?? [];
    return photos.map((photo) => PexelsPhoto.fromJson(photo)).toList();
  }

  // API 실패 시 사용할 모의 데이터
  static List<PexelsPhoto> _getMockPhotos(String situation) {
    switch (situation) {
      case '출근':
        return [
          PexelsPhoto(
            id: 1,
            photographer: 'Business Fashion',
            photographerUrl: 'https://pexels.com/@business',
            src: PexelsPhotoSrc(
              original: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              large2x: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              large: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              medium: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=300',
              small: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=200',
              portrait: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=300',
              landscape: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              tiny: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=100',
            ),
            alt: 'Professional business outfit',
            rating: 4.8,
            tags: ['프로페셔널', '깔끔한'],
          ),
          PexelsPhoto(
            id: 2,
            photographer: 'Office Style',
            photographerUrl: 'https://pexels.com/@office',
            src: PexelsPhotoSrc(
              original: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              large2x: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              large: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              medium: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=300',
              small: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=200',
              portrait: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=300',
              landscape: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              tiny: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=100',
            ),
            alt: 'Business casual style',
            rating: 4.6,
            tags: ['프로페셔널', '깔끔한'],
          ),
        ];
      case '데이트':
        return [
          PexelsPhoto(
            id: 3,
            photographer: 'Romantic Fashion',
            photographerUrl: 'https://pexels.com/@romantic',
            src: PexelsPhotoSrc(
              original: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              large2x: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              large: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              medium: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=300',
              small: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=200',
              portrait: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=300',
              landscape: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              tiny: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=100',
            ),
            alt: 'Romantic date night outfit',
            rating: 4.9,
            tags: ['우아한', '로맨틱'],
          ),
        ];
      case '운동':
        return [
          PexelsPhoto(
            id: 4,
            photographer: 'Fitness Fashion',
            photographerUrl: 'https://pexels.com/@fitness',
            src: PexelsPhotoSrc(
              original: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              large2x: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              large: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              medium: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=300',
              small: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=200',
              portrait: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=300',
              landscape: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              tiny: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=100',
            ),
            alt: 'Gym workout outfit',
            rating: 4.7,
            tags: ['편안한', '기능성'],
          ),
        ];
      case '여행':
        return [
          PexelsPhoto(
            id: 5,
            photographer: 'Travel Fashion',
            photographerUrl: 'https://pexels.com/@travel',
            src: PexelsPhotoSrc(
              original: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              large2x: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              large: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              medium: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=300',
              small: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=200',
              portrait: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=300',
              landscape: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
              tiny: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=100',
            ),
            alt: 'Travel adventure outfit',
            rating: 4.8,
            tags: ['편안한', '실용적'],
          ),
        ];
      default:
        return [];
    }
  }
}

// Pexels 사진 데이터 모델
class PexelsPhoto {
  final int id;
  final String alt;
  final String photographer;
  final String photographerUrl;
  final PexelsPhotoSrc src;
  final double rating;
  final List<String> tags;

  PexelsPhoto({
    required this.id,
    required this.alt,
    required this.photographer,
    required this.photographerUrl,
    required this.src,
    required this.rating,
    required this.tags,
  });

  factory PexelsPhoto.fromJson(Map<String, dynamic> json) {
    return PexelsPhoto(
      id: json['id'] ?? 0,
      alt: json['alt'] ?? '',
      photographer: json['photographer'] ?? '',
      photographerUrl: json['photographer_url'] ?? '',
      src: PexelsPhotoSrc.fromJson(json['src'] ?? {}),
      rating: (json['rating'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photographer': photographer,
      'photographer_url': photographerUrl,
      'src': src.toJson(),
      'alt': alt,
      'rating': rating,
      'tags': tags,
    };
  }
}

// Pexels 사진 소스 데이터 모델
class PexelsPhotoSrc {
  final String original;
  final String large2x;
  final String large;
  final String medium;
  final String small;
  final String portrait;
  final String landscape;
  final String tiny;

  PexelsPhotoSrc({
    required this.original,
    required this.large2x,
    required this.large,
    required this.medium,
    required this.small,
    required this.portrait,
    required this.landscape,
    required this.tiny,
  });

  factory PexelsPhotoSrc.fromJson(Map<String, dynamic> json) {
    return PexelsPhotoSrc(
      original: json['original'] ?? '',
      large2x: json['large2x'] ?? '',
      large: json['large'] ?? '',
      medium: json['medium'] ?? '',
      small: json['small'] ?? '',
      portrait: json['portrait'] ?? '',
      landscape: json['landscape'] ?? '',
      tiny: json['tiny'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original': original,
      'large2x': large2x,
      'large': large,
      'medium': medium,
      'small': small,
      'portrait': portrait,
      'landscape': landscape,
      'tiny': tiny,
    };
  }
}