import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:app1/chat-app/screens_chat/individual_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final ChatModel? chatModel;
  const CustomCard({Key? key, this.chatModel, this.sourceChat})
      : super(key: key);
  final ChatModel? sourceChat;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print("chuyen page individual ....");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => IndividualChat(
                    chatModel: chatModel, sourceChat: sourceChat)));
      },
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
                radius: 30,
                // child: Icon(
                //   Icons.groups,
                //   size: 30,
                //   color: Colors.white,
                // ),
                child: Image.asset(
                    chatModel!.isGroup
                        ? "assets/icons/groups.png"
                        : "assets/icons/man.png",
                    width: 37,
                    height: 37),
                backgroundColor: Colors.amber),
            title: Text(
              chatModel!.realName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.done),
                SizedBox(
                  width: 3,
                ),
                Text(
                  chatModel!.currentMessage,
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            trailing: Text(chatModel!.time),
          ),
          Divider(
            indent: 32,
            endIndent: 16,
            thickness: 3,
          )
        ],
      ),
    );
  }
}
