import 'package:ads_with_riverpod/Ads/Ad_AdMob/adControler_Provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    ref.read(admobProvider.notifier).loadBannerAd();
    ref.read(admobProvider.notifier).loadInterstitialAd();
    ref.read(admobProvider.notifier).loadRewardedAd();
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      print("Count: $_counter");
    });

    if (_counter % 5 == 0) {
      ref.read(admobProvider.notifier).showInterstitialAd();
    }

    if (_counter % 9 == 0) {
      ref.read(admobProvider.notifier).showRewardedAd(() {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reward earned!')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final adState = ref.watch(admobProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /// ---------------- Banner ----------------
            if (adState.bannerAd != null)
              SizedBox(
                width: adState.bannerAd!.size.width.toDouble(),
                height: adState.bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: adState.bannerAd!),
              ),
            Text(
              'You have pushed the button this many times: $_counter)',
              style: TextStyle(fontSize: 25),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
