import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:app1/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AvatarCard extends StatelessWidget {
  const AvatarCard({Key? key, this.contact}) : super(key: key);
  final ChatModel? contact;
  @override
  Widget build(BuildContext context) {
    String pathImg;
    if (contact != null) {
      if (contact!.avatar != "")
        pathImg = SERVER_IP + "/upload/" + contact!.avatar;
      else {
        pathImg = SERVER_IP + "/upload/" + "avatarNull.jpg";
      }
    } else {
      pathImg = SERVER_IP + "/upload/" + "avatarNull.jpg";
    }
    return Container(
      constraints: BoxConstraints(maxWidth: 80, maxHeight: 80),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(children: [
              CircleAvatar(
                backgroundColor: Colors.red,
                radius: 23,
                backgroundImage: AssetImage('assets/images/load.gif'),
                child: CircleAvatar(
                  radius: 23,
                  backgroundImage: NetworkImage(pathImg),
                  backgroundColor: Colors.transparent,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                    radius: 6,
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: Colors.green,
                    )),
              )
            ]),
            SizedBox(
              height: 2,
            ),
            Text(contact != null ? contact!.realName : "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12))
          ],
        ),
      ),
    );
  }
}
