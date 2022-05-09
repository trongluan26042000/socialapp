import 'package:flutter/material.dart';

class AppBTnStyle extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final bool? isIcon;
  final VoidCallback? onTap;
  const AppBTnStyle(
      {Key? key,
      required this.label,
      required this.onTap,
      this.color,
      this.icon = null,
      this.isIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: color ?? Colors.orange,
                elevation: 4,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  overlayColor: MaterialStateProperty.all(Colors.amber),
                  child: Container(
                      padding: const EdgeInsets.only(
                          top: 12, bottom: 12, right: 8, left: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon != null
                              ? Container(
                                  constraints: BoxConstraints(maxWidth: 100),
                                  child: Icon(icon ?? null),
                                )
                              : Container(),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 30.0, right: 30),
                            child: Text(
                              label,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )),
                ),
              ))
        ],
      ),
    );
  }
}
