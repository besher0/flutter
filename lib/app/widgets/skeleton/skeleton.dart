/// Shared skeleton (shimmer) loading primitives.
///
/// Compose screen-specific skeletons from these: wrap the layout in one
/// [AppShimmer] and use [SkeletonBox] / [SkeletonText] / [SkeletonAvatar] /
/// [SkeletonChip] inside real-sized card chrome ([SkeletonCard]).
library;

export 'app_shimmer.dart';
export 'field_loading_placeholder.dart';
export 'skeleton_shapes.dart';
