import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../theme/app_colors.dart';

/// Single item in the land history timeline with color-coded indicator.
class TimelineItem extends StatelessWidget {
  const TimelineItem({
    super.key,
    required this.year,
    required this.score,
    required this.note,
    this.isFirst = false,
    this.isLast = false,
    this.dotType = 'success',
  });

  final String year;
  final int score;
  final String note;
  final bool isFirst;
  final bool isLast;
  /// 'success' = green, 'warning' = red/orange
  final String dotType;

  Color get _dotColor {
    switch (dotType) {
      case 'warning':
        return AppColors.deficientRed;
      case 'success':
      default:
        return AppColors.agriGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(
        color: AppColors.agriGreen.withOpacity(0.25),
        thickness: 2,
      ),
      afterLineStyle: LineStyle(
        color: AppColors.agriGreen.withOpacity(0.25),
        thickness: 2,
      ),
      indicatorStyle: IndicatorStyle(
        width: 32,
        height: 32,
        indicator: Container(
          decoration: BoxDecoration(
            color: _dotColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: _dotColor.withOpacity(0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
      endChild: Padding(
        padding: const EdgeInsets.only(bottom: 24)
            .add(const EdgeInsetsDirectional.only(start: 16)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.agriGreen.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.agriGreen.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    year,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.agriGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.agriGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$score%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.agriGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                note,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
