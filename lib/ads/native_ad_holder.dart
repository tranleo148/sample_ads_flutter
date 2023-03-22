import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/color_const.dart';
import '../utils/constant.dart';

class NativeAdHolder extends StatefulWidget {
  final int loaded;
  final NativeAd? nativeAd;
  final double adSize;
  const NativeAdHolder({
    Key? key,
    required this.loaded,
    required this.nativeAd,
    required this.adSize,
  }) : super(key: key);

  @override
  State<NativeAdHolder> createState() => _AdHolderState();
}

class _AdHolderState extends State<NativeAdHolder> {
  late Widget _myAnimatedWidget;

  @override
  void initState() {
    super.initState();
    switch (widget.loaded) {
      case -1:
        _myAnimatedWidget = const SizedBox();
        break;
      case 0:
        _myAnimatedWidget = _buildNativeAdHolder();
        break;
      case 1:
        _myAnimatedWidget = _buildNativeAdWidget();
        break;
      default:
        _myAnimatedWidget = const SizedBox();
        break;
    }
  }

  @override
  void didUpdateWidget(NativeAdHolder oldWidget) {
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

  Widget _buildNativeAdWidget() {
    return Container(
      key: const ValueKey<int>(0),
      width: double.infinity,
      height: widget.adSize,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: AdWidget(
        ad: widget.nativeAd!,
      ),
    );
  }

  Widget _buildNativeAdHolder() {
    return Container(
      key: const ValueKey<int>(1),
      width: double.infinity,
      height: widget.adSize,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12, width: 2),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.black12,
        highlightColor: Colors.white70,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    color: Colors.black26,
                    width: 65,
                    height: 65,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.black26,
                        width: 120,
                        height: 15,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(6)),
                          border: Border.all(color: Colur.gnt_ad_green, width: 2),
                        ),
                        child: const Text(
                          'Ad',
                          style: TextStyle(color: Colur.gnt_ad_green, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                color: Colors.black12,
              ),
            ),
            Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.all(15),
              color: Colors.black12,
            ),
          ],
        ),
      ),
    );
  }

  void _onChangeStatus(int status) {
    Debug.printLog('NativeAd loaded:$status');

    setState(() {
      switch (status) {
        case -1:
          _myAnimatedWidget = const SizedBox();
          break;
        case 0:
          _myAnimatedWidget = _buildNativeAdHolder();
          break;
        case 1:
          _myAnimatedWidget = _buildNativeAdWidget();
          break;
        default:
          _myAnimatedWidget = const SizedBox();
          break;
      }
    });
  }
}
