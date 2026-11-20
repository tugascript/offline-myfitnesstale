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

import 'dart:async';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/core/dtos/picture_dto.dart';
import '../../../../data/services/storage/local_file_storage_service.dart';
import '../../../../data/utils/display_names.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/json_data.dart';
import '../../../../data/utils/picture_utils.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_dropdown.dart';
import '../../../core/widgets/layout/app_elevated_button.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';
import '../../../core/widgets/picture/app_picture.dart';
import '../../../core/widgets/picture/app_picture_editor.dart';

typedef EquipmentImagePicker = Future<Uint8List?> Function(ImageSource source);
typedef EquipmentPictureEditor = Future<Uint8List?> Function(
  Uint8List rawBytes,
);

enum _PictureSourceMode { none, url, upload }

class EquipmentForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final String initialName;
  final EquipmentRarity initialRarity;
  final PictureDto? initialPicture;
  final bool isLoading;
  final String submitLabel;
  final IconData? submitIcon;
  final LocalFileStorageService? storageService;
  final EquipmentImagePicker? pickImageBytes;
  final EquipmentPictureEditor? editPictureBytes;
  final FutureOr<void> Function({
    required String name,
    required EquipmentRarity rarity,
    required PictureData? picture,
    required Uint8List? uploadedPictureBytes,
  })
  onSubmit;

  const EquipmentForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.initialName,
    this.initialRarity = EquipmentRarity.common,
    this.initialPicture,
    required this.isLoading,
    required this.submitLabel,
    this.submitIcon,
    this.storageService,
    this.pickImageBytes,
    this.editPictureBytes,
    required this.onSubmit,
  });

  @override
  State<EquipmentForm> createState() => _EquipmentFormState();
}

class _EquipmentFormState extends State<EquipmentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  late _PictureSourceMode _sourceMode;
  late String _name;
  late EquipmentRarity _rarity;
  PictureDto? _existingLocalPicture;
  Uint8List? _rawPickedBytes;
  Uint8List? _uploadedBytes;
  String? _uploadError;
  bool _isPickingOrEditing = false;
  bool _isSubmitting = false;

  bool get _isBusy => widget.isLoading || _isPickingOrEditing || _isSubmitting;

  LocalFileStorageService get _storageService =>
      widget.storageService ?? LocalFileStorageService.create();

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _rarity = widget.initialRarity;
    _nameController.text = _name;

    final initialPicture = widget.initialPicture;
    if (initialPicture == null) {
      _sourceMode = _PictureSourceMode.none;
    } else if (initialPicture.storage == PictureStorage.network) {
      _sourceMode = _PictureSourceMode.url;
      _urlController.text = initialPicture.uri;
    } else {
      _sourceMode = _PictureSourceMode.upload;
      _existingLocalPicture = initialPicture;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _defaultPickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile == null) return null;
    return pickedFile.readAsBytes();
  }

  Future<Uint8List?> _defaultEditPicture(Uint8List rawBytes) {
    return showPictureEditorDialog(
      context: context,
      theme: widget.theme,
      sizes: widget.sizes,
      imageBytes: rawBytes,
    );
  }

  Future<void> _pickAndEdit(ImageSource source) async {
    if (_isBusy) return;

    setState(() {
      _isPickingOrEditing = true;
      _uploadError = null;
    });

    try {
      final picker = widget.pickImageBytes ?? _defaultPickImage;
      final rawBytes = await picker(source);
      if (!mounted || rawBytes == null) {
        if (mounted) {
          setState(() {
            _isPickingOrEditing = false;
          });
        }
        return;
      }

      final editor = widget.editPictureBytes ?? _defaultEditPicture;
      final croppedBytes = await editor(rawBytes);
      if (!mounted) return;

      setState(() {
        _isPickingOrEditing = false;
        if (croppedBytes != null) {
          _rawPickedBytes = rawBytes;
          _uploadedBytes = croppedBytes;
          _uploadError = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPickingOrEditing = false;
        _uploadError = 'Unable to pick or process that photo.';
      });
    }
  }

  Future<void> _recropCurrentPhoto() async {
    if (_isBusy) return;

    Uint8List? sourceBytes = _rawPickedBytes ?? _uploadedBytes;
    if (sourceBytes == null &&
        _existingLocalPicture?.storage == PictureStorage.files) {
      final file = await _storageService.resolvePictureFile(
        _existingLocalPicture!.uri,
      );
      if (file != null && await file.exists()) {
        sourceBytes = await file.readAsBytes();
      }
    }

    if (!mounted || sourceBytes == null) {
      if (mounted) {
        setState(() {
          _uploadError = 'Original photo file could not be opened.';
        });
      }
      return;
    }

    setState(() {
      _isPickingOrEditing = true;
      _uploadError = null;
    });

    try {
      final editor = widget.editPictureBytes ?? _defaultEditPicture;
      final croppedBytes = await editor(sourceBytes);
      if (!mounted) return;

      setState(() {
        _isPickingOrEditing = false;
        if (croppedBytes != null) {
          _rawPickedBytes ??= sourceBytes;
          _uploadedBytes = croppedBytes;
          _uploadError = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPickingOrEditing = false;
        _uploadError = 'Unable to edit photo.';
      });
    }
  }

  void _clearUploadedPhoto() {
    setState(() {
      _rawPickedBytes = null;
      _uploadedBytes = null;
      _existingLocalPicture = null;
      _uploadError = null;
      _sourceMode = _PictureSourceMode.none;
    });
  }

  Future<void> _handleSubmit() async {
    if (_isBusy) return;

    final isFormValid = _formKey.currentState!.validate();
    if (_sourceMode == _PictureSourceMode.upload &&
        _uploadedBytes == null &&
        _existingLocalPicture == null) {
      setState(() {
        _uploadError = 'Please upload a 4:3 photo or select None';
      });
      return;
    }

    if (!isFormValid) {
      return;
    }

    _formKey.currentState!.save();

    PictureData? picture;
    Uint8List? uploadedBytes;

    switch (_sourceMode) {
      case _PictureSourceMode.none:
        picture = null;
        uploadedBytes = null;
      case _PictureSourceMode.url:
        picture = PictureData(
          storage: PictureStorage.network,
          uri: _urlController.text.trim(),
        );
        uploadedBytes = null;
      case _PictureSourceMode.upload:
        if (_uploadedBytes != null) {
          picture = null;
          uploadedBytes = _uploadedBytes;
        } else if (_existingLocalPicture != null) {
          picture = PictureData(
            storage: _existingLocalPicture!.storage,
            uri: _existingLocalPicture!.uri,
          );
          uploadedBytes = null;
        }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(
        name: _name.trim(),
        rarity: _rarity,
        picture: picture,
        uploadedPictureBytes: uploadedBytes,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isBusy;
    final isDarkTheme = widget.theme.brightness == Brightness.dark;
    final urlText = _urlController.text.trim();
    final hasValidPreviewUrl = PictureUtils.isValidNetworkUrl(urlText);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextFormField(
            filled: true,
            theme: widget.theme,
            maxLines: 1,
            isLoading: isBusy,
            controller: _nameController,
            labelText: 'Name',
            hintText: 'Enter equipment name',
            fontSize: widget.sizes.subtitleFontSize * 1.25,
            padding: widget.sizes.padding * 1.3,
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _name = value;
                });
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          AppDropdown<EquipmentRarity>(
            theme: widget.theme,
            isLoading: isBusy,
            value: _rarity,
            filled: true,
            emptyLabel: 'Rarity',
            labelText: 'Rarity',
            showEmptyValue: false,
            items: EquipmentRarity.values,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            labelBuilder: EnumDisplayNames.getEquipmentRarityDisplayName,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _rarity = value;
                });
              }
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _rarity = value;
                });
              }
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          Text(
            'Photo (Optional, Horizontal 4:3)',
            style: TextStyle(
              fontSize: widget.sizes.fontSize,
              fontWeight: FontWeight.w600,
              color: isDarkTheme ? Colors.grey[200] : Colors.grey[800],
            ),
          ),
          SizedBox(height: widget.sizes.halfSpacing),
          SegmentedButton<_PictureSourceMode>(
            showSelectedIcon: false,
            style: const ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder()),
            ),
            segments: [
              ButtonSegment<_PictureSourceMode>(
                value: _PictureSourceMode.none,
                label: Text(
                  'None',
                  style: TextStyle(fontSize: widget.sizes.smallFontSize),
                ),
                icon: Icon(
                  Icons.hide_image_outlined,
                  size: widget.sizes.compactIconSize,
                ),
              ),
              ButtonSegment<_PictureSourceMode>(
                value: _PictureSourceMode.url,
                label: Text(
                  'URL',
                  style: TextStyle(fontSize: widget.sizes.smallFontSize),
                ),
                icon: Icon(Icons.link, size: widget.sizes.compactIconSize),
              ),
              ButtonSegment<_PictureSourceMode>(
                value: _PictureSourceMode.upload,
                label: Text(
                  'Upload',
                  style: TextStyle(fontSize: widget.sizes.smallFontSize),
                ),
                icon: Icon(
                  Icons.photo_camera_outlined,
                  size: widget.sizes.compactIconSize,
                ),
              ),
            ],
            selected: {_sourceMode},
            onSelectionChanged: isBusy
                ? null
                : (selected) {
                    setState(() {
                      _sourceMode = selected.first;
                      _uploadError = null;
                    });
                  },
          ),
          if (_sourceMode == _PictureSourceMode.url) ...[
            SizedBox(height: widget.sizes.spacing),
            AppTextFormField(
              filled: true,
              theme: widget.theme,
              maxLines: 1,
              isLoading: isBusy,
              controller: _urlController,
              keyboardType: TextInputType.url,
              labelText: 'Photo URL',
              hintText: 'https://example.com/equipment.jpg',
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.padding,
              onChanged: (_) {
                setState(() {});
              },
              validator: PictureUtils.validateRequiredUrl,
            ),
            if (hasValidPreviewUrl) ...[
              SizedBox(height: widget.sizes.spacing),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.sizes.buttonSize * 3.2,
                  ),
                  child: AppPicture(
                    picture: PictureDto(
                      storage: PictureStorage.network,
                      uri: urlText,
                    ),
                    sizes: widget.sizes,
                    theme: widget.theme,
                  ),
                ),
              ),
            ],
          ],
          if (_sourceMode == _PictureSourceMode.upload) ...[
            SizedBox(height: widget.sizes.spacing),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('equipment-photo-camera'),
                    onPressed: isBusy
                        ? null
                        : () => _pickAndEdit(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                ),
                SizedBox(width: widget.sizes.spacing),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('equipment-photo-gallery'),
                    onPressed: isBusy
                        ? null
                        : () => _pickAndEdit(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            if (_uploadedBytes != null) ...[
              SizedBox(height: widget.sizes.spacing),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.sizes.buttonSize * 3.2,
                  ),
                  child: AppPicture.memory(
                    memoryBytes: _uploadedBytes!,
                    sizes: widget.sizes,
                    theme: widget.theme,
                  ),
                ),
              ),
              SizedBox(height: widget.sizes.halfSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    key: const ValueKey('equipment-photo-recrop'),
                    onPressed: isBusy ? null : _recropCurrentPhoto,
                    icon: const Icon(Icons.crop),
                    label: const Text('Crop 4:3'),
                  ),
                  TextButton.icon(
                    key: const ValueKey('equipment-photo-remove'),
                    onPressed: isBusy ? null : _clearUploadedPhoto,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove'),
                  ),
                ],
              ),
            ] else if (_existingLocalPicture != null) ...[
              SizedBox(height: widget.sizes.spacing),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.sizes.buttonSize * 3.2,
                  ),
                  child: AppPicture(
                    picture: _existingLocalPicture!,
                    sizes: widget.sizes,
                    theme: widget.theme,
                    storageService: _storageService,
                  ),
                ),
              ),
              SizedBox(height: widget.sizes.halfSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_existingLocalPicture!.storage == PictureStorage.files)
                    TextButton.icon(
                      key: const ValueKey('equipment-photo-recrop'),
                      onPressed: isBusy ? null : _recropCurrentPhoto,
                      icon: const Icon(Icons.crop),
                      label: const Text('Crop 4:3'),
                    ),
                  TextButton.icon(
                    key: const ValueKey('equipment-photo-remove'),
                    onPressed: isBusy ? null : _clearUploadedPhoto,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove'),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(height: widget.sizes.spacing),
              Container(
                padding: EdgeInsets.all(widget.sizes.padding),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _uploadError != null
                        ? widget.theme.colorScheme.error
                        : widget.theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Text(
                  'Pick a photo from your camera or gallery to crop into horizontal 4:3.',
                  style: TextStyle(
                    fontSize: widget.sizes.smallFontSize,
                    color: isDarkTheme ? Colors.grey[400] : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (_uploadError != null) ...[
              SizedBox(height: widget.sizes.halfSpacing),
              Text(
                _uploadError!,
                style: TextStyle(
                  color: widget.theme.colorScheme.error,
                  fontSize: widget.sizes.smallFontSize,
                ),
              ),
            ],
          ],
          SizedBox(height: widget.sizes.spacing),
          AppElevatedButton(
            isLoading: isBusy,
            onPressed: _handleSubmit,
            sizes: widget.sizes,
            theme: widget.theme,
            label: widget.submitLabel,
            icon: widget.submitIcon ?? Icons.add,
          ),
        ],
      ),
    );
  }
}
