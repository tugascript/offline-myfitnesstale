// Copyright (C) 2026 afonsobarracha
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

import 'package:flutter/material.dart';

import '../../sizes/data_display_sizes.dart';
import '../layout/app_text_form_field.dart';

class ExpandingDynamicInputWrapper extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;

  final bool initiallyExpanded;
  final String title;
  final String labelText;
  final Widget? prefixIcon;
  final List<Widget> children;

  const ExpandingDynamicInputWrapper({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.initiallyExpanded,
    required this.title,
    required this.labelText,
    this.prefixIcon,
    required this.children,
  });

  @override
  State<ExpandingDynamicInputWrapper> createState() =>
      _ExpandingDynamicInputWrapperState();
}

class _ExpandingDynamicInputWrapperState
    extends State<ExpandingDynamicInputWrapper> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: IgnorePointer(
            child: AppTextFormField(
              key: ValueKey(widget.title),
              filled: true,
              theme: widget.theme,
              labelText: widget.labelText,
              prefixIcon: widget.prefixIcon,
              fontSize: widget.sizes.fontSize,
              padding: widget.sizes.padding,
              isLoading: widget.isLoading,
              initialValue: widget.title,
              readOnly: true,
              enabled: true,
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: widget.sizes.spacing / 2),
                child: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: _isExpanded
                      ? widget.theme.colorScheme.secondary
                      : widget.theme.colorScheme.onSurface,
                  size: widget.sizes.fontSize * 1.5,
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          alignment: Alignment.topCenter,
          child: AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.children,
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ),
      ],
    );
  }
}
