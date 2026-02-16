import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

/// Next analysis due reminder banner.
class NextAnalysisBanner extends StatelessWidget {
  const NextAnalysisBanner({
    super.key,
    required this.label,
    required this.date,
  });

  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.earthBrown.withOpacity(0.12),
            AppColors.earthBrown.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.earthBrown.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.calendarClock, size: 24, color: AppColors.earthBrown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.earthBrown,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
