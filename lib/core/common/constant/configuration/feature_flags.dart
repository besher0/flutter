import 'paid_content_policy.dart';

/// Product switches that can be changed per build without changing the main
/// subscription experience.
abstract final class SubscriptionFeatureFlags {
  SubscriptionFeatureFlags._();

  /// Keeps the historic code, point-of-sale and support actions available
  /// beneath the QR flow when a rollout needs them.
  static const bool showLegacySubscriptionMethods = false;

  /// Points of sale: a legacy method, and never shown on an iPhone whose
  /// admin setting hides paid content.
  static bool get showPointsOfSale =>
      showLegacySubscriptionMethods && !PaidContentPolicy.hidePaid;
}
