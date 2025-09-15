# MusicX 应用图标设置指南

## 自动生成图标（推荐）

### 1. 安装 flutter_launcher_icons 包

在 `pubspec.yaml` 的 `dev_dependencies` 中添加：

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### 2. 添加图标配置

在 `pubspec.yaml` 文件末尾添加：

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#1A1625"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

### 3. 准备图标文件

创建以下文件夹和图标：
- `assets/icon/app_icon.png` - 1024x1024px 的应用图标
- `assets/icon/app_icon_foreground.png` - 1024x1024px 的前景图标（Android自适应图标）

### 4. 生成图标

运行以下命令：
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

## 手动设置图标

### Android 图标位置
- `/android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `/android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

### iOS 图标位置
- `/ios/Runner/Assets.xcassets/AppIcon.appiconset/`
  - 需要多个尺寸：20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024px

## 设计规范

### 图标设计建议
- 主图标：紫色渐变背景 (#8B7FE8 → #6366F1)
- 中心元素：白色音符图标
- 圆角：22% 的圆角半径
- 留白：图标边缘保留适当留白

### 配色方案
- 主色：#8B7FE8 (紫色)
- 辅色：#6366F1 (蓝紫色)
- 背景：#1A1625 (深色背景)
- 前景：#FFFFFF (白色)

## 临时图标代码

如果需要快速生成一个临时图标用于测试，可以使用以下Flutter代码生成：

```dart
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<Uint8List> generateAppIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = 1024.0;

  // 背景
  final bgPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8B7FE8), Color(0xFF6366F1)],
    ).createShader(Rect.fromLTWH(0, 0, size, size));

  // 绘制圆角矩形背景
  final rrect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, size, size),
    Radius.circular(size * 0.22),
  );
  canvas.drawRRect(rrect, bgPaint);

  // 绘制音符图标
  final textPainter = TextPainter(
    text: TextSpan(
      text: '♪',
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.5,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (size - textPainter.width) / 2,
      (size - textPainter.height) / 2,
    ),
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
```

## 验证图标更新

1. 清理并重新构建：
```bash
flutter clean
flutter pub get
flutter build apk  # Android
flutter build ios  # iOS
```

2. 安装到设备查看效果

## 注意事项

- iOS需要在Xcode中清理构建文件夹才能看到新图标
- Android可能需要卸载旧版本应用才能看到新图标
- 确保图标文件是PNG格式，背景透明（iOS）或纯色（Android）