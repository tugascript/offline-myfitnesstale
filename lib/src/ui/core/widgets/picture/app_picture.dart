// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:io';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/core/dtos/picture_dto.dart';
import '../../../../data/services/storage/local_file_storage_service.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/picture_utils.dart';
import '../../sizes/data_display_sizes.dart';

class AppPicture extends StatefulWidget {
  final PictureDto? picture;
  final Uint8List? memoryBytes;
  final DataDisplaySizesList sizes;
  final ThemeData? theme;
  final double aspectRatio;
  final LocalFileStorageService? storageService;
  final BoxFit fit;

  const AppPicture({
    super.key,
    required PictureDto this.picture,
    required this.sizes,
    this.theme,
    this.aspectRatio = PictureUtils.horizontalAspectRatio,
    this.storageService,
    this.fit = BoxFit.cover,
  }) : memoryBytes = null;

  const AppPicture.memory({
    super.key,
    required Uint8List this.memoryBytes,
    required this.sizes,
    this.theme,
    this.aspectRatio = PictureUtils.horizontalAspectRatio,
    this.fit = BoxFit.cover,
  }) : picture = null,
       storageService = null;

  @override
  State<AppPicture> createState() => _AppPictureState();
}

class _AppPictureState extends State<AppPicture> {
  Future<File?>? _localFileFuture;

  LocalFileStorageService get _storageService =>
      widget.storageService ?? LocalFileStorageService.create();

  @override
  void initState() {
    super.initState();
    _initFileFuture();
  }

  @override
  void didUpdateWidget(covariant AppPicture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.picture != widget.picture ||
        oldWidget.storageService != widget.storageService ||
        oldWidget.memoryBytes != widget.memoryBytes) {
      _initFileFuture();
    }
  }

  void _initFileFuture() {
    if (widget.memoryBytes == null &&
        widget.picture?.storage == PictureStorage.files) {
      _localFileFuture = _resolveExistingFile(widget.picture!.uri);
    } else {
      _localFileFuture = null;
    }
  }

  Future<File?> _resolveExistingFile(String uri) async {
    final file = await _storageService.resolvePictureFile(uri);
    if (file == null || !await file.exists()) {
      return null;
    }
    return file;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = widget.theme ?? Theme.of(context);
    final isDarkTheme = resolvedTheme.brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDarkTheme ? Colors.grey[900] : Colors.grey[200],
          border: Border.all(
            color: resolvedTheme.colorScheme.outlineVariant,
            width: 0.75,
          ),
        ),
        child: _buildImageContent(resolvedTheme, isDarkTheme),
      ),
    );
  }

  Widget _buildImageContent(ThemeData resolvedTheme, bool isDarkTheme) {
    if (widget.memoryBytes != null) {
      return Image.memory(
        widget.memoryBytes!,
        fit: widget.fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _buildFallback(
          isDarkTheme,
          Icons.broken_image_outlined,
          'Unable to display photo',
        ),
      );
    }

    final picture = widget.picture;
    if (picture == null || picture.uri.trim().isEmpty) {
      return _buildFallback(
        isDarkTheme,
        Icons.image_not_supported_outlined,
        'No photo available',
      );
    }

    switch (picture.storage) {
      case PictureStorage.assets:
        return Image.asset(
          picture.uri,
          fit: widget.fit,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, _, _) => _buildFallback(
            isDarkTheme,
            Icons.broken_image_outlined,
            'Asset photo unavailable',
          ),
        );
      case PictureStorage.network:
        return Image.network(
          picture.uri,
          fit: widget.fit,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (_, _, _) => _buildFallback(
            isDarkTheme,
            Icons.broken_image_outlined,
            'Could not load photo from URL',
          ),
        );
      case PictureStorage.files:
        return FutureBuilder<File?>(
          future: _localFileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Icon(
                  Icons.image_outlined,
                  size: widget.sizes.largeIconSize * 0.65,
                  color: Colors.grey,
                ),
              );
            }

            final file = snapshot.data;
            if (file == null) {
              return _buildFallback(
                isDarkTheme,
                Icons.image_not_supported_outlined,
                'Local photo unavailable',
              );
            }

            return Image.file(
              file,
              fit: widget.fit,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) => _buildFallback(
                isDarkTheme,
                Icons.broken_image_outlined,
                'Unable to open local photo',
              ),
            );
          },
        );
    }
  }

  Widget _buildFallback(bool isDarkTheme, IconData icon, String message) {
    return Padding(
      padding: EdgeInsets.all(widget.sizes.padding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: widget.sizes.largeIconSize * 0.65, color: Colors.grey),
            SizedBox(height: widget.sizes.halfSpacing),
            Text(
              message,
              style: TextStyle(
                fontSize: widget.sizes.smallFontSize,
                color: isDarkTheme ? Colors.grey[300] : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
