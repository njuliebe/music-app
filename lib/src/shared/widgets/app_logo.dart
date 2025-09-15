import 'package:flutter/material.dart';
import 'package:music_app/src/shared/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 64,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentPurple,
                AppTheme.accentBlue,
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentPurple.withValues(alpha: 0.4),
                blurRadius: size * 0.25,
                offset: Offset(0, size * 0.1),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 音波效果
              CustomPaint(
                size: Size(size * 0.7, size * 0.7),
                painter: _WavePainter(),
              ),
              // 中心音符图标
              Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: size * 0.4,
              ),
            ],
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.15),
          Text(
            'MusicX',
            style: TextStyle(
              fontSize: size * 0.3,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [
                    AppTheme.accentPurple,
                    AppTheme.accentBlue,
                  ],
                ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    // 绘制三个同心圆作为音波
    for (int i = 0; i < 3; i++) {
      final radius = size.width * (0.25 + i * 0.15);
      paint.color = Colors.white.withValues(alpha: 0.3 - i * 0.1);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 简化版Logo（用于小尺寸显示）
class AppLogoSimple extends StatelessWidget {
  final double size;

  const AppLogoSimple({
    super.key,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentPurple,
            AppTheme.accentBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}