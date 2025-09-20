import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/outfit_model.dart';
import '../models/weather_model.dart';
import '../models/user_model.dart';
import '../models/feedback_model.dart';
import '../services/feedback_service.dart';

class FeedbackSheet extends ConsumerStatefulWidget {
  final List<OutfitRecommendation> recommendations;
  final WeatherModel weather;
  final UserModel user;

  const FeedbackSheet({
    super.key,
    required this.recommendations,
    required this.weather,
    required this.user,
  });

  @override
  ConsumerState<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends ConsumerState<FeedbackSheet> {
  OutfitRecommendation? _selectedOutfit;
  FeedbackType? _selectedFeedback;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                '피드백 남기기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF030213),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Step 1: Outfit Selection
          _buildOutfitSelection(),
          
          const SizedBox(height: 24),
          
          // Step 2: Temperature Feedback (only if outfit selected)
          if (_selectedOutfit != null) _buildTemperatureFeedback(),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildOutfitSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. 추천받은 옷차림 중 착용하신 옷차림을 선택해주세요',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF030213),
          ),
        ),
        const SizedBox(height: 16),
        
        // Outfit Options
        ...widget.recommendations.map((recommendation) => 
          _buildOutfitOption(recommendation)
        ).toList(),
        
        const SizedBox(height: 16),
        
        // "입지 않았어요" Option
        _buildNotWornOption(),
      ],
    );
  }

  Widget _buildOutfitOption(OutfitRecommendation recommendation) {
    final isSelected = _selectedOutfit?.outfit.id == recommendation.outfit.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedOutfit = recommendation;
            _selectedFeedback = null; // Reset feedback when changing outfit
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? const Color(0xFF030213) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? const Color(0xFF030213).withOpacity(0.05) : Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.checkroom, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.outfit.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF030213) : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation.outfit.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? const Color(0xFF666666) : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF030213),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotWornOption() {
    final isSelected = _selectedOutfit == null;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedOutfit = null;
          _selectedFeedback = null;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF030213) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? const Color(0xFF030213).withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              Icons.close,
              color: isSelected ? const Color(0xFF030213) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '추천받은 옷을 입지 않았어요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF030213) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF030213),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureFeedback() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. 착용하신 옷차림의 체감 온도는 어땠나요?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF030213),
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            _buildFeedbackOption(FeedbackType.cold, '추웠어요', Icons.ac_unit),
            const SizedBox(width: 12),
            _buildFeedbackOption(FeedbackType.perfect, '적당했어요', Icons.check_circle),
            const SizedBox(width: 12),
            _buildFeedbackOption(FeedbackType.hot, '더웠어요', Icons.wb_sunny),
          ],
        ),
      ],
    );
  }

  Widget _buildFeedbackOption(FeedbackType type, String label, IconData icon) {
    final isSelected = _selectedFeedback == type;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFeedback = type;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? const Color(0xFF030213) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? const Color(0xFF030213).withOpacity(0.05) : Colors.white,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF030213) : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF030213) : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final canSubmit = _selectedOutfit != null ? _selectedFeedback != null : true;
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF030213)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '나중에 할래요',
              style: TextStyle(
                color: Color(0xFF030213),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: canSubmit && !_isLoading ? _submitFeedback : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF030213),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '피드백 제출',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitFeedback() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Submit feedback to backend
      final success = await FeedbackService.submitFeedback(
        userId: widget.user.id,
        outfitId: _selectedOutfit?.outfit.id ?? 'not_worn',
        feedbackType: _selectedFeedback ?? FeedbackType.perfect,
        weather: widget.weather,
        user: widget.user,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('피드백이 저장되었습니다. 감사합니다!'),
            backgroundColor: Color(0xFF030213),
          ),
        );
        Navigator.of(context).pop();
      } else {
        throw Exception('피드백 저장에 실패했습니다.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
