import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonCard extends StatelessWidget {
  const ButtonCard({Key? key, this.name = "", this.icon = Icons.home})
      : super(key: key);
  final String name;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 23,
        child: Icon(icon, size: 26, color: Colors.white),
        backgroundColor: Colors.blueGrey[200],
      ),
      title: Text(
        name,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}
