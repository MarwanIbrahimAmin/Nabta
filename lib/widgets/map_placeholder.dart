import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

/// Mock satellite map placeholder with overlay pins.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({
    super.key,
    required this.regionName,
    required this.plots,
    this.mapHeight = 220,
    this.satelliteLabel = 'عرض الأقمار الصناعية',
  });

  final String regionName;
  final List<Map<String, dynamic>> plots;
  final double mapHeight;
  final String satelliteLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: mapHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.mapGradientColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                const _GridPatternPainter(),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.satellite,
                        size: 40,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        satelliteLabel,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        regionName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                ...plots.map((plot) => _MapPin(
                      mapWidth: mapWidth,
                      mapHeight: mapHeight,
                      name: plot['name'] as String,
                      xPercent: (plot['xPercent'] as num).toDouble(),
                      yPercent: (plot['yPercent'] as num).toDouble(),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.mapWidth,
    required this.mapHeight,
    required this.name,
    required this.xPercent,
    required this.yPercent,
  });

  final double mapWidth;
  final double mapHeight;
  final String name;
  final double xPercent;
  final double yPercent;

  static const _pinWidth = 60.0;
  static const _pinHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (xPercent * mapWidth) - (_pinWidth / 2),
      top: (yPercent * mapHeight) - _pinHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.agriGreen,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.agriGreen.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.mapPin,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.agriGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPatternPainter extends StatelessWidget {
  const _GridPatternPainter();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;

    const spacing = 24.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
