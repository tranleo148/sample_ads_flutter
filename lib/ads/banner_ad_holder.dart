import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/color_const.dart';
import '../utils/constant.dart';

class BannerAdHolder extends StatefulWidget {
  final int loaded;
  final BannerAd? bannerAd;
  const BannerAdHolder({
    Key? key,
    required this.loaded,
    required this.bannerAd,
  }) : super(key: key);

  @override
  State<BannerAdHolder> createState() => _AdHolderState();
}

class _AdHolderState extends State<BannerAdHolder> {
  late Widget _myAnimatedWidget;

  @override
  void initState() {
    super.initState();
    switch (widget.loaded) {
      case -1:
        _myAnimatedWidget = const SizedBox();
        break;
      case 0:
        _myAnimatedWidget = _buildBannerAdHolder();
        break;
      case 1:
        _myAnimatedWidget = _buildBannerAdWidget();
        break;
      default:
        _myAnimatedWidget = const SizedBox();
        break;
    }
  }

  @override
  void didUpdateWidget(BannerAdHolder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.loaded != oldWidget.loaded) {
      _onChangeStatus(widget.loaded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: _myAnimatedWidget,
    );
  }

  Widget _buildBannerAdWidget() {
    return Align(
      key: const ValueKey<int>(0),
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: widget.bannerAd?.size.width.toDouble(),
        height: widget.bannerAd?.size.height.toDouble(),
        child: AdWidget(ad: widget.bannerAd!),
      ),
    );
  }

  Widget _buildBannerAdHolder() {
    return Container(
      key: const ValueKey<int>(1),
      width: double.infinity,
      height: 50.0,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.black12,
        highlightColor: Colors.white70,
        child: Container(
          margin: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 10),
                color: Colors.black26,
                width: 38,
                height: 38,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.black26,
                      width: 120,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      border: Border.all(color: Colur.gnt_ad_green, width: 2),
                    ),
                    child: const Text(
                      'Ad',
                      style: TextStyle(color: Colur.gnt_ad_green, fontSize: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onChangeStatus(int status) {
    Debug.printLog('BannerAd loaded:$status');

    setState(() {
      switch (status) {
        case -1:
          _myAnimatedWidget = const SizedBox();
          break;
        case 0:
          _myAnimatedWidget = _buildBannerAdHolder();
          break;
        case 1:
          _myAnimatedWidget = _buildBannerAdWidget();
          break;
        default:
          _myAnimatedWidget = const SizedBox();
          break;
      }
    });
  }
}
