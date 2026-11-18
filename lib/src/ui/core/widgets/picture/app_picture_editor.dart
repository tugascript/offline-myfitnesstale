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

import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/utils/picture_utils.dart';
import '../../sizes/data_display_sizes.dart';
import '../layout/app_elevated_button.dart';

typedef PictureTransformCallback = Future<Uint8List> Function(Uint8List bytes);

Future<Uint8List?> showPictureEditorDialog({
  required BuildContext context,
  required ThemeData theme,
  required DataDisplaySizesList sizes,
  required Uint8List imageBytes,
  PictureTransformCallback? preparePicture,
  PictureTransformCallback? rotatePicture,
  PictureTransformCallback? compressPicture,
}) {
  return showDialog<Uint8List>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final mediaSize = MediaQuery.sizeOf(dialogContext);
      final maxHeight = (mediaSize.height * 0.8).clamp(320.0, 680.0);
      final maxWidth = (mediaSize.width * 0.92).clamp(280.0, 620.0);

      return Dialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: BeveledRectangleBorder(
          side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
        insetPadding: EdgeInsets.all(sizes.margins),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          child: Padding(
            padding: EdgeInsets.all(sizes.padding),
            child: AppPictureEditor(
              theme: theme,
              sizes: sizes,
              imageBytes: imageBytes,
              preparePicture: preparePicture,
              rotatePicture: rotatePicture,
              compressPicture: compressPicture,
              onCancel: () => Navigator.of(dialogContext).pop(),
              onSaved: (compressed) =>
                  Navigator.of(dialogContext).pop(compressed),
            ),
          ),
        ),
      );
    },
  );
}

class AppPictureEditor extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Uint8List imageBytes;
  final ValueChanged<Uint8List> onSaved;
  final VoidCallback onCancel;
  final PictureTransformCallback? preparePicture;
  final PictureTransformCallback? rotatePicture;
  final PictureTransformCallback? compressPicture;

  const AppPictureEditor({
    super.key,
    required this.theme,
    required this.sizes,
    required this.imageBytes,
    required this.onSaved,
    required this.onCancel,
    this.preparePicture,
    this.rotatePicture,
    this.compressPicture,
  });

  @override
  State<AppPictureEditor> createState() => _AppPictureEditorState();
}

class _AppPictureEditorState extends State<AppPictureEditor> {
  final CropController _cropController = CropController();

  Uint8List? _preparedBytes;
  bool _isPreparing = true;
  bool _isCropReady = false;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _prepareImage();
  }

  Future<void> _prepareImage() async {
    try {
      final prepare = widget.preparePicture ?? PictureUtils.prepareForCropping;
      final prepared = await prepare(widget.imageBytes);
      if (!mounted) return;
      setState(() {
        _preparedBytes = prepared;
        _isPreparing = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPreparing = false;
        _errorMessage = 'Could not load this image for cropping.';
      });
    }
  }

  Future<void> _rotateImage() async {
    final current = _preparedBytes;
    if (current == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final rotate = widget.rotatePicture ?? PictureUtils.rotateClockwise90;
      final rotated = await rotate(current);
      if (!mounted) return;
      setState(() {
        _preparedBytes = rotated;
        _isCropReady = false;
        _isProcessing = false;
      });
      _cropController.image = rotated;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Failed to rotate image.';
      });
    }
  }

  void _triggerCrop() {
    if (!_isCropReady || _isProcessing || _preparedBytes == null) {
      return;
    }
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    _cropController.crop();
  }

  Future<void> _handleCropped(CropResult result) async {
    switch (result) {
      case CropSuccess(:final croppedImage):
        try {
          final compress =
              widget.compressPicture ?? PictureUtils.compressHorizontalPicture;
          final compressed = await compress(croppedImage);
          if (!mounted) return;
          widget.onSaved(compressed);
        } catch (_) {
          if (!mounted) return;
          setState(() {
            _isProcessing = false;
            _errorMessage = 'Failed to compress cropped photo.';
          });
        }
      case CropFailure():
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Failed to crop photo.';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = widget.theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Crop Photo (4:3)',
                style: TextStyle(
                  fontSize: widget.sizes.subtitleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('picture-editor-rotate'),
              tooltip: 'Rotate 90°',
              onPressed: (!_isPreparing && _isCropReady && !_isProcessing)
                  ? _rotateImage
                  : null,
              icon: const Icon(Icons.rotate_right),
            ),
            IconButton(
              key: const ValueKey('picture-editor-close'),
              tooltip: 'Cancel',
              onPressed: _isProcessing ? null : widget.onCancel,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        Text(
          'Only horizontal 4:3 photos are supported. Drag corners to frame the equipment.',
          style: TextStyle(
            fontSize: widget.sizes.smallFontSize,
            color: isDarkTheme ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        SizedBox(height: widget.sizes.spacing),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_isPreparing)
                const Center(child: CircularProgressIndicator())
              else if (_preparedBytes != null)
                Crop(
                  controller: _cropController,
                  image: _preparedBytes!,
                  aspectRatio: PictureUtils.horizontalAspectRatio,
                  initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                    size: 0.9,
                    aspectRatio: PictureUtils.horizontalAspectRatio,
                  ),
                  baseColor: widget.theme.scaffoldBackgroundColor,
                  maskColor: Colors.black.withValues(alpha: 0.55),
                  cornerDotBuilder: (_, _) =>
                      DotControl(color: widget.theme.colorScheme.primary),
                  progressIndicator: const Center(
                    child: CircularProgressIndicator(),
                  ),
                  onStatusChanged: (status) {
                    if (!mounted) return;
                    final ready = status == CropStatus.ready;
                    if (ready != _isCropReady) {
                      setState(() {
                        _isCropReady = ready;
                      });
                    }
                  },
                  onCropped: _handleCropped,
                )
              else
                Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: widget.sizes.largeIconSize,
                    color: Colors.grey,
                  ),
                ),
              if (_isProcessing)
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
        if (_errorMessage != null) ...[
          SizedBox(height: widget.sizes.halfSpacing),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: widget.theme.colorScheme.error,
              fontSize: widget.sizes.smallFontSize,
            ),
          ),
        ],
        SizedBox(height: widget.sizes.spacing),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isProcessing ? null : widget.onCancel,
                child: const Text('CANCEL'),
              ),
            ),
            SizedBox(width: widget.sizes.spacing),
            Expanded(
              child: AppElevatedButton(
                theme: widget.theme,
                sizes: widget.sizes,
                isDense: true,
                isLoading: _isProcessing,
                onPressed: (!_isPreparing && _isCropReady && !_isProcessing)
                    ? _triggerCrop
                    : null,
                label: 'SAVE',
                icon: Icons.check,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
