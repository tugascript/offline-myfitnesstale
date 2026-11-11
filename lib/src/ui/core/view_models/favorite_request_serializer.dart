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

/// Mixin that serializes asynchronous favorite toggle requests per Cubit so
/// concurrent toggles execute sequentially in FIFO order.
mixin FavoriteRequestSerializer {
  Future<void> _favoriteRequestChain = Future<void>.value();

  /// Enqueues [action] behind any pending favorite mutation on this instance.
  Future<R> serializeFavorite<R>(Future<R> Function() action) {
    final completer = Completer<R>();
    final previous = _favoriteRequestChain;
    final next = () async {
      try {
        await previous;
      } catch (_) {
        // Keep later favorite updates running if an earlier call failed.
      }
      try {
        completer.complete(await action());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    }();
    _favoriteRequestChain = next;
    return completer.future;
  }
}
