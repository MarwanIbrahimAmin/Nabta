import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../l10n/app_ar.dart';
import '../widgets/map_placeholder.dart';
import '../widgets/regional_insight_card.dart';

class GeoMapScreen extends StatelessWidget {
  const GeoMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MapPlaceholder(
                regionName: AppAr.regionName,
                plots: MockData.farmerPlots
                    .map((p) => {
                          ...p,
                          'name': AppAr.plotName(p['name'] as String),
                        })
                    .toList(),
                satelliteLabel: AppAr.satelliteViewLabel,
              ),
              const SizedBox(height: 24),
              RegionalInsightCard(
                sectionTitle: AppAr.regionalInsightsSectionTitle,
                insightLabel: AppAr.insightLabel,
                message: AppAr.regionalInsightCardMessage,
                badgeText: AppAr.predictiveAnalysisBadgeText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
