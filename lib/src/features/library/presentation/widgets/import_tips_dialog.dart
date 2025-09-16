import 'package:flutter/material.dart';
import 'package:music_app/src/shared/theme/app_theme.dart';

class ImportTipsDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const ImportTipsDialog({super.key, required this.onComplete});

  @override
  State<ImportTipsDialog> createState() => _ImportTipsDialogState();
}

class _ImportTipsDialogState extends State<ImportTipsDialog> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _urlController = TextEditingController();

  final List<_TipStep> _steps = [
    _TipStep(
      title: '打开歌单',
      imagePath: 'lib/assets/images/import_tips/step1.jpg',
      description: '第1步',
      subtitle: '打开歌单',
    ),
    _TipStep(
      title: '分享歌单',
      imagePath: 'lib/assets/images/import_tips/step2.jpg',
      description: '第2步',
      subtitle: '分享歌单',
    ),
    _TipStep(
      title: '复制链接',
      imagePath: 'lib/assets/images/import_tips/step3.jpg',
      description: '第3步',
      subtitle: '复制链接',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    for (final step in _steps) {
      try {
        await precacheImage(AssetImage(step.imagePath), context);
      } catch (e) {
        debugPrint('Failed to preload image ${step.imagePath}: $e');
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 450,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.backgroundCard,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      '导入歌单',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: ListView(
                shrinkWrap: false,
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 16),
                  // Title
                  Center(
                    child: Text(
                      '导入步骤',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Horizontal scrollable steps
                  SizedBox(
                    height: 260,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _steps.length,
                      itemBuilder: (context, index) {
                        return _buildHorizontalStepCard(_steps[index], index);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Bottom section with input (non-scrollable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundElevated,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.divider.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '粘贴链接或分享文本',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // URL Input field
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: '粘贴歌单链接或分享文本',
                        hintStyle: TextStyle(fontSize: 14, color: AppTheme.textHint),
                        filled: true,
                        fillColor: AppTheme.backgroundCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(Icons.link, color: AppTheme.textSecondary, size: 20),
                      ),
                      style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final String playlistUrl = _urlController.text.trim();
                        if (playlistUrl.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('请输入歌单链接或分享文本')),
                          );
                          return;
                        }

                        Navigator.of(context).pop(playlistUrl);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentPurple,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '开始导入',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalStepCard(_TipStep step, int index) {
    return Container(
      width: 220,
      margin: EdgeInsets.only(
        left: index == 0 ? 0 : 8,
        right: index == _steps.length - 1 ? 0 : 8,
      ),
      child: Column(
        children: [
          // Step number and title
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.accentPurple, AppTheme.accentBlue],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    step.subtitle ?? step.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Image card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.backgroundElevated,
                border: Border.all(
                  color: AppTheme.divider.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  step.imagePath,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading image ${step.imagePath}: $error');
                    return Container(
                      color: AppTheme.backgroundCard,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              step.description,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipStep {
  final String title;
  final String imagePath;
  final String description;
  final String? subtitle;

  _TipStep({
    required this.title,
    required this.imagePath,
    required this.description,
    this.subtitle,
  });
}
