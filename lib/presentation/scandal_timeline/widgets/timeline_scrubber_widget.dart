import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TimelineScrubberWidget extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final int currentEventIndex;
  final Function(int) onEventSelected;

  const TimelineScrubberWidget({
    super.key,
    required this.events,
    required this.currentEventIndex,
    required this.onEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 2.w,
      top: 20.h,
      bottom: 15.h,
      child: Container(
        width: 8.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 8,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Scrubber header
            Container(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: CustomIconWidget(
                iconName: 'timeline',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ),
            // Timeline scrubber
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                child: Column(
                  children: events.asMap().entries.map((entry) {
                    final index = entry.key;
                    final event = entry.value;
                    final isSelected = index == currentEventIndex;
                    final progress =
                        events.length > 1 ? index / (events.length - 1) : 0.0;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onEventSelected(index),
                        child: Container(
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Timeline line
                              if (index < events.length - 1)
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    width: 1.w,
                                    height: 100,
                                    color: AppTheme
                                        .lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                              // Event dot
                              Container(
                                width: isSelected ? 4.w : 2.w,
                                height: isSelected ? 4.w : 2.w,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : _getSeverityColor(
                                          event['severity'] as String),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        AppTheme.lightTheme.colorScheme.surface,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppTheme
                                                .lightTheme.colorScheme.primary
                                                .withValues(alpha: 0.3),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                              // Year label for major events
                              if (index % 3 == 0 && !isSelected)
                                Positioned(
                                  left: -15.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: AppTheme
                                            .lightTheme.colorScheme.outline
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Text(
                                      _extractYear(event['date'] as String),
                                      style: AppTheme
                                          .lightTheme.textTheme.labelSmall
                                          ?.copyWith(
                                        fontSize: 8.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Current position indicator
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Text(
                '${currentEventIndex + 1}/${events.length}',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppTheme.lightTheme.colorScheme.error;
      case 'high':
        return AppTheme.warningLight;
      case 'medium':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'low':
        return AppTheme.successLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _extractYear(String date) {
    try {
      return date.split(' ').last;
    } catch (e) {
      return '';
    }
  }
}
