import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SkeletonCardWidget extends StatefulWidget {
  const SkeletonCardWidget({super.key});

  @override
  State<SkeletonCardWidget> createState() => _SkeletonCardWidgetState();
}

class _SkeletonCardWidgetState extends State<SkeletonCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
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
              _buildSkeletonImage(),
              _buildSkeletonContent(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonImage() {
    return Container(
      width: double.infinity,
      height: 25.h,
      decoration: BoxDecoration(
        color: _getSkeletonColor().withValues(alpha: _animation.value),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
    );
  }

  Widget _buildSkeletonContent() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 15.w,
                height: 3.h,
                decoration: BoxDecoration(
                  color:
                      _getSkeletonColor().withValues(alpha: _animation.value),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(5, (index) {
                  return Container(
                    width: 3.w,
                    height: 3.w,
                    margin: EdgeInsets.only(left: 0.5.w),
                    decoration: BoxDecoration(
                      color: _getSkeletonColor()
                          .withValues(alpha: _animation.value),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 2.h,
            decoration: BoxDecoration(
              color: _getSkeletonColor().withValues(alpha: _animation.value),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: 80.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: _getSkeletonColor().withValues(alpha: _animation.value),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: 60.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: _getSkeletonColor().withValues(alpha: _animation.value),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color:
                      _getSkeletonColor().withValues(alpha: _animation.value),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                width: 20.w,
                height: 1.5.h,
                decoration: BoxDecoration(
                  color:
                      _getSkeletonColor().withValues(alpha: _animation.value),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            height: 1,
            color:
                _getSkeletonColor().withValues(alpha: _animation.value * 0.5),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Container(
                width: 15.w,
                height: 1.5.h,
                decoration: BoxDecoration(
                  color:
                      _getSkeletonColor().withValues(alpha: _animation.value),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 4.w),
              Container(
                width: 15.w,
                height: 1.5.h,
                decoration: BoxDecoration(
                  color:
                      _getSkeletonColor().withValues(alpha: _animation.value),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 20.w,
                height: 1.5.h,
                decoration: BoxDecoration(
                  color:
                      _getSkeletonColor().withValues(alpha: _animation.value),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSkeletonColor() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppTheme.textDisabledDark : AppTheme.textDisabledLight;
  }
}
