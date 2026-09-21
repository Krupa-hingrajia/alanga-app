import 'dart:convert';
import 'package:flutter/material.dart';

class ImageLightboxDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageLightboxDialog({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  static void show(BuildContext context, List<String> images, {int initialIndex = 0}) {
    if (images.isEmpty) return;
    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (_) => ImageLightboxDialog(images: images, initialIndex: initialIndex),
    );
  }

  @override
  State<ImageLightboxDialog> createState() => _ImageLightboxDialogState();
}

class _ImageLightboxDialogState extends State<ImageLightboxDialog> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImage(String url) {
    if (url.startsWith('data:image')) {
      try {
        final commaIndex = url.indexOf(',');
        final base64String = commaIndex != -1 ? url.substring(commaIndex + 1) : url;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.broken_image_rounded, color: Colors.white60, size: 64),
          ),
        );
      } catch (_) {
        return const Center(
          child: Icon(Icons.broken_image_rounded, color: Colors.white60, size: 64),
        );
      }
    }

    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.broken_image_rounded, color: Colors.white60, size: 64),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Photo PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.8,
                maxScale: 3.5,
                child: Center(
                  child: _buildImage(widget.images[index]),
                ),
              );
            },
          ),

          // Top action bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Close button
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
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
