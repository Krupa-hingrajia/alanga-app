import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? initialValue;
  final String label;
  final ValueChanged<String> onImageChanged;

  const ImagePickerWidget({
    super.key,
    this.initialValue,
    required this.label,
    required this.onImageChanged,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _imageValue;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant ImagePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _imageValue = widget.initialValue;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        final dataUri = "data:image/jpeg;base64,$base64String";

        setState(() {
          _imageValue = dataUri;
        });
        widget.onImageChanged(dataUri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _clearImage() {
    setState(() {
      _imageValue = null;
    });
    widget.onImageChanged('');
  }

  void _showSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Select Image Source for ${widget.label}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.brandOrange),
                  title: const Text('Capture from Camera'),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_outlined, color: AppColors.brandOrange),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_imageValue != null && _imageValue!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.brandRed),
                    title: const Text('Remove Current Image', style: TextStyle(color: AppColors.brandRed)),
                    onTap: () {
                      Navigator.pop(bottomSheetCtx);
                      _clearImage();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    if (_imageValue == null || _imageValue!.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF9DCC4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined, color: AppColors.brandOrange, size: 36),
            const SizedBox(height: 8),
            Text(
              'Add ${widget.label}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4C6656),
              ),
            ),
          ],
        ),
      );
    }

    final isBase64 = _imageValue!.startsWith('data:image');

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4ECE8)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            isBase64
                ? Image.memory(
                    base64Decode(_imageValue!.split(',').last),
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    _imageValue!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_outlined, color: AppColors.brandRed, size: 36),
                    ),
                  ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: _clearImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _showSourceBottomSheet,
          borderRadius: BorderRadius.circular(12),
          child: _buildImagePreview(),
        ),
      ],
    );
  }
}
