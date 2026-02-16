import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/mock_data.dart';
import '../l10n/app_ar.dart';
import '../theme/app_colors.dart';
import '../widgets/soil_health_chart.dart';
import '../widgets/subscription_badge.dart';
import '../widgets/next_analysis_banner.dart';
import '../widgets/timeline_item.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubscriptionBadge(label: AppAr.subscriptionBadgeLabel),
              const SizedBox(height: 12),
              NextAnalysisBanner(
                label: AppAr.nextAnalysisDueLabel,
                date: AppAr.nextAnalysisDueDisplay,
              ),
              const SizedBox(height: 24),
              _buildChartSection(context),
              const SizedBox(height: 28),
              _buildTimelineSection(context),
              const SizedBox(height: 24),
              _buildScheduleButton(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _onScheduleNewTest(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppAr.scheduleNewTestLabel),
        backgroundColor: AppColors.agriGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildScheduleButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _onScheduleNewTest(context),
        icon: const Icon(LucideIcons.calendarPlus, size: 20),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            AppAr.scheduleNewTestLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.agriGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: AppColors.agriGreen.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppAr.soilHealthScoreLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        SoilHealthChart(dataPoints: MockData.healthHistory),
      ],
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    final history = List<Map<String, dynamic>>.from(MockData.healthHistory)
      ..sort((a, b) => (b['year'] as String).compareTo(a['year'] as String));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppAr.pastSoilTestsLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),
        ...List.generate(history.length, (index) {
          final item = history[index];
          return TimelineItem(
            year: item['year'] as String? ?? '',
            score: item['score'] as int? ?? 0,
            note: AppAr.healthNote(item['note'] as String? ?? ''),
            isFirst: index == 0,
            isLast: index == history.length - 1,
            dotType: item['dotType'] as String? ?? 'success',
          );
        }),
      ],
    );
  }
}
