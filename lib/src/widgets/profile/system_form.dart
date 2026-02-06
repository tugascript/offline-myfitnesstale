import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../utilities/sizes/profile/modal_form_sizes.dart';
import '../../utilities/sizes/screen_size.dart';

final class _FormData {
  Units units;
  ThemeType themeMode;
  bool notificationsOn;

  _FormData({
    required this.units,
    required this.themeMode,
    required this.notificationsOn,
  });
}

final class SystemForm extends StatefulWidget {
  final BuildContext ctx;
  final Units initialUnits;
  final ThemeType initialThemeMode;
  final bool initialNotificationsOn;
  final void Function({
    required Units units,
    required ThemeType themeMode,
    required bool notificationsOn,
  }) onSubmit;
  final bool isLoading;

  const SystemForm({
    super.key,
    required this.ctx,
    required this.initialUnits,
    required this.initialThemeMode,
    required this.initialNotificationsOn,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<SystemForm> createState() => _SystemFormState();
}

class _SystemFormState extends State<SystemForm> {
  static const String _route = "/setup/system";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    _data = _FormData(
      units: widget.initialUnits,
      themeMode: widget.initialThemeMode,
      notificationsOn: widget.initialNotificationsOn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMetric = _data.units == Units.metric;
    final BreakPoint breakPoint = BreakPoint.fromContext(widget.ctx);
    final ModalFormSizesList sizes = ModalFormSizes.getNavFormSizes(
      breakPoint.screenSize,
      breakPoint.width,
    );

    return Form(
      key: _formKey,
      child: AlertDialog(
        content: SizedBox(
          width: sizes.width,
          height: sizes.height,
          child: Column(
            children: [
              SegmentedButton(
                segments: <ButtonSegment<ThemeType>>[
                  ButtonSegment(
                    label: Text(
                      "Light",
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                      ),
                    ),
                    icon: Icon(
                      Icons.light_mode,
                      size: sizes.iconSize,
                    ),
                    value: ThemeType.light,
                  ),
                  ButtonSegment(
                    label: Text(
                      "System",
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                      ),
                    ),
                    icon: Icon(
                      Icons.settings,
                      size: sizes.iconSize,
                    ),
                    value: ThemeType.system,
                  ),
                  ButtonSegment(
                    label: Text(
                      "Dark",
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                      ),
                    ),
                    icon: Icon(
                      Icons.dark_mode,
                      size: sizes.iconSize,
                    ),
                    value: ThemeType.dark,
                  ),
                ],
                selected: <ThemeType>{_data.themeMode},
                onSelectionChanged: (Set<ThemeType> selected) {
                  setState(() {
                    _data.themeMode = selected.first;
                  });
                },
              ),
              SwitchListTile(
                title: Row(
                  children: [
                    Icon(Icons.height_rounded, size: sizes.iconSize),
                    SizedBox(width: sizes.fontSize / 2),
                    Text(
                      "Units ${isMetric ? "Metric" : "Imperial"}",
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                      ),
                    ),
                  ],
                ),
                value: isMetric,
                onChanged: (bool value) {
                  if (widget.isLoading) return;

                  setState(() {
                    _data.units = value ? Units.metric : Units.imperial;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (widget.isLoading) return;

              widget.onSubmit(
                units: _data.units,
                themeMode: _data.themeMode,
                notificationsOn: _data.notificationsOn,
              );
              Navigator.pop(context, _route);
            },
            child: Text(
              widget.isLoading ? "Loading..." : "Confirm",
              style: TextStyle(
                fontSize: sizes.fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
