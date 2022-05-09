import 'package:app1/chat-app/customs/custom_card.dart';
import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:app1/chat-app/screens_chat/select_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, this.chatmodels, this.sourceChat})
      : super(key: key);
  final List<ChatModel>? chatmodels;
  final ChatModel? sourceChat;
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => SelectContact()));
            },
            child: Icon(Icons.chat)),
        body: ListView.builder(
          itemCount: widget.chatmodels!.length,
          itemBuilder: (context, index) => CustomCard(
              chatModel: widget.chatmodels![index],
              sourceChat: widget.sourceChat),
        ));
  }
}
