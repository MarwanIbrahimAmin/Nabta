/// Single source of truth for all Nabta app mock data.
/// Every screen MUST read its data from this file only.

/// Soil element model for Smart Reports grid.
class SoilElement {
  const SoilElement({
    required this.symbol,
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
    required this.gaugePercent,
  });

  final String symbol;
  final String name;
  final double value;
  final String unit;
  final String status;
  final double gaugePercent;

  factory SoilElement.fromMap(Map<String, dynamic> map) {
    final statusRaw = map['status'] as String? ?? 'Optimal';
    final status = statusRaw == 'Low'
        ? 'Deficient'
        : statusRaw == 'High'
            ? 'Excess'
            : statusRaw;
    final value = (map['value'] as num?)?.toDouble() ?? 0.0;
    final nameRaw = map['name'] as String? ?? '';
    final symbol = _extractSymbol(nameRaw);
    final gaugePercent = _gaugeFromStatus(status, value, symbol);

    return SoilElement(
      symbol: symbol,
      name: _getElementName(symbol),
      value: value,
      unit: map['unit'] as String? ?? '',
      status: status,
      gaugePercent: gaugePercent,
    );
  }

  static String _extractSymbol(String name) {
    if (name.contains('(N)')) return 'N';
    if (name.contains('(P)')) return 'P';
    if (name.contains('(K)')) return 'K';
    if (name.contains('pH')) return 'pH';
    if (name.contains('EC')) return 'EC';
    return 'N';
  }

  static String _getElementName(String symbol) {
    switch (symbol) {
      case 'N':
        return 'Nitrogen';
      case 'P':
        return 'Phosphorus';
      case 'K':
        return 'Potassium';
      case 'pH':
        return 'Acidity';
      case 'EC':
        return 'Salinity';
      default:
        return symbol;
    }
  }

  static double _gaugeFromStatus(String status, double value, String symbol) {
    if (status == 'Deficient') return 0.25;
    if (status == 'Excess') return 0.88;
    if (symbol == 'pH') return (value - 4) / 6;
    return (value / 150).clamp(0.3, 0.9);
  }
}

class MockData {
  // ─── Dashboard ─────────────────────────────────────────────────────────────

  static String get farmerName =>
      userProfile['farmerName'] as String? ?? 'Ahmed Mahmoud';

  static String get latestReportStatus {
    final score = latestReport['overallHealthScore'] as int? ?? 85;
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Needs Attention';
  }

  static String get actionNeededTitle => 'Action Needed';

  static String get actionNeededMessage =>
      'Your Plot A needs Nitrogen treatment before winter';

  static String get welcomeGreeting => 'Welcome back,';

  static String get latestReportStatusLabel => 'Latest Report Status';

  // ─── Smart Reports ────────────────────────────────────────────────────────

  static String get reportPlotName => 'Plot A';

  static String get reportDateDisplay => 'Feb 10, 2026';

  static String get soilAnalysisLabel => 'Soil Analysis';

  static List<SoilElement> get soilElements {
    final list = latestReport['elements'] as List<dynamic>? ?? [];
    if (list.isEmpty) return _fallbackSoilElements;
    try {
      return list
          .map((e) => SoilElement.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _fallbackSoilElements;
    }
  }

  static const List<SoilElement> _fallbackSoilElements = [
    SoilElement(
      symbol: 'N',
      name: 'Nitrogen',
      value: 15,
      unit: 'mg/kg',
      status: 'Deficient',
      gaugePercent: 0.25,
    ),
    SoilElement(
      symbol: 'P',
      name: 'Phosphorus',
      value: 45,
      unit: 'mg/kg',
      status: 'Optimal',
      gaugePercent: 0.65,
    ),
    SoilElement(
      symbol: 'K',
      name: 'Potassium',
      value: 120,
      unit: 'mg/kg',
      status: 'Optimal',
      gaugePercent: 0.80,
    ),
    SoilElement(
      symbol: 'pH',
      name: 'Acidity',
      value: 7.8,
      unit: 'pH',
      status: 'Excess',
      gaugePercent: 0.88,
    ),
    SoilElement(
      symbol: 'EC',
      name: 'Salinity',
      value: 1.2,
      unit: 'dS/m',
      status: 'Optimal',
      gaugePercent: 0.55,
    ),
  ];

  static String get aiTreatmentPlan =>
      'To fix Nitrogen deficiency, add 50kg of Urea per acre';

  static String get aiTreatmentPlanTitle => 'AI Treatment Plan';

  static String get recommendedActionLabel => 'Recommended Action';

  // ─── Timeline ─────────────────────────────────────────────────────────────

  static String get timelineTitle => 'Timeline';

  static String get timelineSubtitle => 'Land History';

  static String get subscriptionStatus =>
      userProfile['subscriptionStatus'] as String? ?? 'Active (Premium LIMS)';

  static String get subscriptionBadgeLabel => 'Subscription Active';

  static String get nextAnalysisDueDisplay => 'March 2026';

  static String get nextAnalysisDueLabel => 'Next Analysis Due';

  static List<Map<String, dynamic>> get healthHistory => _healthHistory;

  static String get soilHealthScoreLabel => 'Soil Health Score';

  static String get pastSoilTestsLabel => 'Past Soil Tests';

  // ─── Geo-Map ──────────────────────────────────────────────────────────────

  static String get geoMapTitle => 'Geo-Map';

  static String get geoMapSubtitle => 'Regional Insights';

  static String get regionName =>
      regionalInsights['regionName'] as String? ?? 'Delta Region';

  static String get insightAlert =>
      regionalInsights['insightAlert'] as String? ??
      '70% of farms in your region are currently experiencing Potassium deficiency.';

  static String get yourAdvantage =>
      regionalInsights['yourAdvantage'] as String? ??
      'Your proactive analysis and application of recommendations saved you an estimated 15% crop loss compared to neighbors.';

  /// Combined insight for Regional Insights card.
  static String get regionalInsightCardMessage =>
      '70% of farms in your region (Delta) are currently experiencing Potassium deficiency. Your early treatment saved 15% in costs.';

  static String get regionalInsightsSectionTitle =>
      'Regional Insights (Big Data)';

  static List<Map<String, dynamic>> get farmerPlots => _farmerPlots;

  static const List<Map<String, dynamic>> _farmerPlots = [
    {
      'name': 'Plot A',
      'nameAr': 'القطعة أ',
      'lat': 31.052,
      'lng': 31.352,
      'soilStatus': 'نسبة الرطوبة ممتازة، تحتاج لنيتروجين',
      'xPercent': 0.25,
      'yPercent': 0.35,
    },
    {
      'name': 'Plot B',
      'nameAr': 'القطعة ب',
      'lat': 31.028,
      'lng': 31.402,
      'soilStatus': 'التربة متوازنة، جاهزة للزراعة',
      'xPercent': 0.62,
      'yPercent': 0.55,
    },
    {
      'name': 'Plot C',
      'nameAr': 'القطعة ج',
      'lat': 31.058,
      'lng': 31.385,
      'soilStatus': 'تحتاج معالجة الفوسفور',
      'xPercent': 0.48,
      'yPercent': 0.22,
    },
  ];

  static String get satelliteViewLabel => 'Satellite View';

  static String get insightLabel => 'Insight';

  static String get predictiveAnalysisBadgeText =>
      'Predictive analysis powered by regional data';

  // ─── App Shell ────────────────────────────────────────────────────────────

  static String get appTitle => 'Nabta';

  static String get navDashboardLabel => 'Dashboard';

  static String get navSmartReportsLabel => 'Smart Reports';

  static String get navTimelineLabel => 'Timeline';

  static String get navGeoMapLabel => 'Geo-Map';

  // ─── Raw data (from original mock_data structure) ──────────────────────────

  static const Map<String, dynamic> userProfile = {
    'farmerName': 'Ahmed Mahmoud',
    'subscriptionStatus': 'Active (Premium LIMS)',
    'nextAnalysisDue': '15 مارس 2026',
    'totalFarms': 2,
    'totalAcres': 15,
  };

  static const Map<String, dynamic> latestReport = {
    'reportDate': '10 فبراير 2026',
    'plotName': 'الحقل أ - 5 فدان',
    'overallHealthScore': 85,
    'statusMessage': 'جيد جداً، ولكن يحتاج إلى دعم نيتروجيني',
    'elements': [
      {'name': 'النيتروجين (N)', 'value': 15, 'unit': 'mg/kg', 'status': 'Low'},
      {'name': 'الفوسفور (P)', 'value': 45, 'unit': 'mg/kg', 'status': 'Optimal'},
      {'name': 'البوتاسيوم (K)', 'value': 120, 'unit': 'mg/kg', 'status': 'Optimal'},
      {'name': 'مستوى الحموضة (pH)', 'value': 7.8, 'unit': 'pH', 'status': 'High'},
      {'name': 'الملوحة (EC)', 'value': 1.2, 'unit': 'dS/m', 'status': 'Optimal'},
    ],
    'aiInsight':
        'تربة أرضك في حالة صحية ممتازة بفضل التسميد الأخير، ولكن نقص النيتروجين سيؤثر على نمو الأوراق.',
  };

  static const List<Map<String, dynamic>> recommendedCrops = [
    {
      'cropName': 'القمح (Wheat)',
      'operationalCost': '15,000 ج.م / فدان',
      'expectedProfit': '35,000 ج.م / فدان',
      'roi': '133%',
      'treatmentRequired': 'إضافة 50 كجم يوريا + 10 لتر حمض هيوميك لمعالجة النيتروجين',
      'riskLevel': 'منخفض (Low)',
      'isBestMatch': true,
    },
    {
      'cropName': 'البطاطس (Potatoes)',
      'operationalCost': '25,000 ج.م / فدان',
      'expectedProfit': '65,000 ج.م / فدان',
      'roi': '160%',
      'treatmentRequired': 'إضافة 75 كجم سلفات نشادر لخفض قلوية التربة (pH)',
      'riskLevel': 'متوسط (Medium)',
      'isBestMatch': false,
    },
  ];

  static const List<Map<String, dynamic>> _healthHistory = [
    {
      'year': '2024',
      'score': 60,
      'note': 'Initial analysis - high salinity',
      'dotType': 'warning', // Red/Orange for initial poor state
    },
    {
      'year': '2025',
      'score': 75,
      'note': 'Gypsum added - salinity reduced',
      'dotType': 'success',
    },
    {
      'year': '2026',
      'score': 85,
      'note': 'Soil analysis - soil health 85%',
      'dotType': 'success',
    },
  ];

  static const Map<String, dynamic> regionalInsights = {
    'regionName': 'Delta Region',
    'insightAlert':
        '70% of farms in your region are currently experiencing Potassium deficiency due to recent climate changes.',
    'yourAdvantage':
        'Your proactive analysis and application of recommendations saved you an estimated 15% crop loss compared to neighbors.',
  };
}
