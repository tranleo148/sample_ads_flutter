import 'package:flutter/material.dart';

import '../interfaces/top_bar_click_listener.dart';
import '../utils/color_const.dart';
import '../utils/constant.dart';

class CommonTopBar extends StatefulWidget {
  final String headerName;
  final TopBarClickListener clickListener;

  final bool isShowBack;
  final bool isShowSetting;

  final bool isShowSettingCircle;
  final bool isDelete;
  final bool isClose;
  final bool isInfo;
  final bool isOptions;
  final bool isShowSubheader;

  final String? subHeader;

  const CommonTopBar(
    this.headerName,
    this.clickListener, {
    Key? key,
    this.isShowBack = false,
    this.isShowSetting = false,
    this.isDelete = false,
    this.isClose = false,
    this.isInfo = false,
    this.isOptions = false,
    this.isShowSubheader = false,
    this.isShowSettingCircle = false,
    this.subHeader,
  }) : super(key: key);

  @override
  State<CommonTopBar> createState() => _CommonTopBarState();
}

class _CommonTopBarState extends State<CommonTopBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                widget.clickListener.onTopBarClick(Constant.STR_BACK);
              },
              child: Visibility(
                visible: widget.isShowBack,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 15.0, right: 25.0),
                  child: Image.asset(
                    'assets/icons/ic_back_white.png',
                    color: Colur.primary_theme_dark,
                    scale: 3.7,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                widget.clickListener.onTopBarClick(Constant.STR_CLOSE);
              },
              child: Visibility(
                visible: widget.isClose,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(left: 15.0, top: 5, bottom: 5, right: 15),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colur.gray_border,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(15))),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/icons/ic_close.png',
                      color: Colur.primary_theme_dark,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.headerName,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 22, color: Colur.txt_white),
                      ),
                      Visibility(
                        visible: widget.isShowSubheader,
                        child: Text(
                          widget.isShowSubheader ? widget.subHeader! : "",
                          style: const TextStyle(
                              color: Colur.txt_grey, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                )),
            InkWell(
              onTap: () {
                widget.clickListener.onTopBarClick(Constant.STR_SETTING);
              },
              child: Visibility(
                visible: widget.isShowSetting,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 15.0, top: 5, bottom: 5, left: 15),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colur.gray_border,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(15))),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/icons/ic_setting.png',
                      color: Colur.primary_theme_dark,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                widget.clickListener.onTopBarClick(Constant.STR_SETTING_CIRCLE);
              },
              child: Visibility(
                visible: widget.isShowSettingCircle,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 15.0, top: 5, bottom: 5, left: 15),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colur.gray_border,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(15))),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/icons/ic_setting_circular.png',
                      color: Colur.primary_theme_dark,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                widget.clickListener.onTopBarClick(Constant.STR_DELETE);
              },
              child: Visibility(
                visible: widget.isDelete,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 15.0, top: 5, bottom: 5, left: 15),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colur.gray_border,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(15))),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/icons/ic_delete.png',
                      color: Colur.primary_theme_dark,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                widget.clickListener.onTopBarClick(Constant.STR_INFO);
              },
              child: Visibility(
                visible: widget.isInfo,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 15.0, top: 5, bottom: 5),
                  child: Image.asset(
                    'assets/icons/ic_info.png',
                    color: Colur.primary_theme_dark,
                    width: 42,
                    height: 42,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                widget.clickListener.onTopBarClick(Constant.STR_OPTIONS);
              },
              child: Visibility(
                visible: widget.isOptions,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 15.0, top: 5, bottom: 5, left: 15.0),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colur.gray_border,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(15))),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/icons/ic_options.png',
                      color: Colur.primary_theme_dark,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
