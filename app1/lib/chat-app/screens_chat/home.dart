import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:app1/chat-app/pages/camera_page.dart';
import 'package:app1/chat-app/pages/chat_page.dart';
import 'package:app1/chat-app/pages/status_chatpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeChatScreen extends StatefulWidget {
  const HomeChatScreen({Key? key, this.chatmodels, this.sourceChat})
      : super(key: key);
  final List<ChatModel>? chatmodels;
  final ChatModel? sourceChat;
  @override
  _HomeChatScreenState createState() => _HomeChatScreenState();
}

class _HomeChatScreenState extends State<HomeChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TabController(length: 4, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("chat app "),
            actions: [
              IconButton(onPressed: () {}, icon: Icon(Icons.search)),
            ],
            bottom: TabBar(
              controller: _controller,
              tabs: [
                Tab(icon: Icon(Icons.camera)),
                Tab(text: "Chat"),
                Tab(text: "Status"),
                Tab(text: "Call"),
              ],
            )),
        body: TabBarView(
          controller: _controller,
          children: [
            CameraPage(),
            ChatPage(
                chatmodels: widget.chatmodels, sourceChat: widget.sourceChat),
            StatusPage(),
            Text("4"),
          ],
        ));
  }
}
