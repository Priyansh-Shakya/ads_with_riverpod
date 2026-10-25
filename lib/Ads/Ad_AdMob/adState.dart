import 'package:google_mobile_ads/google_mobile_ads.dart';

// AdState
class AdState {
  final BannerAd? bannerAd;
  final InterstitialAd? interstitialAd;
  final RewardedAd? rewardedAd;
  AdState({this.bannerAd, this.interstitialAd, this.rewardedAd});

  AdState copyWith({
    BannerAd? bannerAd,
    InterstitialAd? interstitialAd,
    RewardedAd? rewardedAd,
  }) {
    return AdState(
      bannerAd: bannerAd ?? this.bannerAd,
      interstitialAd: interstitialAd ?? this.interstitialAd,
      rewardedAd: rewardedAd ?? this.rewardedAd,
    );
  }
}
