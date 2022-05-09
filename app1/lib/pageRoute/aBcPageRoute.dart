import 'package:app1/user/screen/suggestFriend.dart';
import 'package:flutter/cupertino.dart';

class A1PageRoute extends PageRouteBuilder {
  final Widget widget;
  A1PageRoute({required this.widget})
      : super(
            transitionDuration: Duration(milliseconds: 600),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secAnimation,
                Widget child) {
              animation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInToLinear,
                  reverseCurve: Curves.slowMiddle);
              return ScaleTransition(
                scale: animation,
                child: child,
                alignment: Alignment.center,
              );
            },
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secAnimation) =>
                widget);
}
