import 'package:flutter/material.dart';

class AppBtnIconStyle extends StatelessWidget {
  final Color? color;
  final IconData icon;

  final VoidCallback onTap;
  const AppBtnIconStyle({
    Key? key,
    required this.onTap,
    this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      elevation: 4,
      child: TextButton(
        onPressed: () {},
        child: Icon(icon),
      ),
    );
  }
}
