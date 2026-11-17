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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myfitnesstale/src/data/repositories/core/dtos/video_dto.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/core/widgets/video/app_video_player.dart';
import 'package:myfitnesstale/src/ui/core/widgets/video/youtube_video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../support/fake_webview_platform.dart';

void main() {
  setUpAll(setUpFakeWebViewPlatform);

  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.md);

  testWidgets(
    'AppVideoPlayer renders YoutubeVideoPlayer and YoutubePlayer for valid YouTube URL',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppVideoPlayer(
                video: const VideoDto(
                  uri: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                  platform: VideoPlatform.youtube,
                ),
                sizes: sizes,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Video'), findsOneWidget);
      expect(find.byType(YoutubeVideoPlayer), findsOneWidget);
      expect(find.byType(YoutubePlayer), findsOneWidget);
    },
  );

  testWidgets(
    'AppVideoPlayer renders invalid URL message for invalid YouTube URL',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppVideoPlayer(
              video: const VideoDto(
                uri: 'https://youtu.be/invalid',
                platform: VideoPlatform.youtube,
              ),
              sizes: sizes,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Invalid YouTube video URL'), findsOneWidget);
      expect(find.byType(YoutubePlayer), findsNothing);
    },
  );

  testWidgets(
    'AppVideoPlayer renders unsupported platform message for non-YouTube platforms',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppVideoPlayer(
              video: const VideoDto(
                uri: 'https://vimeo.com/123456',
                platform: VideoPlatform.vimeo,
              ),
              sizes: sizes,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text('Video platform "vimeo" is not supported yet'),
        findsOneWidget,
      );
      expect(find.byType(YoutubeVideoPlayer), findsNothing);
    },
  );
}
