import 'package:flutter/material.dart';
import '/utils/color_const.dart';

class CustomTabBar extends StatefulWidget {
  final String tab1;
  final String tab2;
  final Widget forHeart;
  final Widget forDistance;

  const CustomTabBar({
    Key? key,
    required this.tab1,
    required this.tab2,
    required this.forHeart,
    required this.forDistance,
  }) : super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  Gradient grad =
      const LinearGradient(colors: [Colur.purple_gradient_color1, Colur.purple_gradient_color1]);

  bool distanceSelected = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    distanceSelected = false;
                    print(distanceSelected);
                  });
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.tab1,
                          style: TextStyle(
                              color: !distanceSelected
                                  ? Colur.txt_white
                                  : Colur.txt_white.withOpacity(0.7),
                              fontSize: !distanceSelected ? 20 : 16.0,
                              fontWeight: !distanceSelected ? FontWeight.bold : FontWeight.w500),
                        ),
                      ),
                      Visibility(
                        visible: !distanceSelected,
                        child: Container(
                          height: 3,
                          width: 30,
                          decoration:
                              BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    distanceSelected = true;
                    print(distanceSelected);
                  });
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.tab2,
                          style: TextStyle(
                              color: distanceSelected
                                  ? Colur.txt_white
                                  : Colur.txt_white.withOpacity(0.7),
                              fontSize: distanceSelected ? 20 : 16.0,
                              fontWeight: distanceSelected ? FontWeight.bold : FontWeight.w500),
                        ),
                      ),
                      Visibility(
                        visible: distanceSelected,
                        child: Container(
                          height: 3,
                          width: 30,
                          decoration:
                              BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          child: distanceSelected ? widget.forDistance : widget.forHeart,
        ),
      ],
    );
  }
}
