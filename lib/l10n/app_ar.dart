/// Arabic (Egypt) localization strings for Nabta app.

class AppAr {
  AppAr._();

  // ─── App Shell ─────────────────────────────────────────────────────────────

  static const String appTitle = 'نبته';

  static const String navDashboardLabel = 'الرئيسية';

  static const String navSmartReportsLabel = 'التقارير الذكية';

  static const String navTimelineLabel = 'الجدول الزمني';

  static const String navGeoMapLabel = 'الخريطة';

  // ─── Dashboard ─────────────────────────────────────────────────────────────

  static const String welcomeGreeting = 'مرحباً بعودتك،';

  static const String latestReportStatusLabel = 'حالة آخر تقرير';

  static const String actionNeededTitle = 'إجراء مطلوب';

  static const String actionNeededMessage =
      'قطعتك أ تحتاج معالجة نيتروجينية قبل الشتاء';

  // ─── Smart Reports ────────────────────────────────────────────────────────

  static const String soilAnalysisLabel = 'تحليل التربة';

  static const String reportPlotName = 'القطعة أ';

  static const String reportDateDisplay = '١٠ فبراير ٢٠٢٦';

  static const String aiTreatmentPlanTitle = 'خطة المعالجة بالذكاء الاصطناعي';

  static const String recommendedActionLabel = 'الإجراء الموصى به';

  static const String aiTreatmentPlan =
      'لعلاج نقص النيتروجين، أضف ٥٠ كجم يوريا لكل فدان';

  static const String uploadSoilReportLabel =
      'رفع تقرير التربة (الكاميرا / المعرض)';

  static const String analyzingLabel = 'جاري التحليل...';

  static const String analyzingWithAiLabel =
      'جاري تحليل التربة بالذكاء الاصطناعي...';

  static const String plantNameHint = 'ماذا تريد أن تزرع؟';

  static const String plantNameExample = 'مثال: قمح، طماطم، ذرة';

  static const String tryAgainLabel = 'حاول مرة أخرى';

  static const String analysisPlaceholder =
      'ارفع صورة تقرير التربة للتحليل بالذكاء الاصطناعي';

  static const String tapToUploadHint = 'انقر لرفع صورة';

  static const String uploadFromGallery = 'اختر من المعرض';

  static const String takePhoto = 'التقط صورة';

  static const String pickImageFailed = 'فشل في اختيار الصورة';

  static const String areaHint = 'مساحة الأرض (اختياري)';

  static const String areaExample = 'مثال: ٢ فدان، ٥ هكتار';

  static const String previousCropHint = 'المحصول السابق (اختياري)';

  static const String previousCropExample = 'مثال: برسيم، قمح، ذرة';

  static const String diagnosisTitle = 'تشخيص التربة';

  static const String recommendationsTitle = 'التوصيات العملية';

  static const String smartInsightsTitle = 'رؤى ذكية إضافية';

  // ─── Timeline ─────────────────────────────────────────────────────────────

  static const String subscriptionBadgeLabel = 'الاشتراك مفعّل';

  static const String nextAnalysisDueLabel = 'موعد التحليل القادم';

  static const String nextAnalysisDueDisplay = 'مارس ٢٠٢٦';

  static const String soilHealthScoreLabel = 'درجة صحة التربة';

  static const String pastSoilTestsLabel = 'تحاليل التربة السابقة';

  // ─── Geo-Map ──────────────────────────────────────────────────────────────

  static const String regionName = 'منطقة الدلتا';

  static const String satelliteViewLabel = 'عرض الأقمار الصناعية';

  static const String regionalInsightsSectionTitle = 'الرؤى الإقليمية (البيانات الضخمة)';

  static const String insightLabel = 'رؤية';

  static const String regionalInsightCardMessage =
      '٧٠٪ من المزارع في منطقتك (الدلتا) تعاني حالياً من نقص البوتاسيوم. معالجتك المبكرة وفرت ١٥٪ من التكاليف.';

  static const String predictiveAnalysisBadgeText =
      'تحليل تنبؤي مدعوم بالبيانات الإقليمية';

  // ─── Status / Element translations (for data from mock_data) ───────────────

  static const Map<String, String> _statusMap = {
    'Excellent': 'ممتاز',
    'Good': 'جيد',
    'Fair': 'مقبول',
    'Needs Attention': 'يحتاج متابعة',
    'Deficient': 'ناقص',
    'Optimal': 'مثالي',
    'Excess': 'زائد',
  };

  static const Map<String, String> _elementNameMap = {
    'Nitrogen': 'النيتروجين',
    'Phosphorus': 'الفوسفور',
    'Potassium': 'البوتاسيوم',
    'Acidity': 'الحموضة',
    'Salinity': 'الملوحة',
  };

  static const String farmerName = 'أحمد محمود';

  static const Map<String, String> healthHistoryNoteMap = {
    'Initial analysis - high salinity': 'تحليل أولي - ملوحة عالية',
    'Gypsum added - salinity reduced': 'إضافة الجبس الزراعي - انخفاض الملوحة',
    'Current - focus on Nitrogen': 'الحالة الحالية - التركيز على النيتروجين',
    'Soil analysis - soil health 85%': 'تحليل تربة - صحة التربة 85٪',
  };

  static const String scheduleNewTestLabel = 'جدولة تحليل جديد';

  static String status(String en) => _statusMap[en] ?? en;

  static String elementName(String en) => _elementNameMap[en] ?? en;

  static String healthNote(String en) => healthHistoryNoteMap[en] ?? en;

  static const Map<String, String> plotNameMap = {
    'Plot A': 'القطعة أ',
    'Plot B': 'القطعة ب',
    'Plot C': 'القطعة ج',
  };

  static String plotName(String en) => plotNameMap[en] ?? en;
}
