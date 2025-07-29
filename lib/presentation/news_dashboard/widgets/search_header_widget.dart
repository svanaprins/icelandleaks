import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchHeaderWidget extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  const SearchHeaderWidget({
    super.key,
    required this.onSearchTap,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildLogo(isDark),
          const Spacer(),
          _buildSearchButton(isDark),
          SizedBox(width: 3.w),
          _buildFilterButton(isDark),
        ],
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: 'visibility',
            color: Colors.white,
            size: 20,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          'IcelandLeaks',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: isDark
                ? AppTheme.textHighEmphasisDark
                : AppTheme.textHighEmphasisLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton(bool isDark) {
    return GestureDetector(
      onTap: onSearchTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            width: 1,
          ),
        ),
        child: CustomIconWidget(
          iconName: 'search',
          color: isDark
              ? AppTheme.textMediumEmphasisDark
              : AppTheme.textMediumEmphasisLight,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFilterButton(bool isDark) {
    return GestureDetector(
      onTap: onFilterTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            width: 1,
          ),
        ),
        child: CustomIconWidget(
          iconName: 'filter_list',
          color: isDark
              ? AppTheme.textMediumEmphasisDark
              : AppTheme.textMediumEmphasisLight,
          size: 20,
        ),
      ),
    );
  }
}
