import 'package:flutter/material.dart';
import 'package:music_app/src/shared/theme/app_theme.dart';
import 'package:music_app/src/shared/widgets/app_logo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // 主Logo展示
              const Center(child: AppLogo(size: 100, showText: true)),
              const SizedBox(height: 30),

              // 功能卡片
              _buildFeatureCard(
                context,
                icon: Icons.search_rounded,
                title: '智能搜索',
                description: '快速找到你喜欢的音乐',
                gradient: [AppTheme.accentPurple, AppTheme.accentBlue],
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                context,
                icon: Icons.library_music_rounded,
                title: '歌单管理',
                description: '轻松导入和管理你的歌单',
                gradient: [AppTheme.accentBlue, AppTheme.accentPurple],
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                context,
                icon: Icons.lyrics_rounded,
                title: '歌词同步',
                description: '享受沉浸式的听歌体验',
                gradient: [AppTheme.accentPurple, AppTheme.primaryMedium],
              ),

              const SizedBox(height: 20),

              // Logo变体展示
              // Container(
              //   padding: const EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     color: AppTheme.backgroundCard,
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   child: Column(
              //     children: [
              //       Text(
              //         'Logo 变体',
              //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //           color: AppTheme.textSecondary,
              //         ),
              //       ),
              //       const SizedBox(height: 20),
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //         children: const [
              //           AppLogo(size: 48),
              //           AppLogoSimple(size: 48),
              //           AppLogoSimple(size: 32),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.divider.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient.map((c) => c.withValues(alpha: 0.9)).toList(),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
