import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

/// AI-generated treatment recommendation card.
class AiTreatmentCard extends StatelessWidget {
  const AiTreatmentCard({
    super.key,
    required this.title,
    required this.label,
    required this.message,
    this.expanded = false,
  });

  final String title;
  final String label;
  final String message;

  /// When true, card uses more height and message is scrollable for long content.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.sparkles, size: 20, color: AppColors.agriGreen),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          constraints: expanded
              ? const BoxConstraints(minHeight: 220)
              : const BoxConstraints(),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.agriGreen.withOpacity(0.12),
                AppColors.agriGreen.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.agriGreen.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.agriGreen.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.agriGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.pill, size: 28, color: AppColors.agriGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    expanded
                        ? Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                message,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            message,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
