import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../config/environment_config.dart';
import '../constants/app_colors.dart';

class CustomImageView extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData placeholderIcon;

  const CustomImageView({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.shopping_bag_outlined,
  });

  String _resolveUrl(String url) {
    final base = EnvironmentConfig.baseUrl.replaceAll('/api/v1', '');

    // Replace obsolete hosts (localhost, 127.0.0.1, old IP 192.168.1.100, 10.0.2.2) with current host
    var resolved = url
        .replaceAll('http://localhost:3000', base)
        .replaceAll('http://127.0.0.1:3000', base)
        .replaceAll('http://10.0.2.2:3000', base)
        .replaceAll('http://192.168.1.101:3000', base)
        .replaceAll('http://10.21.155.225:3000', base)
        .replaceAll('http://192.168.118.162:3000', base)
        .replaceAll('http://169.254.132.164:3000', base)
        .replaceAll('http://192.168.29.154:3000', base)
        .replaceAll('http://192.168.1.100:3000', base);

    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return resolved;
    }

    if (resolved.startsWith('/')) {
      return '$base$resolved';
    }
    return '$base/$resolved';
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _buildPlaceholder();
    }

    final trimmedUrl = imageUrl!.trim();

    // 1. Check Base64 Image
    if (trimmedUrl.startsWith('data:image')) {
      try {
        final base64Data = trimmedUrl.split(',').last;
        return Image.memory(
          base64Decode(base64Data),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } catch (_) {
        return _buildPlaceholder();
      }
    }

    // 2. Check Local File Image
    final cleanPath = trimmedUrl.startsWith('file://')
        ? trimmedUrl.replaceFirst('file://', '')
        : trimmedUrl;
    final file = File(cleanPath);

    if (!trimmedUrl.startsWith('/uploads') &&
        !trimmedUrl.startsWith('uploads/') &&
        !trimmedUrl.startsWith('http://') &&
        !trimmedUrl.startsWith('https://') &&
        file.existsSync()) {
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    // 3. Network Image
    try {
      final fullUrl = _resolveUrl(trimmedUrl);
      return Image.network(
        fullUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFF4F8F5),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } catch (_) {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFFFF9F2),
      child: Center(
        child: Icon(
          placeholderIcon,
          color: AppColors.brandOrange,
          size: 26,
        ),
      ),
    );
  }
}
