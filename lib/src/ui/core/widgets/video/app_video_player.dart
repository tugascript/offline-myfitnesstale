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

import '../../../../data/repositories/core/dtos/video_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../sizes/data_display_sizes.dart';
import 'youtube_video_player.dart';

class AppVideoPlayer extends StatelessWidget {
  final VideoDto video;
  final DataDisplaySizesList sizes;
  final ThemeData? theme;
  final String? title;
  final double aspectRatio;
  final bool autoPlay;

  const AppVideoPlayer({
    super.key,
    required this.video,
    required this.sizes,
    this.theme,
    this.title = 'Video',
    this.aspectRatio = 16 / 9,
    this.autoPlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ?? Theme.of(context);
    final isDarkTheme = resolvedTheme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty) ...[
          Text(
            title!,
            style: TextStyle(
              fontSize: sizes.titleFontSize,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.grey[200] : Colors.grey[800],
            ),
          ),
          SizedBox(height: sizes.spacing),
        ],
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(sizes.halfPadding),
            child: _buildPlayer(resolvedTheme, isDarkTheme),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayer(ThemeData resolvedTheme, bool isDarkTheme) {
    switch (video.platform) {
      case VideoPlatform.youtube:
        return YoutubeVideoPlayer(
          videoUrl: video.uri,
          sizes: sizes,
          theme: resolvedTheme,
          aspectRatio: aspectRatio,
          autoPlay: autoPlay,
        );
      case VideoPlatform.vimeo:
      case VideoPlatform.facebook:
      case VideoPlatform.tiktok:
      case VideoPlatform.instagram:
      case VideoPlatform.dailymotion:
      case VideoPlatform.assets:
      case VideoPlatform.files:
      case VideoPlatform.custom:
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            color: isDarkTheme ? Colors.grey[900] : Colors.grey[200],
            padding: EdgeInsets.all(sizes.padding),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.ondemand_video,
                    size: sizes.largeIconSize * 0.75,
                    color: Colors.grey,
                  ),
                  SizedBox(height: sizes.halfSpacing),
                  Text(
                    'Video platform "${video.platform.value}" is not supported yet',
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      color: isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
