# MusicX 🎵

<p align="center">
  <img src="assets/logo.png" alt="MusicX Logo" width="120" height="120">
</p>

<p align="center">
  <strong>探索无限音乐世界</strong>
</p>

<p align="center">
  一款优雅简约的跨平台音乐播放器，支持歌单导入、在线搜索和歌词同步。
</p>

## ✨ 功能特性
### 功能界面


![WechatIMG129](https://github.com/user-attachments/assets/ad38fd9a-475c-4b74-9615-a18e78d14bec)![WechatIMG128](https://github.com/user-attachments/assets/3c022752-c69f-430d-ad55-15180de95bc0)![WechatIMG127](https://github.com/user-attachments/assets/3b6c8817-bb9b-49f0-837d-f0f269747844)![WechatIMG126](https://github.com/user-attachments/assets/79c2e463-d573-4aeb-9e64-14e6ebc30d4a)


### 🎵 核心功能
- **智能搜索** - 快速搜索并播放喜欢的音乐
- **歌单管理** - 支持创建自定义歌单，导入网易云/QQ音乐歌单
- **歌词同步** - 实时显示滚动歌词，沉浸式听歌体验
- **播放控制** - 支持顺序播放、随机播放、单曲循环三种模式

### 🎨 设计特点
- **紫色主题** - 优雅的紫色渐变设计语言
- **简约界面** - 清晰的视觉层次，流畅的交互体验
- **深色模式** - 护眼的深色背景，适合长时间使用
- **响应式设计** - 适配手机、平板、桌面多种设备

### 📱 平台支持
- ✅ Android
- ✅ iOS
- ✅ macOS
- 🚧 Windows (开发中)
- 🚧 Linux (开发中)

## 🚀 快速开始

### 环境要求
- Flutter SDK: >=3.35.3
- Dart SDK: >=3.7.0
- Android Studio / Xcode (用于移动端开发)

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/yourusername/music_app.git
cd music_app
```

2. **安装依赖**
```bash
flutter pub get
```

3. **代码生成**（Freezed模型）
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **运行应用**
```bash
# 运行在已连接的设备上
flutter run

# 指定平台运行
flutter run -d android
flutter run -d ios
flutter run -d macos
```

## 📂 项目结构

```
lib/
├── src/
│   ├── core/               # 核心服务
│   │   └── services/       # 播放服务等
│   ├── data/               # 数据层
│   │   ├── models/         # 数据模型
│   │   ├── repositories/   # 数据仓库
│   │   └── sources/        # 数据源（API）
│   ├── features/           # 功能模块
│   │   ├── home/          # 首页
│   │   ├── search/        # 搜索
│   │   ├── library/       # 音乐库
│   │   ├── player/        # 播放器
│   │   └── lyrics/        # 歌词
│   └── shared/            # 共享组件
│       ├── theme/         # 主题配置
│       ├── widgets/       # 通用组件
│       └── shell/         # 应用外壳
└── main.dart              # 应用入口
```

## 🛠 技术栈

### 框架与语言
- **Flutter** - 跨平台UI框架
- **Dart** - 编程语言

### 状态管理
- **Riverpod** - 响应式状态管理和依赖注入

### 数据存储
- **SQLite** (sqflite) - 本地数据库存储
- **Shared Preferences** - 简单配置存储

### 网络请求
- **Dio** - HTTP客户端

### 音频播放
- **just_audio** - 跨平台音频播放器

### 代码生成
- **Freezed** - 不可变数据类生成
- **json_serializable** - JSON序列化

## 🎵 使用说明

### 搜索音乐
1. 点击底部导航栏的"搜索"标签
2. 在搜索框输入歌曲名、歌手或专辑
3. 点击搜索结果即可播放
4. 长按可以收藏到自建歌单

### 导入歌单
1. 进入"我的音乐"页面
2. 点击右上角"+"按钮
3. 选择"导入歌单"
4. 粘贴歌单链接或分享文本
5. 支持网易云音乐和QQ音乐歌单

### 创建歌单
1. 进入"我的音乐"页面
2. 点击右上角"+"按钮
3. 选择"创建歌单"
4. 输入歌单名称和描述
5. 在搜索页面长按歌曲可添加到歌单

### 播放控制
- **播放/暂停** - 点击播放按钮
- **上一首/下一首** - 点击切换按钮
- **播放模式** - 点击模式按钮切换（顺序/随机/单曲循环）
- **进度控制** - 拖动进度条调整播放位置

## 🔧 开发命令

```bash
# 清理构建
flutter clean

# 获取依赖
flutter pub get

# 运行代码生成
flutter pub run build_runner build --delete-conflicting-outputs

# 运行测试
flutter test

# 构建APK
flutter build apk

# 构建iOS
flutter build ios

# 构建macOS
flutter build macos
```

## 📝 配置说明

### API配置
应用使用两个音乐API源，配置在相应的service文件中：
- 主API：用于音乐搜索和播放
- 歌单导入API：用于解析外部歌单

### 数据库
- 使用SQLite存储本地歌单和歌曲信息
- 数据库版本管理支持自动迁移
- 当前版本：v6

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

### 开发规范
- 遵循Flutter官方代码规范
- 使用Riverpod进行状态管理
- 保持代码简洁和可维护性
- 添加必要的注释和文档

### 提交PR前请确保
- [ ] 代码通过所有测试
- [ ] 没有引入新的警告
- [ ] 更新了相关文档
- [ ] 遵循现有代码风格

## 📄 开源协议

本项目采用 MIT 协议开源，详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- [Flutter](https://flutter.dev/) - 跨平台UI框架
- [just_audio](https://pub.dev/packages/just_audio) - 音频播放支持
- [Riverpod](https://riverpod.dev/) - 状态管理方案
- [GD music](https://music.gdstudio.xyz/) - 音乐资源获取
- [unmeta](https://music.unmeta.cn/) - 歌单管理
- 所有贡献者和用户的支持

## 📮 联系方式

- 问题反馈：[GitHub Issues](https://github.com/yourusername/music_app/issues)
- 邮箱：njuliebe@gmail.com

---

<p align="center">
  Made with ❤️ using Flutter
</p>

<p align="center">
  <strong>MusicX - 让音乐触手可及</strong>
</p>
