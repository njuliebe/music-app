import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

// Run this with: flutter run lib/src/tools/generate_icon.dart
void main() {
  runApp(IconGeneratorApp());
}

class IconGeneratorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IconGenerator(),
    );
  }
}

class IconGenerator extends StatefulWidget {
  @override
  _IconGeneratorState createState() => _IconGeneratorState();
}

class _IconGeneratorState extends State<IconGenerator> {
  bool _generating = false;
  String _status = 'Click button to generate icons';

  Future<void> _generateIcons() async {
    setState(() {
      _generating = true;
      _status = 'Generating icons...';
    });

    try {
      // Generate main icon
      final mainIcon = await _generateIcon(1024, false);
      final foregroundIcon = await _generateIcon(1024, true);

      // Save to assets folder
      final assetsDir = Directory('assets/icon');
      if (!await assetsDir.exists()) {
        await assetsDir.create(recursive: true);
      }

      final mainFile = File('assets/icon/app_icon.png');
      await mainFile.writeAsBytes(mainIcon);

      final foregroundFile = File('assets/icon/app_icon_foreground.png');
      await foregroundFile.writeAsBytes(foregroundIcon);

      setState(() {
        _status = 'Icons generated successfully! Check assets/icon/ folder';
        _generating = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _generating = false;
      });
    }
  }

  Future<Uint8List> _generateIcon(int size, bool isForeground) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    if (!isForeground) {
      // Draw background gradient
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF8B7FE8),
          const Color(0xFF6366F1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));

      // Draw rounded rectangle background
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Radius.circular(size * 0.22),
      );
      canvas.drawRRect(rrect, paint);
    }

    // Draw music note
    final notePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final centerX = size / 2;
    final centerY = size / 2;
    final noteSize = size * 0.4;

    // Draw simplified music note shape
    // Note head (circle)
    canvas.drawCircle(
      Offset(centerX - noteSize * 0.15, centerY + noteSize * 0.2),
      noteSize * 0.15,
      notePaint,
    );

    // Note stem
    canvas.drawRect(
      Rect.fromLTWH(
        centerX - noteSize * 0.15 + noteSize * 0.13,
        centerY - noteSize * 0.3,
        noteSize * 0.04,
        noteSize * 0.5,
      ),
      notePaint,
    );

    // Note flag
    final flagPath = Path()
      ..moveTo(centerX - noteSize * 0.02, centerY - noteSize * 0.3)
      ..lineTo(centerX + noteSize * 0.15, centerY - noteSize * 0.15)
      ..lineTo(centerX + noteSize * 0.12, centerY - noteSize * 0.05)
      ..lineTo(centerX - noteSize * 0.02, centerY - noteSize * 0.1)
      ..close();
    canvas.drawPath(flagPath, notePaint);

    // Second note
    canvas.drawCircle(
      Offset(centerX + noteSize * 0.1, centerY + noteSize * 0.05),
      noteSize * 0.15,
      notePaint,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size, size);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MusicX Icon Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Preview
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B7FE8), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(44),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 100,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _status,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generating ? null : _generateIcons,
              child: _generating
                  ? const CircularProgressIndicator()
                  : const Text('Generate Icons'),
            ),
          ],
        ),
      ),
    );
  }
}