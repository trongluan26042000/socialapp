import 'dart:convert';

import 'package:app1/chat-app/customs/avatar_card.dart';
import 'package:app1/chat-app/customs/button_card.dart';
import 'package:app1/chat-app/customs/contact_card.dart';
import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:app1/chat-app/model/message_model.dart';
import 'package:app1/chat-app/screens_chat/home.dart';
import 'package:app1/chat-app/screens_chat/individual_chat.dart';
import 'package:app1/main.dart';
import 'package:app1/pageRoute/BourcePageRoute.dart';
import 'package:app1/pageRoute/aBcPageRoute.dart';
import 'package:app1/provider/message_provider.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatLoginScreen extends StatefulWidget {
  const ChatLoginScreen({Key? key}) : super(key: key);
  @override
  _ChatLoginScreenState createState() => _ChatLoginScreenState();
}

class _ChatLoginScreenState extends State<ChatLoginScreen> {
  ChatModel? sourceChat;
  Map<String, ChatModel> chatFriend = {};
  List<ChatModel> hadMessageInit = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    return Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
      hadMessageInit = [];

      /// chuyen doi listFr thanh chat Model
      for (var i = 0; i < userProvider.userP.friend.length; i++) {
        if (userProvider.listFriendsP.length > 0) {
          chatFriend[userProvider.userP.friend[i]] = ChatModel(
              id: userProvider.userP.friend[i],
              realName: userProvider
                  .listFriendsP[userProvider.userP.friend[i]]!.realName,
              avatar: userProvider.listFriendsP[userProvider.userP.friend[i]]!
                  .avatarImg[userProvider
                      .listFriendsP[userProvider.userP.friend[i]]!
                      .avatarImg
                      .length -
                  1]);
        }
      }
      //chuyen doi du lieu hadChatMsg thanh chatmodel
      Map<String, List<MessageModel>> chatHad = messageProvider.listMessageP;

      for (var i = 0; i < userProvider.userP.hadMessageList.length; i++) {
        var a = chatHad[userProvider.userP.id +
            "/" +
            userProvider.userP.hadMessageList[i]]![chatHad[
                    userProvider.userP.id +
                        "/" +
                        userProvider.userP.hadMessageList[i]]!
                .length -
            1];
        hadMessageInit.add(ChatModel(
            id: userProvider.userP.hadMessageList[i],
            currentMessage: a.message,
            time: a.time,
            avatar: userProvider
                .listHadChatP[userProvider.userP.hadMessageList[i]]!
                .avatarImg[userProvider
                    .listHadChatP[userProvider.userP.hadMessageList[i]]!
                    .avatarImg
                    .length -
                1],
            realName: userProvider
                .listHadChatP[userProvider.userP.hadMessageList[i]]!.realName));
      }
      hadMessageInit.sort((a, b) => b.time.compareTo(a.time));

      return Scaffold(
          appBar: AppBar(
            title: Text("Tin nhắn"),
          ),
          body: Stack(children: [
            ListView.builder(
                itemCount: hadMessageInit.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                        height: hadMessageInit.length > 0 ? 90 : 10);
                  }
                  return InkWell(
                      onTap: () {
                        print("--- chon avatar1----");
                        print(hadMessageInit[index - 1].id);
                        Navigator.push(
                            context,
                            BourcePageRoute(
                                widget: IndividualChat(
                              chatModel: hadMessageInit[index - 1],
                              sourceChat: ChatModel(
                                  id: userProvider.userP.id,
                                  avatar: userProvider.userP.avatarImg[
                                      userProvider.userP.avatarImg.length - 1]),
                            )));
                      },
                      child: ContactCard(
                        contact: hadMessageInit[index - 1],
                      ));
                }),
            //----------------------list avatar head -----------------
            userProvider.userP.friend.length > 0
                ? Column(
                    children: [
                      Container(
                          height: 80,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: userProvider.userP.friend.length,
                              itemBuilder: (context, index) {
                                if (true)
                                  return InkWell(
                                      onTap: () {
                                        print("--- chon avatar----");
                                        print(userProvider.userP.friend[index]);
                                        Navigator.push(
                                            context,
                                            A1PageRoute(
                                                widget: IndividualChat(
                                              chatModel: ChatModel(
                                                id: userProvider
                                                    .userP.friend[index],
                                                avatar: chatFriend[userProvider
                                                        .userP.friend[index]]!
                                                    .avatar,
                                                realName: chatFriend[
                                                        userProvider.userP
                                                            .friend[index]]!
                                                    .realName,
                                              ),
                                              sourceChat: ChatModel(
                                                  id: userProvider.userP.id,
                                                  avatar: userProvider.userP
                                                      .avatarImg[userProvider
                                                          .userP
                                                          .avatarImg
                                                          .length -
                                                      1]),
                                            )));
                                      },
                                      child: AvatarCard(
                                          contact: chatFriend[userProvider
                                              .userP.friend[index]]));
                                else
                                  return Container();
                              })),
                      Divider(
                        thickness: 1,
                      )
                    ],
                  )
                : Container(
                    height: 0,
                  ),
          ]));
    });
  }
}

///////////////////////////////////
///
Future getApi(String jwt, String sourcePath) async {
  print("----chạy hàm get api feed---------------");
  try {
    http.Response response;
    String path = SERVER_IP + sourcePath;
    print(path);
    response = await http.get(Uri.parse(path), headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'cookie': "jwt=" + jwt,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(json.decode(response.body));
      return json.decode(response.body);
    } else {
      return "error";
    }
  } catch (e) {
    return "error";
  }
}
