import 'dart:ui';
import 'package:ads_with_riverpod/Ads/Ad_AdMob/adHelper.dart';
import 'package:ads_with_riverpod/Ads/Ad_AdMob/adState.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ads_with_riverpod/Ads/adPloicy.dart';

// Provider
final admobProvider = StateNotifierProvider<AdmobController, AdState>((ref) {
  return AdmobController();
});

//Ad Controller
class AdmobController extends StateNotifier<AdState> {
  AdmobController()
    : super(AdState(bannerAd: null, interstitialAd: null, rewardedAd: null));

  final AdPolicy _policy = AdPolicy();
  final AdPolicyState _policyState = AdPolicyState();

  // ---------------- Banner ----------------
  Future<void> loadBannerAd() async {
    return BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          state = state.copyWith(bannerAd: ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    ).load();
  }

  // ---------------- Interstitial ----------------
  Future<void> loadInterstitialAd() {
    return InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) async {
              ad.dispose();
              await loadInterstitialAd();
            },
          );

          state = state.copyWith(interstitialAd: ad);
        },
        onAdFailedToLoad: (err) {},
      ),
    );
  }

  void showInterstitialAd() {
    debugPrint('[ADS] showInterstitial requested');

    final ad = state.interstitialAd;

    debugPrint('[ADS] ad exists: ${ad != null}');

    if (ad == null) return;

    final canShow = _policy.canShow(
      type: AdType.interstitial,
      lastShown: _policyState.lastInterstitialShown,
      lastAnyFullscreenShown: _policyState.lastFullscreenShown,
    );

    debugPrint('[ADS] allowed by policy: ${canShow}');

    if (!canShow) return;

    ad.show();
    _policyState.markShown(AdType.interstitial);

    state = state.copyWith(interstitialAd: null);
  }

  // ---------------- Rewarded ----------------
  Future<void> loadRewardedAd() {
    return RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) async {
              ad.dispose();
              await loadRewardedAd();
            },
          );

          state = state.copyWith(rewardedAd: ad);
        },
        onAdFailedToLoad: (err) {},
      ),
    );
  }

  void showRewardedAd(VoidCallback onRewardEarned) {
    final ad = state.rewardedAd;

    if (ad == null) return;

    final canShow = _policy.canShow(
      type: AdType.rewarded,
      lastShown: _policyState.lastRewardedShown,
      lastAnyFullscreenShown: _policyState.lastFullscreenShown,
    );

    if (!canShow) return;

    ad.show(onUserEarnedReward: (_, __) => onRewardEarned());
    _policyState.markShown(AdType.rewarded);

    state = state.copyWith(rewardedAd: null);
  }
}
