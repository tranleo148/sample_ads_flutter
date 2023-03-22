import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../utils/color_const.dart';
import 'ad_loading_controller.dart';

class AdLoadingDialog extends StatefulWidget {
  const AdLoadingDialog({Key? key}) : super(key: key);

  @override
  State<AdLoadingDialog> createState() => _AdLoadingState();
}

class _AdLoadingState extends State<AdLoadingDialog> {
  @override
  void initState() {
    super.initState();
    /*SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.white,
    ));*/
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // This to prevent user press back button to close loading dialog
        return false;
      },
      child: Scaffold(
        body: GetBuilder<AdLoadingController>(
          init: AdLoadingController(),
          builder: (adLoadingCtl) {
            return !adLoadingCtl.hideLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SpinKitCircle(
                        color: Colur.txt_white,
                        size: 50.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Loading Ads…',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ),
                    ],
                  )
                : const SizedBox();
          },
        ),
      ),
    );
  }
}
