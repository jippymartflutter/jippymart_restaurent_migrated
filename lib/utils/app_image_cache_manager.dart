import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Centralized disk-cache configuration for all network images.
///
/// - Reduces server load (re-uses cached files)
/// - Makes scrolling smoother (less re-fetching)
/// - Keeps cache bounded
class AppImageCacheManager extends CacheManager {
  AppImageCacheManager._()
      : super(
          Config(
            'appImageCache',
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 200,
            // Note: this version of flutter_cache_manager doesn't support a byte-size
            // limit (e.g. maxCacheSize). We cap by object count + stalePeriod.
          ),
        );

  static final AppImageCacheManager instance = AppImageCacheManager._();
}

