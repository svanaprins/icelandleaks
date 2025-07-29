import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class TipPreferencesWidget extends StatelessWidget {
  final bool enableTracking;
  final bool enableFollowUp;
  final Function(bool) onTrackingChanged;
  final Function(bool) onFollowUpChanged;

  const TipPreferencesWidget({
    Key? key,
    required this.enableTracking,
    required this.enableFollowUp,
    required this.onTrackingChanged,
    required this.onFollowUpChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Submission Preferences',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildPreferenceItem(
                icon: 'track_changes',
                title: 'Enable Tip Tracking',
                subtitle:
                    'Generate an anonymous ID to track your tip\'s progress',
                value: enableTracking,
                onChanged: onTrackingChanged,
                iconColor: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                height: 1,
              ),
              SizedBox(height: 2.h),
              _buildPreferenceItem(
                icon: 'forum',
                title: 'Allow Follow-up Communication',
                subtitle:
                    'Receive anonymous updates about your tip via secure channel',
                value: enableFollowUp,
                onChanged: onFollowUpChanged,
                iconColor: AppTheme.getSuccessColor(true),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Your identity remains completely anonymous regardless of these settings. All communication uses end-to-end encryption.',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: iconColor,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: iconColor,
        ),
      ],
    );
  }
}
