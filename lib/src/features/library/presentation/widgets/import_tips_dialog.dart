import 'package:flutter/material.dart';

class ImportTipsDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const ImportTipsDialog({super.key, required this.onComplete});

  @override
  State<ImportTipsDialog> createState() => _ImportTipsDialogState();
}

class _ImportTipsDialogState extends State<ImportTipsDialog> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _urlController = TextEditingController();
  bool _imagesLoaded = false;

  final List<_TipStep> _steps = [
    _TipStep(
      title: '进入音乐App歌单',
      imagePath: 'lib/assets/images/import_tips/step1.jpg',
      description: '第1步',
      subtitle: '进入音乐App歌单页面',
    ),
    _TipStep(
      title: '点击分享按钮',
      imagePath: 'lib/assets/images/import_tips/step2.jpg',
      description: '第2步',
      subtitle: '点击分享按钮',
    ),
    _TipStep(
      title: '复制链接',
      imagePath: 'lib/assets/images/import_tips/step3.jpg',
      description: '第3步',
      subtitle: '点击复制链接',
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
    if (mounted) {
      setState(() {
        _imagesLoaded = true;
      });
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
          color: const Color(0xFFE8F5F3),
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
                      '歌单导入',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
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
                  // Tab indicators
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTabButton('链接导入', true),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Center(
                    child: Text(
                      '复制内容链接',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      '方法1·分享到微信后复制链接',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  // Step indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // Bottom section with input (non-scrollable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '第2步  将链接粘贴到下方',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // URL Input field
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: '请粘贴歌单链接',
                        hintStyle: const TextStyle(fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(Icons.link, color: Colors.grey[600], size: 20),
                      ),
                      style: const TextStyle(fontSize: 14),
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
                            const SnackBar(content: Text('请输入歌单链接')),
                          );
                          return;
                        }

                        Navigator.of(context).pop(playlistUrl);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[300],
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(height: 4),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.black : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
                    color: Theme.of(context).primaryColor,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                      color: Colors.grey[100],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              step.description,
                              style: TextStyle(
                                color: Colors.grey[600],
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
