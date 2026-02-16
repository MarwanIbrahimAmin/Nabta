import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../l10n/app_ar.dart';
import '../widgets/status_card.dart';
import '../widgets/action_needed_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(context),
              const SizedBox(height: 24),
              StatusCard(
                label: AppAr.latestReportStatusLabel,
                status: AppAr.status(MockData.latestReportStatus),
              ),
              const SizedBox(height: 16),
              ActionNeededCard(
                title: AppAr.actionNeededTitle,
                message: AppAr.actionNeededMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppAr.welcomeGreeting,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          AppAr.farmerName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}
