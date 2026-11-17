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

sealed class YoutubeVideoUtils {
  static final RegExp _videoIdRegex = RegExp(r'^[A-Za-z0-9_-]{11}$');

  static const Set<String> _shortHosts = {'youtu.be'};

  static const Set<String> _standardHosts = {
    'youtube.com',
    'www.youtube.com',
    'm.youtube.com',
    'music.youtube.com',
    'youtube-nocookie.com',
    'www.youtube-nocookie.com',
  };

  static const Set<String> _pathIdPrefixes = {
    'shorts',
    'embed',
    'live',
    'v',
  };

  /// Extracts a valid 11-character YouTube video ID from [rawUrl].
  ///
  /// Returns `null` if [rawUrl] is not a valid `http`/`https` YouTube URL
  /// or does not contain a valid 11-character YouTube video ID.
  static String? extractVideoId(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return null;

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') return null;

    final host = uri.host.toLowerCase();
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

    String? candidateId;
    if (_shortHosts.contains(host)) {
      if (segments.length == 1) {
        candidateId = segments.first;
      }
    } else if (_standardHosts.contains(host)) {
      if (segments.length == 1 && segments.first == 'watch') {
        candidateId = uri.queryParameters['v'];
      } else if (segments.isEmpty) {
        candidateId = uri.queryParameters['v'];
      } else if (segments.length == 2 &&
          _pathIdPrefixes.contains(segments.first)) {
        candidateId = segments[1];
      }
    } else {
      return null;
    }

    if (candidateId == null || !_videoIdRegex.hasMatch(candidateId)) {
      return null;
    }

    return candidateId;
  }

  static bool isValidUrl(String rawUrl) => extractVideoId(rawUrl) != null;

  static String? validateOptionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (!isValidUrl(value)) {
      return 'Please enter a valid YouTube video URL';
    }
    return null;
  }
}
