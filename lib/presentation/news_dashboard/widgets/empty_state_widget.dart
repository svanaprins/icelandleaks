import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onSubmitTip;

  const EmptyStateWidget({
    super.key,
    required this.onSubmitTip,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: CustomIconWidget(
                iconName: 'article',
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 60,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'No News Available',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.textHighEmphasisDark
                    : AppTheme.textHighEmphasisLight,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Stay informed about Icelandic political transparency. Be the first to know when breaking news arrives.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppTheme.textMediumEmphasisDark
                    : AppTheme.textMediumEmphasisLight,
                height: 1.5,
              ),
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: onSubmitTip,
              icon: CustomIconWidget(
                iconName: 'tips_and_updates',
                color: Colors.white,
                size: 20,
              ),
              label: const Text('Submit Anonymous Tip'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextButton(
              onPressed: () {
                // Refresh action
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'refresh',
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Refresh Feed',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
