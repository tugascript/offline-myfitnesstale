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

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/themes/colors.dart';
import '../../../core/widgets/layout/app_dropdown.dart';
import '../../../core/widgets/layout/sharp_switch.dart';
import 'backup_passkey_modal.dart';

class BackupSettingsConfig extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isDarkTheme;
  final bool isLoading;

  const BackupSettingsConfig({
    super.key,
    required this.sizes,
    required this.theme,
    required this.isDarkTheme,
    required this.isLoading,
  });

  @override
  State<BackupSettingsConfig> createState() => _BackupSettingsConfigState();
}

class _BackupSettingsConfigState extends State<BackupSettingsConfig> {
  bool _backupsOn = false;
  BackupSchedule _schedule = BackupSchedule.daily;
  late BackupProvider _provider;
  bool _encrypted = false;

  @override
  void initState() {
    super.initState();
    _provider = defaultTargetPlatform == TargetPlatform.iOS
        ? BackupProvider.iCloud
        : BackupProvider.googleDrive;
  }

  Future<void> _onEncryptedChanged(bool value) async {
    if (widget.isLoading || !_backupsOn) {
      return;
    }

    if (!value) {
      setState(() {
        _encrypted = false;
      });
      return;
    }

    final passkey = await showDialog<String>(
      context: context,
      builder: (_) =>
          BackupPasskeyModal(theme: widget.theme, sizes: widget.sizes),
    );

    if (passkey != null && passkey.isNotEmpty && mounted) {
      // Passkey will be hashed and persisted once wired to a backup cubit.
      setState(() {
        _encrypted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = widget.isDarkTheme
        ? ThemedColors.themedGrey.light
        : ThemedColors.themedGrey.dark;

    return Column(
      key: const ValueKey('profile-backup-settings'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.backup, size: widget.sizes.iconSubtitleFontSize),
            Text(
              " Backups",
              style: TextStyle(
                fontSize: widget.sizes.subtitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: widget.sizes.halfSpacing),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: widget.sizes.profileLabelWidth,
              child: Text(
                "Backups",
                style: TextStyle(
                  fontSize: widget.sizes.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
            ),
            SharpSwitch(
              key: const ValueKey('backup-backups-on'),
              value: _backupsOn,
              enabled: !widget.isLoading,
              onChanged: (value) {
                if (!widget.isLoading) {
                  setState(() {
                    _backupsOn = value;
                  });
                }
              },
              thumbSize: widget.sizes.subtitleFontSize,
              padding: EdgeInsets.all(widget.sizes.halfSpacing),
            ),
            SizedBox(width: widget.sizes.halfSpacing),
            Expanded(
              child: KeyedSubtree(
                key: const ValueKey('backup-schedule'),
                child: AppDropdown<BackupSchedule>(
                  key: ValueKey(_schedule),
                  theme: widget.theme,
                  filled: true,
                  value: _schedule,
                  emptyLabel: '',
                  showEmptyValue: false,
                  items: BackupSchedule.values,
                  labelBuilder: _formatSchedule,
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.halfSpacing,
                  isLoading: widget.isLoading,
                  enabled: _backupsOn,
                  prefixIcon: Icon(
                    Icons.schedule,
                    size: widget.sizes.iconFontSize,
                  ),
                  onChanged: (schedule) {
                    if (schedule != null) {
                      setState(() {
                        _schedule = schedule;
                      });
                    }
                  },
                  onSaved: (_) {},
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: widget.sizes.spacing),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: widget.sizes.profileLabelWidth,
              child: Text(
                "Provider",
                style: TextStyle(
                  fontSize: widget.sizes.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
            ),
            Expanded(
              child: KeyedSubtree(
                key: const ValueKey('backup-provider'),
                child: AppDropdown<BackupProvider>(
                  key: ValueKey(_provider),
                  theme: widget.theme,
                  filled: true,
                  value: _provider,
                  emptyLabel: '',
                  showEmptyValue: false,
                  items: BackupProvider.supportedValues(),
                  labelBuilder: _formatProvider,
                  fontSize: widget.sizes.fontSize,
                  padding: widget.sizes.halfSpacing,
                  isLoading: widget.isLoading,
                  enabled: _backupsOn,
                  prefixIcon: Icon(
                    Icons.cloud_outlined,
                    size: widget.sizes.iconFontSize,
                  ),
                  onChanged: (provider) {
                    if (provider != null) {
                      setState(() {
                        _provider = provider;
                      });
                    }
                  },
                  onSaved: (_) {},
                ),
              ),
            ),
            SizedBox(width: widget.sizes.halfSpacing),
            Tooltip(
              message: "Encrypt backups",
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _encrypted ? Icons.lock : Icons.lock_open,
                    size: widget.sizes.iconFontSize,
                    color: _backupsOn
                        ? (_encrypted
                              ? widget.theme.colorScheme.primary
                              : titleColor)
                        : widget.theme.disabledColor,
                  ),
                  SizedBox(width: widget.sizes.quarterSpacing),
                  SharpSwitch(
                    key: const ValueKey('backup-encrypted'),
                    value: _encrypted,
                    enabled: !widget.isLoading && _backupsOn,
                    onChanged: _onEncryptedChanged,
                    thumbSize: widget.sizes.subtitleFontSize,
                    padding: EdgeInsets.all(widget.sizes.halfSpacing),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatSchedule(BackupSchedule schedule) => switch (schedule) {
    BackupSchedule.daily => 'Daily',
    BackupSchedule.weekly => 'Weekly',
    BackupSchedule.monthly => 'Monthly',
  };

  String _formatProvider(BackupProvider provider) => switch (provider) {
    BackupProvider.googleDrive => 'Google Drive',
    BackupProvider.iCloud => 'iCloud',
    BackupProvider.oneDrive => 'OneDrive',
    BackupProvider.localFile => 'Local File',
    BackupProvider.myFitnessTale => 'My Fitness Tale',
  };
}
