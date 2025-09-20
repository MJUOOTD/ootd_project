import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_providers.dart';
import '../../../theme/app_theme.dart';

class WeatherMessageBanner extends ConsumerWidget {
  const WeatherMessageBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final message = ref.watch(weatherMessageProvider);
    final isLoading = ref.watch(isLoadingProvider);

    if (isLoading) {
      return _buildLoadingBanner(theme);
    }

    if (message == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _getMessageGradient(message.type, theme),
        borderRadius: AppTheme.borderRadiusAll,
        border: Border.all(
          color: _getMessageBorderColor(message.type, theme),
        ),
        boxShadow: [
          BoxShadow(
            color: _getMessageShadowColor(message.type, theme),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getMessageIconBackgroundColor(message.type, theme),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                message.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMessageTitle(message.type),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: _getMessageTextColor(message.type, theme),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _getMessageTextColor(message.type, theme).withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Close button
          IconButton(
            onPressed: () {
              // TODO: Dismiss message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('메시지 닫기 기능 준비 중')),
              );
            },
            icon: Icon(
              Icons.close,
              size: 18,
              color: _getMessageTextColor(message.type, theme).withOpacity(0.7),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppTheme.borderRadiusAll,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getMessageGradient(String type, ThemeData theme) {
    switch (type) {
      case 'warning':
        return LinearGradient(
          colors: [
            theme.colorScheme.error.withOpacity(0.1),
            theme.colorScheme.error.withOpacity(0.05),
          ],
        );
      case 'info':
        return LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
        );
      case 'tip':
        return LinearGradient(
          colors: [
            theme.colorScheme.secondary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        );
      default:
        return LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface,
          ],
        );
    }
  }

  Color _getMessageBorderColor(String type, ThemeData theme) {
    switch (type) {
      case 'warning':
        return theme.colorScheme.error.withOpacity(0.3);
      case 'info':
        return theme.colorScheme.primary.withOpacity(0.3);
      case 'tip':
        return theme.colorScheme.secondary.withOpacity(0.3);
      default:
        return theme.colorScheme.outline.withOpacity(0.2);
    }
  }

  Color _getMessageShadowColor(String type, ThemeData theme) {
    switch (type) {
      case 'warning':
        return theme.colorScheme.error.withOpacity(0.1);
      case 'info':
        return theme.colorScheme.primary.withOpacity(0.1);
      case 'tip':
        return theme.colorScheme.secondary.withOpacity(0.1);
      default:
        return theme.colorScheme.shadow.withOpacity(0.1);
    }
  }

  Color _getMessageIconBackgroundColor(String type, ThemeData theme) {
    switch (type) {
      case 'warning':
        return theme.colorScheme.error.withOpacity(0.2);
      case 'info':
        return theme.colorScheme.primary.withOpacity(0.2);
      case 'tip':
        return theme.colorScheme.secondary.withOpacity(0.2);
      default:
        return theme.colorScheme.outline.withOpacity(0.1);
    }
  }

  Color _getMessageTextColor(String type, ThemeData theme) {
    switch (type) {
      case 'warning':
        return theme.colorScheme.error;
      case 'info':
        return theme.colorScheme.primary;
      case 'tip':
        return theme.colorScheme.onSurface;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  String _getMessageTitle(String type) {
    switch (type) {
      case 'warning':
        return '주의사항';
      case 'info':
        return '날씨 정보';
      case 'tip':
        return '팁';
      default:
        return '알림';
    }
  }
}

