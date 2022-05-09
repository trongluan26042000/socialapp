import 'package:flutter/material.dart';
import "../widgets/dismit_keybord.dart";

class Background extends StatelessWidget {
  final Widget Column;
  const Background({Key? key, required this.Column}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        child: Stack(children: [
      Container(
        width: size.width,
        height: size.height,
        child: Image.asset(
          "assets/images/background1.jpg",
          color: Color.fromRGBO(255, 255, 255, 0.3),
          colorBlendMode: BlendMode.modulate,
          fit: BoxFit.fitHeight,
        ),
      ),
      ListView(
        children: [
          Column,
        ],
      )
    ]));
  }
}
