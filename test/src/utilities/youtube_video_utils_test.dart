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
import 'package:myfitnesstale/src/data/utils/youtube_video_utils.dart';

void main() {
  group('YoutubeVideoUtils.extractVideoId', () {
    test('extracts ID from standard youtube.com watch URLs', () {
      expect(
        YoutubeVideoUtils.extractVideoId(
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        'dQw4w9WgXcQ',
      );
      expect(
        YoutubeVideoUtils.extractVideoId(
          'http://youtube.com/watch?v=dQw4w9WgXcQ&t=42s',
        ),
        'dQw4w9WgXcQ',
      );
      expect(
        YoutubeVideoUtils.extractVideoId(
          'https://m.youtube.com/watch?feature=share&v=a_B-1234567',
        ),
        'a_B-1234567',
      );
      expect(
        YoutubeVideoUtils.extractVideoId(
          'https://music.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        'dQw4w9WgXcQ',
      );
    });

    test('extracts ID from youtu.be, shorts, embed, and live URLs', () {
      expect(
        YoutubeVideoUtils.extractVideoId('https://youtu.be/dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
      expect(
        YoutubeVideoUtils.extractVideoId('https://youtu.be/dQw4w9WgXcQ?si=abc'),
        'dQw4w9WgXcQ',
      );
      expect(
        YoutubeVideoUtils.extractVideoId(
          'https://www.youtube.com/shorts/dQw4w9WgXcQ',
        ),
        'dQw4w9WgXcQ',
      );
      expect(
        YoutubeVideoUtils.extractVideoId(
          'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ',
        ),
        'dQw4w9WgXcQ',
      );
      expect(
        YoutubeVideoUtils.extractVideoId(
          'https://www.youtube.com/live/dQw4w9WgXcQ?feature=share',
        ),
        'dQw4w9WgXcQ',
      );
    });

    test('rejects non-YouTube URLs, bare IDs, and invalid video IDs', () {
      expect(
        YoutubeVideoUtils.extractVideoId('https://vimeo.com/12345678901'),
        isNull,
      );
      expect(
        YoutubeVideoUtils.extractVideoId(
          'https://evil-youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        isNull,
      );
      expect(YoutubeVideoUtils.extractVideoId('dQw4w9WgXcQ'), isNull);
      expect(
        YoutubeVideoUtils.extractVideoId('https://youtu.be/example'),
        isNull,
      );
      expect(
        YoutubeVideoUtils.extractVideoId(
          'https://www.youtube.com/watch?v=too_short',
        ),
        isNull,
      );
      expect(
        YoutubeVideoUtils.extractVideoId('https://www.youtube.com/'),
        isNull,
      );
      expect(
        YoutubeVideoUtils.extractVideoId('ftp://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        isNull,
      );
      expect(YoutubeVideoUtils.extractVideoId('   '), isNull);
    });
  });

  group('YoutubeVideoUtils.validateOptionalUrl', () {
    test('allows null and empty/whitespace strings', () {
      expect(YoutubeVideoUtils.validateOptionalUrl(null), isNull);
      expect(YoutubeVideoUtils.validateOptionalUrl(''), isNull);
      expect(YoutubeVideoUtils.validateOptionalUrl('   '), isNull);
    });

    test('validates non-empty YouTube URLs', () {
      expect(
        YoutubeVideoUtils.validateOptionalUrl(
          '  https://www.youtube.com/watch?v=dQw4w9WgXcQ  ',
        ),
        isNull,
      );
      expect(
        YoutubeVideoUtils.validateOptionalUrl('https://vimeo.com/123456'),
        isNotNull,
      );
      expect(
        YoutubeVideoUtils.validateOptionalUrl('https://youtu.be/short'),
        isNotNull,
      );
    });
  });
}
