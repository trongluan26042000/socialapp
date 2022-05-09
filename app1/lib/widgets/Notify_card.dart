import 'dart:convert';

import 'package:app1/api/notification.dart';
import 'package:app1/feed/screen/comment.dart';
import 'package:app1/provider/notifi_provider.dart';
import 'package:app1/user/screen/FriendProfile.dart';
import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:app1/chat-app/screens_chat/individual_chat.dart';
import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/feed/screen/mainFeedScreen.dart';
import 'package:app1/main.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:app1/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Notify_Card extends StatefulWidget {
  const Notify_Card(
      {Key? key,
      required this.idUserSource,
      required this.pathImgSource,
      required this.realNameSource,
      required this.type,
      required this.createdAt,
      required this.content})
      : super(key: key);
  final String pathImgSource;
  final String realNameSource;
  final String idUserSource;
  final String type;
  final String content;
  final String createdAt;

  @override
  State<Notify_Card> createState() => _Notify_CardState();
}

class _Notify_CardState extends State<Notify_Card> {
  @override
  Widget build(BuildContext context) {
    final notifiProvider = Provider.of<NotifiProvider>(context, listen: false);
    print("thời gian trong card no");
    print(notifiProvider.timeSeen);
    print(widget.type);
    bool isSeen = false;
    if (notifiProvider.timeSeen != "") {
      List time = [notifiProvider.timeSeen, widget.createdAt];
      time.sort((a, b) => a.compareTo(b));
      if (time[0] == widget.createdAt) {
        isSeen = true;
      }
    } else {
      print("bằng");
    }

    String textAction = "";
    if (widget.type == "newMsg") {
      textAction = " gửi tin nhắn cho bạn";
    }
    ;
    if (widget.type == "newFeed") {
      textAction = " thêm 1 bài viết mới";
    }
    if (widget.type == "tagFeed" || widget.type == "newTag") {
      textAction = " gắn thẻ bạn trong 1 bài viết mới";
    }
    if (widget.type == "likeFeed" || widget.type == "like") {
      textAction = " yêu thích bài viết của bạn";
    }
    if (widget.type == "comment" || widget.type == "commentFeed") {
      textAction = " bình luận trong bài viết của bạn";
    }
    if (widget.type == "addFr") {
      textAction = " gửi lời mời kết bạn";
    }
    if (widget.type == "confirmFr") {
      textAction = " chấp nhận lời mời";
    }
    return Column(
      children: [
        Container(
          color: isSeen == true ? Colors.grey[300] : Colors.white,
          child: InkWell(
            hoverColor: Colors.amber,
            onTap: () async {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              notifiProvider.timeSeen = DateTime.now().toString();
              var a = await putApi(
                  userProvider.jwtP,
                  {"seentime": DateTime.now().toString()},
                  "/user/updateSeenTime");
              print("seentime là");
              print(a);
              print(widget.type);
              print(widget.idUserSource);
              if (widget.type == "addFr") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) =>
                            FriendProfile(frId: widget.idUserSource)));
              }
              if (widget.type == "confirmFr") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) =>
                            FriendProfile(frId: widget.idUserSource)));
              }
              if (widget.type == "comment" || widget.type == "commentFeed") {
                print("bằng comment mà");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => CommentScreen(
                              feed: FeedBaseModel(
                                  pathImg: [],
                                  pathVideo: [],
                                  comment: [],
                                  tag: [],
                                  rule: [],
                                  like: [],
                                  feedId: widget.content),
                            )));
              }
              if (widget.type == "newFeed") {
                FeedBaseModel feed =
                    await getFeedApi(widget.content, userProvider.jwtP);
                if (feed != "not jwt" && feed != "error" && feed.feedId != "") {
                  if (mounted) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => MainFeedScreen(
                                feed: feed,
                                ownFeedUser: UserModel(
                                    friend: [],
                                    hadMessageList: [],
                                    coverImg: [],
                                    friendConfirm: [],
                                    feedImg: [],
                                    feedVideo: [],
                                    friendRequest: [],
                                    avatarImg: [widget.pathImgSource],
                                    realName: widget.realNameSource,
                                    id: widget.idUserSource))));
                  }
                }
              }

              if (widget.type == "newMsg") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => IndividualChat(
                              sourceChat: ChatModel(
                                id: userProvider.userP.id,
                                avatar: userProvider.userP.avatarImg[
                                    userProvider.userP.avatarImg.length - 1],
                                realName: userProvider.userP.realName,
                              ),
                              chatModel: ChatModel(
                                id: widget.idUserSource,
                                realName: widget.realNameSource,
                                avatar: widget.pathImgSource,
                              ),
                            )));
              }

              if (mounted) {
                setState(() {});
              }
            },
            child: ListTile(
                leading: CustomPaint(
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/load.gif'),
                    radius: 30,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                          SERVER_IP + "/upload/" + widget.pathImgSource),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                trailing: SizedBox(
                    height: 50,
                    width: 50,
                    child: InkWell(
                      onTap: () async {
                        print("xóa");
                        await showModalBottomSheet<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                  height: 200,
                                  child: Center(
                                      child: SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: InkWell(
                                              onTap: () async {
                                                print("xóa");
                                                await NotificationApi
                                                    .showNotification(
                                                        "nam", "hey");
                                              },
                                              child: Text("xóa",
                                                  textAlign:
                                                      TextAlign.center)))));
                            });
                      },
                      child: Text(
                        "...",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    )),
                title: RichText(
                    text: TextSpan(
                        text: widget.realNameSource,
                        style: AppStyles.h6.copyWith(color: Colors.lightBlue),
                        children: [
                      TextSpan(
                        text: " đã ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: textAction,
                        style: TextStyle(color: Colors.orangeAccent),
                      )
                    ])),
                subtitle: Text(
                  widget.createdAt.substring(0, 19),
                  style: TextStyle(color: Colors.grey[900], fontSize: 12),
                )),
          ),
        ),
        Divider(
          height: 1,
          thickness: 2,
        )
      ],
    );
  }
}

//--------------------------like và dislike-----------------
postApi(String jwt, data, String sourcePath) async {
  print("----chạy hàm get api feed---------------");
  try {
    http.Response response;
    String path = SERVER_IP + sourcePath;
    print(path);
    response = await http.post(Uri.parse(path),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'cookie': "jwt=" + jwt,
        },
        body: jsonEncode(data));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return "error";
    }
  } catch (e) {
    return "error";
  }
}

Future fetchApiFindFeed(String sourceFeedId, String jwt) async {
  print("----chạy hàm get api feed---------------");
  try {
    print("source feed id là ");
    print(sourceFeedId);

    http.Response response;
    String path = SERVER_IP + '/feed/' + sourceFeedId;
    print(path);
    response = await http.get(
      Uri.parse(path),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'cookie': "jwt=" + jwt,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("kết quả là feed ");
      print(json.decode(response.body));
      return json.decode(response.body);
    } else {
      return FeedBaseModel(
          like: [], rule: [], comment: [], pathImg: [], tag: [], pathVideo: []);
    }
  } catch (e) {
    return FeedBaseModel(
        like: [], rule: [], comment: [], tag: [], pathImg: [], pathVideo: []);
  }
}

//-----------------------like func------------
getFeedApi(sourceId, jwt) async {
  FeedBaseModel feedApi = FeedBaseModel(
      like: [], tag: [], rule: [], comment: [], pathImg: [], pathVideo: []);
  var data = await fetchApiFindFeed(sourceId, jwt);
  if (data == "not jwt") {
    return feedApi;
  } else {
    if (data != "error") {
      print("data:feed là");
      print(data);
      print(data["like"]);
      FeedBaseModel a = FeedBaseModel(
        like: data["like"],
        comment: data["comment"],
        pathImg: data["pathImg"],
        pathVideo: data["pathVideo"],
        tag: data["tag"],
        rule: data["rule"],
        feedId: data["_id"].toString(),
        message: data["messages"],
        createdAt: data["createdAt"],
      );
      return a;
    } else {
      return feedApi;
    }
  }
}

putApi(String jwt, data, String sourcePath) async {
  print("----chạy hàm post api feed---------------");
  try {
    http.Response response;
    String path = SERVER_IP + sourcePath;
    print(path);
    response = await http.put(Uri.parse(path),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'cookie': "jwt=" + jwt,
        },
        body: jsonEncode(data));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return "error";
    }
  } catch (e) {
    return "error";
  }
}
