import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/mock_data.dart';
import '../l10n/app_ar.dart';
import '../theme/app_colors.dart';

/// Soil health gauge card for N, P, K, pH, EC.
class SoilElementCard extends StatelessWidget {
  const SoilElementCard({super.key, required this.element});

  final SoilElement element;

  Color _getStatusColor() {
    switch (element.status) {
      case 'Deficient':
        return AppColors.deficientRed;
      case 'Optimal':
        return AppColors.agriGreen;
      case 'Excess':
        return AppColors.excessAmber;
      default:
        return AppColors.earthBrown;
    }
  }

  IconData _getElementIcon() {
    switch (element.symbol) {
      case 'N':
        return LucideIcons.leaf;
      case 'P':
        return LucideIcons.flame;
      case 'K':
        return LucideIcons.zap;
      case 'pH':
        return LucideIcons.gauge;
      case 'EC':
        return LucideIcons.activity;
      default:
        return LucideIcons.atom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getElementIcon(), size: 22, color: color),
              const SizedBox(width: 6),
              Text(
                element.symbol,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: element.gaugePercent,
                    strokeWidth: 6,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(
                  element.value.toStringAsFixed(element.symbol == 'pH' ? 1 : 0),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppAr.elementName(element.name),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              AppAr.status(element.status),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
