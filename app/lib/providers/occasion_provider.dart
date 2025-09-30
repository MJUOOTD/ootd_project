import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 추천에 사용할 occasion(영문) 전역 상태
/// 기본값은 'casual'
final selectedOccasionProvider = StateProvider<String>((ref) => 'casual');


