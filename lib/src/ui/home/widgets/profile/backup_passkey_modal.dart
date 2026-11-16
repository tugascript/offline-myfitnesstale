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

import 'package:material_ui/material_ui.dart';

import '../../../../data/utils/backup_passkey.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/themes/colors.dart';
import '../../../core/widgets/editors/save_buttons.dart';
import '../../../core/widgets/layout/app_modal.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';

class BackupPasskeyModal extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const BackupPasskeyModal({
    super.key,
    required this.theme,
    required this.sizes,
  });

  @override
  State<BackupPasskeyModal> createState() => _BackupPasskeyModalState();
}

class _BackupPasskeyModalState extends State<BackupPasskeyModal> {
  static const int _minPasskeyLength = 8;

  final _formKey = GlobalKey<FormState>();
  final _passkeyController = TextEditingController();
  final _confirmPasskeyController = TextEditingController();

  bool _obscurePasskey = true;
  bool _obscureConfirmPasskey = true;

  @override
  void dispose() {
    _passkeyController.dispose();
    _confirmPasskeyController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_passkeyController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final descriptionColor = ThemedColors.themedGrey.fromBrightness(
      widget.theme.brightness,
    );

    return AppModal(
      theme: widget.theme,
      sizes: widget.sizes,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.sizes.modalMaxWidth),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock, size: widget.sizes.iconSubtitleFontSize),
                  SizedBox(width: widget.sizes.halfSpacing),
                  Expanded(
                    child: Text(
                      "Set Backup Passkey",
                      style: TextStyle(
                        fontSize: widget.sizes.subtitleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: widget.sizes.halfSpacing),
              Text(
                "Create a passkey to encrypt your backups. You will need this passkey to restore your data.",
                style: TextStyle(
                  fontSize: widget.sizes.smallFontSize,
                  color: descriptionColor,
                ),
              ),
              SizedBox(height: widget.sizes.inputSpacing),
              AppTextFormField(
                key: const ValueKey('backup-passkey-input'),
                theme: widget.theme,
                controller: _passkeyController,
                labelText: "Passkey",
                hintText: "Enter passkey",
                fontSize: widget.sizes.fontSize,
                padding: widget.sizes.padding,
                isLoading: false,
                filled: true,
                obscureText: _obscurePasskey,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(Icons.key, size: widget.sizes.iconFontSize),
                suffixIcon: IconButton(
                  key: const ValueKey('backup-passkey-visibility'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _obscurePasskey ? Icons.visibility : Icons.visibility_off,
                    size: widget.sizes.iconFontSize,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePasskey = !_obscurePasskey;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a passkey";
                  }
                  if (value.length < _minPasskeyLength) {
                    return "Passkey must be at least $_minPasskeyLength characters";
                  }
                  if (isBackupPasskeyTooLong(value)) {
                    return "Passkey must be at most $backupPasskeyMaxBytes bytes";
                  }
                  return null;
                },
              ),
              SizedBox(height: widget.sizes.inputSpacing),
              AppTextFormField(
                key: const ValueKey('backup-passkey-confirm-input'),
                theme: widget.theme,
                controller: _confirmPasskeyController,
                labelText: "Confirm Passkey",
                hintText: "Re-enter passkey",
                fontSize: widget.sizes.fontSize,
                padding: widget.sizes.padding,
                isLoading: false,
                filled: true,
                obscureText: _obscureConfirmPasskey,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _onSave(),
                prefixIcon: Icon(Icons.key, size: widget.sizes.iconFontSize),
                suffixIcon: IconButton(
                  key: const ValueKey('backup-passkey-confirm-visibility'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _obscureConfirmPasskey
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: widget.sizes.iconFontSize,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPasskey = !_obscureConfirmPasskey;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm your passkey";
                  }
                  if (value != _passkeyController.text) {
                    return "Passkeys do not match";
                  }
                  return null;
                },
              ),
              SizedBox(height: widget.sizes.inputSpacing),
              SaveButtons(
                theme: widget.theme,
                sizes: widget.sizes,
                isLoading: false,
                onCancel: () => Navigator.of(context).pop(),
                onSave: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
