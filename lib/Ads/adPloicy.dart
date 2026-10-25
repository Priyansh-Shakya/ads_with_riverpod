enum AdType { interstitial, rewarded }

class AdPolicy {
  static const Duration interstitialCooldown = Duration(seconds: 60);
  static const Duration rewardedCooldown = Duration(seconds: 180);

  /// Prevents showing two fullscreen ads back-to-back
  static const Duration fullscreenGap = Duration(seconds: 5);

  bool canShow({
    required AdType type,
    DateTime? lastShown,
    DateTime? lastAnyFullscreenShown,
  }) {
    final now = DateTime.now();

    // First time → allow
    if (lastShown == null) return true;

    // Cooldown check
    final cooldown = switch (type) {
      AdType.interstitial => interstitialCooldown,
      AdType.rewarded => rewardedCooldown,
    };

    if (now.difference(lastShown) < cooldown) {
      return false;
    }

    // Clash protection (interstitial ↔ rewarded)
    if (lastAnyFullscreenShown != null &&
        now.difference(lastAnyFullscreenShown) < fullscreenGap) {
      return false;
    }

    return true;
  }
}

class AdPolicyState {
  DateTime? lastInterstitialShown;
  DateTime? lastRewardedShown;
  DateTime? lastFullscreenShown;

  void markShown(AdType type) {
    final now = DateTime.now();
    lastFullscreenShown = now;

    if (type == AdType.interstitial) {
      lastInterstitialShown = now;
    } else {
      lastRewardedShown = now;
    }
  }
}
