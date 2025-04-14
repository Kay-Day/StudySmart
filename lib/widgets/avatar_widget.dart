import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:studysmart/widgets/avatar_cache.dart';
import '../constants/app_colors.dart';


class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String fallbackText;
  final double radius;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;
  final bool showEditIcon;

  const AvatarWidget({
    Key? key,
    this.avatarUrl,
    required this.fallbackText,
    this.radius = 40,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.onTap,
    this.showEditIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor,
            child: _buildAvatarContent(),
          ),
          if (showEditIcon)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    // Không có avatar URL
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return Text(
        _getFirstLetter(fallbackText),
        style: TextStyle(
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      );
    }

    // Đường dẫn GridFS
    if (avatarUrl!.startsWith('gridfs:')) {
      return FutureBuilder<Uint8List?>(
        future: _loadGridFSImage(avatarUrl!.substring(7)), // Bỏ tiền tố 'gridfs:'
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: textColor,
                strokeWidth: 2,
              ),
            );
          }
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Text(
              _getFirstLetter(fallbackText),
              style: TextStyle(
                fontSize: radius * 0.6,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            );
          }
          
          return ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image.memory(
              snapshot.data!,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  _getFirstLetter(fallbackText),
                  style: TextStyle(
                    fontSize: radius * 0.6,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                );
              },
            ),
          );
        },
      );
    }
    
    // Đường dẫn local
    if (avatarUrl!.startsWith('/')) {
      final file = File(avatarUrl!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.file(
          file,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              _getFirstLetter(fallbackText),
              style: TextStyle(
                fontSize: radius * 0.6,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            );
          },
        ),
      );
    }

    // Đường dẫn trực tuyến
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: avatarUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: textColor,
            strokeWidth: 2,
          ),
        ),
        errorWidget: (context, url, error) => Text(
          _getFirstLetter(fallbackText),
          style: TextStyle(
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
  
  Future<Uint8List?> _loadGridFSImage(String imageId) async {
    try {
      // Sử dụng AvatarCache để lấy ảnh từ cache hoặc GridFS
      return await AvatarCache.getImage(imageId);
    } catch (e) {
      print('Lỗi khi lấy ảnh từ GridFS: $e');
      return null;
    }
  }

  String _getFirstLetter(String text) {
    if (text.isNotEmpty) {
      return text.substring(0, 1).toUpperCase();
    }
    return 'U';
  }
}