import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NewsCardWidget extends StatelessWidget {
  final Map<String, dynamic> article;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  const NewsCardWidget({
    super.key,
    required this.article,
    this.onTap,
    this.onBookmark,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildContentSection(isDark),
            _buildActionSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Stack(
        children: [
          CustomImageWidget(
            imageUrl: article['imageUrl'] as String? ?? '',
            width: double.infinity,
            height: 25.h,
            fit: BoxFit.cover,
          ),
          if (article['isTrending'] == true)
            Positioned(
              top: 2.h,
              right: 3.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'trending_up',
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Trending',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentSection(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSourceBadge(isDark),
              const Spacer(),
              _buildCredibilityRating(),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            article['headline'] as String? ?? '',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppTheme.textHighEmphasisDark
                  : AppTheme.textHighEmphasisLight,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Text(
            article['summary'] as String? ?? '',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark
                  ? AppTheme.textMediumEmphasisDark
                  : AppTheme.textMediumEmphasisLight,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'access_time',
                color: isDark
                    ? AppTheme.textMediumEmphasisDark
                    : AppTheme.textMediumEmphasisLight,
                size: 14,
              ),
              SizedBox(width: 1.w),
              Text(
                _formatTimestamp(article['timestamp']),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark
                      ? AppTheme.textMediumEmphasisDark
                      : AppTheme.textMediumEmphasisLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceBadge(bool isDark) {
    final String source = article['source'] as String? ?? '';
    Color badgeColor;

    switch (source.toLowerCase()) {
      case 'rúv':
        badgeColor = const Color(0xFF1B365D);
        break;
      case 'stundin':
        badgeColor = const Color(0xFF4A90A4);
        break;
      case 'dv':
        badgeColor = const Color(0xFFD32F2F);
        break;
      default:
        badgeColor = isDark
            ? AppTheme.textMediumEmphasisDark
            : AppTheme.textMediumEmphasisLight;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        source,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildCredibilityRating() {
    final int rating = article['credibilityRating'] as int? ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return CustomIconWidget(
          iconName: index < rating ? 'star' : 'star_border',
          color: index < rating
              ? AppTheme.warningLight
              : AppTheme.textDisabledLight,
          size: 14,
        );
      }),
    );
  }

  Widget _buildActionSection(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: 'bookmark_border',
            label: 'Save',
            onTap: onBookmark,
            isDark: isDark,
          ),
          SizedBox(width: 6.w),
          _buildActionButton(
            icon: 'share',
            label: 'Share',
            onTap: onShare,
            isDark: isDark,
          ),
          const Spacer(),
          Text(
            '${article['readTime'] ?? 3} min read',
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark
                  ? AppTheme.textMediumEmphasisDark
                  : AppTheme.textMediumEmphasisLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: isDark
                ? AppTheme.textMediumEmphasisDark
                : AppTheme.textMediumEmphasisLight,
            size: 16,
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark
                  ? AppTheme.textMediumEmphasisDark
                  : AppTheme.textMediumEmphasisLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'report',
                color: AppTheme.accentLight,
                size: 24,
              ),
              title: const Text('Report Content'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility_off',
                color: AppTheme.textMediumEmphasisLight,
                size: 24,
              ),
              title: const Text('Hide Source'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'research',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              title: const Text('Add to Research'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime dateTime;
    if (timestamp is DateTime) {
      dateTime = timestamp;
    } else if (timestamp is String) {
      dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
