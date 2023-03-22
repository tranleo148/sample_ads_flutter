import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension BuildContextX on BuildContext {
  Future<dynamic> showCustomDialog({
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: this,
      builder: (context) => AlertDialog(
        title: title,
        content: content,
        actions: actions,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  Future<dynamic> showCircularDialog() {
    return showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  void dismissDialog() {
    Navigator.of(this).pop();
  }

  ThemeData get theme => Theme.of(this);

  Size get screenSize => MediaQuery.of(this).size;

  double get topStatusBarPadding => MediaQuery.of(this).padding.top;

  // 24 = FloatingActionButton.regular
  // 5 = Padding between bottomNavigationBar and floatingActionButton
  double get bottomNavigationBarPadding => MediaQuery.of(this).padding.bottom + 24 + 5;

  double widthInPercent(double percent) {
    final toDouble = percent / 100;

    return MediaQuery.of(this).size.width * toDouble;
  }

  double heightInPercent(double percent) {
    final toDouble = percent / 100;

    return MediaQuery.of(this).size.height * toDouble;
  }
}

extension ExtensionIntX on int {
  String get toCurrencyString => NumberFormat('#,##0', 'en_US').format(this);
}

extension ColorX on Color {
  String toHexTriplet() =>
      '#${(value & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0').toUpperCase()}';
}
