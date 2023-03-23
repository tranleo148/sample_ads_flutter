import 'package:flutter/material.dart';

import '../utils/color_const.dart';

class BlankScreen extends StatefulWidget {
  const BlankScreen({Key? key}) : super(key: key);

  @override
  State<BlankScreen> createState() => _BlankScreenState();
}

class _BlankScreenState extends State<BlankScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colur.common_bg_dark,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: const [
              Text('data test'),
            ],
          ),
        ),
      ),
    );
  }
}
