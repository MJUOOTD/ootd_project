// 최종 추천될 옷차림 정보를 담을 클래스
class OutfitData {
  final String top;
  final String bottom;
  final String outer;

  OutfitData({required this.top, required this.bottom, required this.outer});

  // Firestore 데이터를 OutfitData 객체로 변환
  factory OutfitData.fromFirestore(Map<String, dynamic> data) {
    return OutfitData(
      top: data['outfit_top'] ?? '정보 없음',
      bottom: data['outfit_bottom'] ?? '정보 없음',
      outer: data['outfit_outer'] ?? '정보 없음',
    );
  }
}