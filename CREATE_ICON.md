# MusicX 应用图标快速创建指南

由于需要正确格式的PNG图标文件，请按照以下步骤创建应用图标：

## 方案一：使用在线工具（最简单）

1. 访问在线图标生成器：https://www.canva.com 或 https://www.figma.com
2. 创建一个 1024x1024 的画布
3. 设计元素：
   - 背景：紫色渐变 (#8B7FE8 → #6366F1)
   - 圆角：22% 半径
   - 中心：白色音符图标
4. 导出为 PNG 格式
5. 保存到 `assets/icon/app_icon.png`

## 方案二：使用设计软件

### 使用 Photoshop/GIMP/Sketch：
1. 新建 1024x1024px 文档
2. 创建圆角矩形（圆角半径 225px）
3. 填充紫色渐变：
   - 起始色：#8B7FE8
   - 结束色：#6366F1
   - 方向：左上到右下
4. 添加白色音符图标在中心
5. 导出为 PNG

## 方案三：使用 macOS 预览应用

1. 打开预览应用
2. 文件 → 新建从剪贴板
3. 创建一个简单的紫色方块
4. 保存为 PNG 到 `assets/icon/app_icon.png`

## 方案四：下载现成图标

创建一个简单的紫色图标：
1. 在浏览器访问：data:image/svg+xml,%3Csvg width='1024' height='1024' xmlns='http://www.w3.org/2000/svg'%3E%3Cdefs%3E%3ClinearGradient id='g' x1='0%25' y1='0%25' x2='100%25' y2='100%25'%3E%3Cstop offset='0%25' style='stop-color:%238B7FE8'/%3E%3Cstop offset='100%25' style='stop-color:%236366F1'/%3E%3C/linearGradient%3E%3C/defs%3E%3Crect width='1024' height='1024' rx='225' fill='url(%23g)'/%3E%3Ctext x='512' y='600' font-family='Arial' font-size='400' fill='white' text-anchor='middle'%3E♪%3C/text%3E%3C/svg%3E
2. 右键保存图像
3. 使用在线转换器转为PNG：https://cloudconvert.com/svg-to-png

## 手动放置图标后的步骤

1. 确保图标文件存在：
   - `assets/icon/app_icon.png` (主图标)
   - `assets/icon/app_icon_foreground.png` (可以是同一个文件的副本)

2. 运行命令生成所有尺寸：
   ```bash
   dart run flutter_launcher_icons
   ```

3. 如果成功，你会看到：
   ```
   ✓ Successfully generated launcher icons
   ```

## 临时解决方案

如果急需测试，可以：

1. **Android**: 直接替换这些文件（使用任意PNG图片）：
   - `/android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
   - `/android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
   - `/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
   - `/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
   - `/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

2. **iOS**: 在 Xcode 中打开项目，直接拖拽图片到 Assets.xcassets

## 验证安装

```bash
# 清理并重新构建
flutter clean
flutter pub get

# 运行应用
flutter run
```

应用安装后应该显示：
- 应用名称：MusicX
- 应用图标：你设计的紫色音符图标