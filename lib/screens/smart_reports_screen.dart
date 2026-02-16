import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_ar.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

enum _AnalysisState { idle, loading, success, error }

class SmartReportsScreen extends StatefulWidget {
  const SmartReportsScreen({super.key});

  @override
  State<SmartReportsScreen> createState() => _SmartReportsScreenState();
}

class _SmartReportsScreenState extends State<SmartReportsScreen> {
  _AnalysisState _state = _AnalysisState.idle;
  String _analysisResult = '';
  String _errorMessage = '';
  final TextEditingController _plantNameController = TextEditingController(
    text: 'Wheat',
  );
  final FocusNode _plantNameFocusNode = FocusNode();

  @override
  void dispose() {
    _plantNameController.dispose();
    _plantNameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyze() async {
    final plantName = _plantNameController.text.trim().isNotEmpty
        ? _plantNameController.text.trim()
        : 'Wheat';

    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.image),
                title: Text(AppAr.uploadFromGallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(LucideIcons.camera),
                title: Text(AppAr.takePhoto),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    XFile? pickedFile;
    try {
      pickedFile = await picker.pickImage(source: source);
    } catch (_) {
      if (mounted) {
        setState(() {
          _state = _AnalysisState.error;
          _errorMessage = AppAr.pickImageFailed;
        });
        _showErrorSnackbar(AppAr.pickImageFailed);
      }
      return;
    }

    if (pickedFile == null || !mounted) return;

    final file = File(pickedFile.path);

    setState(() {
      _state = _AnalysisState.loading;
      _errorMessage = '';
      _analysisResult = '';
    });

    try {
      final result = await ApiService.analyzeSoilReport(
        imageFile: file,
        plantName: plantName,
      );
      if (mounted) {
        setState(() {
          _state = _AnalysisState.success;
          _analysisResult = result;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _state = _AnalysisState.error;
          _errorMessage = e.message;
        });
        _showErrorSnackbar(e.message);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.deficientRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _resetToIdle() {
    setState(() {
      _state = _AnalysisState.idle;
      _errorMessage = '';
      _analysisResult = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  if (_state == _AnalysisState.idle ||
                      _state == _AnalysisState.loading) ...[
                    _buildPlantNameField(context),
                    const SizedBox(height: 20),
                  ],
                  if (_state == _AnalysisState.idle) _buildPlaceholderCard(context),
                  if (_state == _AnalysisState.loading)
                    _buildLoadingPlaceholder(context),
                  if (_state == _AnalysisState.success)
                    _buildAnalysisResultCard(context),
                  if (_state == _AnalysisState.error) _buildErrorCard(context),
                ],
              ),
            ),
            if (_state == _AnalysisState.loading) _buildLoadingOverlay(context),
          ],
        ),
      ),
      floatingActionButton: _state == _AnalysisState.idle
          ? FloatingActionButton.extended(
              onPressed: _pickAndAnalyze,
              backgroundColor: AppColors.agriGreen,
              icon: const Icon(LucideIcons.upload),
              label: Text(AppAr.uploadSoilReportLabel),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppAr.soilAnalysisLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '${AppAr.reportPlotName} · ${AppAr.reportDateDisplay}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }

  Widget _buildPlantNameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppAr.plantNameHint,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _plantNameController,
          focusNode: _plantNameFocusNode,
          enabled: _state != _AnalysisState.loading,
          decoration: InputDecoration(
            hintText: AppAr.plantNameExample,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.agriGreen.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.agriGreen.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.agriGreen,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildPlaceholderCard(BuildContext context) {
    return GestureDetector(
      onTap: _pickAndAnalyze,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.agriGreen.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.agriGreen.withOpacity(0.25),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              LucideIcons.fileImage,
              size: 56,
              color: AppColors.agriGreen.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              AppAr.analysisPlaceholder,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppAr.tapToUploadHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.agriGreen,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.agriGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.agriGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: AppColors.agriGreen,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppAr.analyzingWithAiLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.agriGreen,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResultCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 240),
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
        border: Border.all(color: AppColors.agriGreen.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.agriGreen.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sparkles, size: 22, color: AppColors.agriGreen),
              const SizedBox(width: 8),
              Text(
                AppAr.aiTreatmentPlanTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            child: Directionality(
                textDirection: TextDirection.rtl,
                child: MarkdownBody(
                  data: _analysisResult,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                    h1: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.agriGreen,
                      fontWeight: FontWeight.bold,
                    ),
                    h2: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.agriGreen,
                      fontWeight: FontWeight.w600,
                    ),
                    h3: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    listBullet: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    blockquote: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    blockquoteDecoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: AppColors.agriGreen,
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.deficientRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deficientRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(LucideIcons.alertCircle,
                  color: AppColors.deficientRed, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _errorMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _resetToIdle,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: Text(AppAr.tryAgainLabel),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.deficientRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: AppColors.agriGreen,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppAr.analyzingWithAiLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.agriGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
