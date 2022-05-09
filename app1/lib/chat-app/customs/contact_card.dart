import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:app1/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({Key? key, required this.contact}) : super(key: key);
  final ChatModel contact;

  @override
  Widget build(BuildContext context) {
    print("render...1.");

    String pathImg = contact.avatar;
    if (contact != null) {
      if (contact.avatar != "")
        pathImg = SERVER_IP + "/upload/" + contact.avatar;
      else {
        pathImg = SERVER_IP + "/upload/" + "avatarNull.jpg";
      }
    } else {
      pathImg = SERVER_IP + "/upload/" + "avatarNull.jpg";
    }
    return ListTile(
        leading: Container(
          height: 50,
          width: 50,
          child: Stack(children: [
            CircleAvatar(
              radius: 23,
              backgroundImage: AssetImage('assets/images/load.gif'),
              child: CircleAvatar(
                radius: 23,
                backgroundImage: NetworkImage(pathImg),
                backgroundColor: Colors.transparent,
              ),
            ),
            Positioned(
              bottom: 4,
              right: 3,
              child: CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 9,
                  child: Icon(Icons.check, color: Colors.white, size: 18)),
            )
          ]),
        ),
        title: Text(
          contact != null ? contact.realName : "userName",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(contact.currentMessage, style: TextStyle(fontSize: 13)));
  }
}
