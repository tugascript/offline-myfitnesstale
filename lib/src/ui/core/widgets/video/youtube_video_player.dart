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

import 'package:material_ui/material_ui.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../data/utils/youtube_video_utils.dart';
import '../../sizes/data_display_sizes.dart';

class YoutubeVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final DataDisplaySizesList sizes;
  final ThemeData? theme;
  final double aspectRatio;
  final bool autoPlay;

  const YoutubeVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.sizes,
    this.theme,
    this.aspectRatio = 16 / 9,
    this.autoPlay = false,
  });

  @override
  State<YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _playerSub;
  String? _videoId;
  bool _hasLoadError = false;

  @override
  void initState() {
    super.initState();
    _initForUrl(widget.videoUrl);
  }

  void _initForUrl(String url) {
    _videoId = YoutubeVideoUtils.extractVideoId(url);
    _hasLoadError = false;
    if (_videoId == null) return;

    final controller = YoutubePlayerController(
      key: _videoId,
      params: const YoutubePlayerParams(showFullscreenButton: true),
      onWebResourceError: (_) {
        if (mounted && !_hasLoadError) {
          setState(() {
            _hasLoadError = true;
          });
        }
      },
    );

    _playerSub = controller.stream.listen((value) {
      if (value.hasError && mounted && !_hasLoadError) {
        setState(() {
          _hasLoadError = true;
        });
      }
    });

    if (widget.autoPlay) {
      unawaited(controller.loadVideoById(videoId: _videoId!));
    } else {
      unawaited(controller.cueVideoById(videoId: _videoId!));
    }

    _controller = controller;
  }

  @override
  void didUpdateWidget(covariant YoutubeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl == widget.videoUrl) return;

    final nextId = YoutubeVideoUtils.extractVideoId(widget.videoUrl);
    if (nextId == _videoId) return;

    _videoId = nextId;
    _hasLoadError = false;

    if (nextId == null) {
      unawaited(_playerSub?.cancel());
      _playerSub = null;
      unawaited(_controller?.close());
      _controller = null;
      return;
    }

    if (_controller != null) {
      if (widget.autoPlay) {
        unawaited(_controller!.loadVideoById(videoId: nextId));
      } else {
        unawaited(_controller!.cueVideoById(videoId: nextId));
      }
    } else {
      _initForUrl(widget.videoUrl);
    }
  }

  @override
  void dispose() {
    unawaited(_playerSub?.cancel());
    unawaited(_controller?.close());
    super.dispose();
  }

  void _retry() {
    final id = _videoId;
    if (id == null) return;
    setState(() {
      _hasLoadError = false;
    });
    if (_controller != null) {
      if (widget.autoPlay) {
        unawaited(_controller!.loadVideoById(videoId: id));
      } else {
        unawaited(_controller!.cueVideoById(videoId: id));
      }
    } else {
      _initForUrl(widget.videoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = widget.theme ?? Theme.of(context);
    final isDarkTheme = resolvedTheme.brightness == Brightness.dark;

    if (_videoId == null || _controller == null || _hasLoadError) {
      final isInvalid = _videoId == null;
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Container(
          color: isDarkTheme ? Colors.grey[900] : Colors.grey[200],
          padding: EdgeInsets.all(widget.sizes.padding),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isInvalid ? Icons.link_off : Icons.wifi_off,
                  size: widget.sizes.largeIconSize * 0.75,
                  color: Colors.grey,
                ),
                SizedBox(height: widget.sizes.halfSpacing),
                Text(
                  isInvalid
                      ? 'Invalid YouTube video URL'
                      : 'Unable to load YouTube video',
                  style: TextStyle(
                    fontSize: widget.sizes.fontSize,
                    color: isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!isInvalid) ...[
                  SizedBox(height: widget.sizes.halfSpacing),
                  TextButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    final existingExtensions = resolvedTheme.extensions.values.where(
      (ext) => ext is! YoutubePlayerTheme,
    );

    return Theme(
      data: resolvedTheme.copyWith(
        extensions: [
          ...existingExtensions,
          YoutubePlayerTheme(
            progressBarActiveColor: resolvedTheme.colorScheme.primary,
            progressBarBufferedColor: resolvedTheme.colorScheme.secondary
                .withValues(alpha: 0.4),
          ),
        ],
      ),
      child: YoutubePlayer(
        controller: _controller!,
        aspectRatio: widget.aspectRatio,
      ),
    );
  }
}
