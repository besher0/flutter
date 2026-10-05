/// Product switches that can be changed per build without changing the main
/// subscription experience.
abstract final class SubscriptionFeatureFlags {
  SubscriptionFeatureFlags._();

  /// Keeps the historic code, point-of-sale and support actions available
  /// beneath the QR flow when a rollout needs them.
  static const bool showLegacySubscriptionMethods = false;
}
