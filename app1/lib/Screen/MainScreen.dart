import 'dart:convert';

import 'package:app1/Screen/Notifications.dart';
import 'package:app1/Screen/SearchScreen.dart';
import 'package:app1/api/notification.dart';
import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:app1/chat-app/model/message_model.dart';
import 'package:app1/chat-app/screens_chat/LoginScreen.dart';
import 'package:app1/feed/model/comment_model.dart';
import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/main.dart';
import 'package:app1/model/notifi_modal.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/comment_provider.dart';
import 'package:app1/provider/feed_provider.dart';
import 'package:app1/provider/message_provider.dart';
import 'package:app1/provider/notifi_provider.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../user/screen/Profile.dart';
import './HomeScreen.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, required this.UserId}) : super(key: key);
  final String UserId;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int numberNotifications = 0;
  final PageController _pageController = PageController();
  bool isSigninSocket = true;
  int _currentIndex = 0;
  late Socket socket;
  //----------connetc socket--------------------------------------------
  void connect(String id) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final commentProvider =
        Provider.of<CommentProvider>(context, listen: false);

    print("begin connect....................");
    socket = io(SERVER_IP, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();
    print(socket.connected);
    socket.emit("signin", id);
    socket.onConnect((data) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);
      final notifiProvider =
          Provider.of<NotifiProvider>(context, listen: false);
      socket.on("newFeed", (feed) async {
        if (mounted) {
          print("---chạy setstate- số thông báo--");

          numberNotifications = numberNotifications + 1;

          print(feed);
          print(feed["feedId"]);
          await NotificationApi.showNotification(
              feed["sourceRealnameUser"], "Đã thêm 1 bài viết mới");
          setListFeedP(feed);
        }
      });
      socket.on("comment", (comment) async {
        print("---chạy setstate- số thông báo--");

        numberNotifications = numberNotifications + 1;
        print(comment);
        Map<String, List<CommentFullModel>> listCommenPInit = {};
        CommentFullModel cmtNew = CommentFullModel(
          comment: CommentBaseModel(
            pathImg: comment["pathImg"],
            messages: comment["messages"],
            createdAt: comment["createdAt"],
            sourceUserId: comment["id"],
          ),
          avatarImg: comment["avatar"],
          realName: comment["realName"],
        );
        if (commentProvider.listCommentP[comment["feedId"]] == null &&
            commentProvider.feedId == comment["feedId"]) {
          listCommenPInit[comment["feedId"]] = [cmtNew];
        }
        if (commentProvider.listCommentP[comment["feedId"]] != null &&
            commentProvider.feedId == comment["feedId"]) {
          listCommenPInit = commentProvider.listCommentP;
          listCommenPInit[comment["feedId"]]!.add(cmtNew);
        }
        NotifiModel not = NotifiModel(
            targetIdUser: [],
            type: "comment",
            sourceIdUser: comment["id"],
            sourceRealnameUser: comment["realName"],
            sourceUserPathImg: comment["avatar"],
            content: comment["feedId"],
            createdAt: comment["createdAt"]);
        List<NotifiModel> listNot = notifiProvider.listNotifiP;
        listNot.insert(0, not);

        await NotificationApi.showNotification(
            comment["realName"], "Đã bình luận về bài viết");
        setState(() {
          notifiProvider.userNotifi(listNot);
          commentProvider.userComment(listCommenPInit);
        });
      });
      socket.on("newTag", (feed) {
        if (mounted) {
          print("---chạy setstate- số thông báo--");

          numberNotifications = numberNotifications + 1;
          setNewTag(feed);
          setState(() async {
            await NotificationApi.showNotification(
                feed["sourceRealnameUser"], "Đã thêm bạn vào 1 bài viết mới");
          });
        }
      });

      socket.on("message", (msg) async {
        var result =
            await getApi(userProvider.jwtP, "/user/" + msg["sourceId"]);
        if (userProvider.userP.hadMessageList.indexOf(msg["sourceId"]) < 0) {
          userProvider.userP.hadMessageList.add(msg["sourceId"]);
          messageProvider.listMessageP;

          if (result != "not jwt" && result != "error") {
            userProvider.listHadChatP[msg["sourceId"]] = UserModel(
                friend: [],
                hadMessageList: [],
                coverImg: [],
                friendConfirm: [],
                feedImg: [],
                feedVideo: [],
                friendRequest: [],
                realName: result["realName"],
                id: result["_id"],
                avatarImg: result["avatarImg"]);
          }
          messageProvider
              .listMessageP[msg["targetId"] + "/" + msg["sourceId"]] = [];
        }
        print("message");
        print(msg);
        await NotificationApi.showNotification(
            result["realName"], "Đã gửi tin nhắn cho bạn");
        if (mounted) {
          setState(() {
            setListMessageP(msg);

            numberNotifications = numberNotifications + 1;
          });
        }
      });
      socket.on("likeFeed", (msg) async {
        NotifiModel not = NotifiModel(
            targetIdUser: [],
            sourceIdUser: msg["idUserLiked"],
            sourceRealnameUser: msg["realNameLiked"],
            sourceUserPathImg: msg["avatarLiked"],
            type: msg["type"],
            isSeen: false,
            createdAt: msg["createdAt"],
            content: msg["feedId"]);
        List<NotifiModel> notifiInit = notifiProvider.listNotifiP;
        for (int i = 0; i < notifiInit.length; i++) {
          if (notifiInit[i].sourceIdUser == not.sourceIdUser &&
              notifiInit[i].content == not.content) {
            notifiInit.removeAt(i);
            i--;
          }
        }
        notifiInit.insert(0, not);

        await NotificationApi.showNotification(
            msg["realNameLiked"], "Đã yêu thích bài viết của bạn");
        if (mounted) {
          setState(() {
            numberNotifications = numberNotifications + 1;
            notifiProvider.userNotifi(notifiInit);
          });
        }
      });
      socket.on("handleFr", (data) async {
        print(data);
        print(data["type"]);
        print("type là là là");
        if (data["type"] == "removeFrRequest") {
          userProvider.userP.friendConfirm.remove(data["sourceUserId"]);
        }
        if (data["type"] == "removeFrConfirm") {
          userProvider.userP.friendRequest.remove(data["sourceUserId"]);
        }

        if (data["type"] == "removeFriend") {
          userProvider.userP.friend.remove(data["sourceUserId"]);
          userProvider.listFriendsP.remove(data["sourceUserId"]);

          if (mounted) {
            setState(() {});
          }
        }
        if (data["type"] == "confirmFr") {
          List<NotifiModel> notifiInit = [];
          userProvider.userP.friend.add(data["sourceUserId"]);
          userProvider.userP.friendRequest.remove(data["sourceUserId"]);
          notifiInit = notifiProvider.listNotifiP;
          var result =
              await getApi(userProvider.jwtP, "/user/" + data["sourceUserId"]);
          print("kết quả result là");
          print(result);
          if (result != "not jwt" && result != "error") {
            userProvider.listFriendsP[data["sourceUserId"]] = UserModel(
                friend: [],
                hadMessageList: [],
                feedImg: [],
                feedVideo: [],
                coverImg: [],
                friendConfirm: [],
                friendRequest: [],
                avatarImg: result["avatarImg"],
                id: data["sourceUserId"],
                realName: result["realName"]);
            notifiInit.insert(
                0,
                NotifiModel(
                  type: data["type"],
                  createdAt: data["createdAt"],
                  isSeen: false,
                  content: data["content"] == null ? "" : data["content"],
                  sourceRealnameUser: result["realName"],
                  sourceUserPathImg: result["avatarImg"]
                      [result["avatarImg"].length - 1],
                  sourceIdUser: data["sourceUserId"],
                  targetIdUser: data["targetUserId"],
                ));

            await NotificationApi.showNotification(
                result["realName"], "Đã chấp nhận lời mời kết bạn");
            if (mounted) {
              setState(() {
                notifiProvider.userNotifi(notifiInit);
                numberNotifications = numberNotifications + 1;
              });
            }
          }
        }
        if (data["type"] == "addFr") {
          List<NotifiModel> notifiInit = [];
          userProvider.userP.friendConfirm.add(data["sourceUserId"]);
          notifiInit = notifiProvider.listNotifiP;
          var result =
              await getApi(userProvider.jwtP, "/user/" + data["sourceUserId"]);
          print("kết quả result là");
          print(result);
          if (result != "error" && result != "not jwt") {
            notifiInit.insert(
                0,
                NotifiModel(
                  type: data["type"],
                  createdAt: data["createdAt"],
                  isSeen: false,
                  content: data["content"] == null ? "" : data["content"],
                  sourceRealnameUser: result["realName"],
                  sourceUserPathImg: result["avatarImg"]
                      [result["avatarImg"].length - 1],
                  sourceIdUser: data["sourceUserId"],
                  targetIdUser: data["targetUserId"],
                ));

            await NotificationApi.showNotification(
                result["realName"], "Đã gửi lời mời kết bạn");
            if (mounted) {
              setState(() {
                notifiProvider.userNotifi(notifiInit);
                numberNotifications = numberNotifications + 1;
              });
            }
          }
        }
      });
    });
  }

  void _onItemTapped(int index) {
    final notifiProvider = Provider.of<NotifiProvider>(context, listen: false);

    setState(() {
      if (index == 4) {
        numberNotifications = 0;
        print("Ấn vào thông váo");

        // notifiProvider.userTimeSeenNotifi(DateTime.now().toString());
        print(notifiProvider.timeSeen);
      }
      ;
      _selectedIndex = index;
    });
  }

  setListMessageP(msg) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final notifiProvider = Provider.of<NotifiProvider>(context, listen: false);

    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    if (messageProvider
            .listMessageP[userProvider.userP.id + "/" + msg["sourceId"]] !=
        null) {
      Map<String, List<MessageModel>> messagesI = {};
      print("---Đã nhắn tin rồi-----");
      messageProvider
          .listMessageP[userProvider.userP.id + "/" + msg["sourceId"]]!
          .add(MessageModel(
              path: msg["path"],
              time: msg["time"],
              message: msg["message"],
              targetId: msg["targetId"],
              sourceId: msg["sourceId"]));
      messagesI = messageProvider.listMessageP;
      NotifiModel not = NotifiModel(
        type: "newMsg",
        sourceIdUser: msg["sourceId"],
        targetIdUser: [msg["targetId"]],
        content: msg["sourceId"],
        createdAt: msg["time"],
      );

      List<NotifiModel> notifiInit = notifiProvider.listNotifiP;

      for (int i = 0; i < notifiInit.length; i++) {
        if (notifiInit[i].type == "newMsg" &&
            notifiInit[i].sourceIdUser == msg["sourceId"]) {
          notifiInit.removeAt(i);
          i--;
        }
      }

      notifiInit.insert(0, not);

      notifiProvider.userNotifi(notifiInit);
      messageProvider.userMessage(messagesI);
    } else {
      Map<String, List<MessageModel>> messagesI = {};

      List<MessageModel> output = [];
      print("---chưa nhắn tin ----");

      output.add(MessageModel(
          path: msg["path"],
          time: msg["time"],
          message: msg["message"],
          targetId: msg["targetId"],
          sourceId: msg["sourceId"]));

      messageProvider
              .listMessageP[userProvider.userP.id + "/" + msg["sourceId"]] ==
          output;
      messagesI = messageProvider.listMessageP;
      NotifiModel not = NotifiModel(
        type: "newMsg",
        sourceIdUser: msg["sourceId"],
        targetIdUser: [msg["targetId"]],
        content: msg["sourceId"],
        createdAt: msg["time"],
      );

      List<NotifiModel> notifiInit = notifiProvider.listNotifiP;

      for (int i = 0; i < notifiInit.length; i++) {
        if (notifiInit[i].type == "newMsg" &&
            notifiInit[i].sourceIdUser == msg["sourceId"]) {
          notifiInit.removeAt(i);
          i--;
        }
      }

      notifiInit.insert(0, not);

      notifiProvider.userNotifi(notifiInit);
      messageProvider.userMessage(messagesI);
    }
  }

  setListFeedP(feed) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final notifiProvider = Provider.of<NotifiProvider>(context, listen: false);

    List<FeedBaseModel> newFeeds = [];
    if (feed["sourceUserId"] == userProvider.userP.id) {
      newFeeds = feedProvider.listFeedsP;
      FeedBaseModel newFeed = FeedBaseModel(
          feedId: feed["feedId"],
          pathImg: feed['pathImg'],
          pathVideo: feed['pathVideo'],
          message: feed['messages'],
          comment: feed['comment'],
          rule: feed['rule'],
          tag: feed["tag"],
          like: feed['like']);
      print(newFeed);
      // newFeeds.add(newFeed);
      // feedProvider.userFeed(newFeeds);

    } else {
      print("-- bạn Đã đăng feed");
      print(feed["messages"]);
      print(feed["sourceUserId"]);
      FeedBaseModel newFeed = FeedBaseModel(
        pathImg: feed["pathImg"],
        rule: feed["rule"],
        comment: feed["comment"],
        feedId: feed["feedId"].toString(),
        message: feed["messages"],
        pathVideo: feed['pathVideo'],
        tag: feed["tag"],
        like: feed["like"],
        sourceUserId: feed["sourceUserId"].toString(),
        createdAt: feed["createdAt"],
        sourceUserName: feed["sourceUserName"].toString(),
      );

      newFeeds = feedProvider.listFeedsFrP;
      newFeeds.add(newFeed);
      feedProvider.userFrFeed(newFeeds);

      NotifiModel not = NotifiModel(
          type: "newFeed",
          sourceIdUser: feed["sourceUserId"].toString(),
          targetIdUser: feed["tag"],
          createdAt: feed["createdAt"],
          content: feed["feedId"],
          isSeen: false,
          sourceRealnameUser: feed["sourceRealnameUser"],
          sourceUserPathImg: feed["sourceUserPathImg"]
              [feed["sourceUserPathImg"].length - 1]);
      List<NotifiModel> notifiInit = notifiProvider.listNotifiP;
      notifiInit.insert(0, not);
      if (mounted) {
        setState(() {
          notifiProvider.userNotifi(notifiInit);
        });
      }
    }
  }

  //
  setNewTag(feed) {
    final notifiProvider = Provider.of<NotifiProvider>(context, listen: false);

    NotifiModel not = NotifiModel(
        type: "newTag",
        sourceIdUser: feed["sourceUserId"].toString(),
        targetIdUser: feed["tag"],
        createdAt: feed["createdAt"],
        content: "",
        isSeen: false,
        sourceRealnameUser: feed["sourceRealnameUser"],
        sourceUserPathImg: feed["sourceUserPathImg"]
            [feed["sourceUserPathImg"].length - 1]);
    List<NotifiModel> notifiInit = notifiProvider.listNotifiP;
    notifiInit.insert(0, not);
    notifiProvider.userNotifi(notifiInit);
  }

  //
  @override
  void initState() {
    super.initState();
    connect(widget.UserId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(numberNotifications.toString());
    numberNotifications = 0;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final notifiProvider = Provider.of<NotifiProvider>(context, listen: false);

    if (notifiProvider.listNotifiP.length > 0) {
      if (notifiProvider.timeSeen != "") {
        print("main screen b ");

        for (int i = 0; i < notifiProvider.listNotifiP.length; i++) {
          List time = [
            notifiProvider.timeSeen,
            notifiProvider.listNotifiP[i].createdAt
          ];
          time.sort((a, b) => a.compareTo(b));
          if (time[1] == notifiProvider.listNotifiP[i].createdAt) {
            numberNotifications++;
          }
        }
      } else {
        print("main screen khac ");

        numberNotifications = notifiProvider.listNotifiP.length;
      }
    }

    List<Widget> _widgetOptions = [
      HomeScreen(),
      Profile(),
      SearchScreen(),
      ChatLoginScreen(),
      NotifiScreen()
    ];
    // final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: [
          HomeScreen(),
          Profile(),
          SearchScreen(),
          ChatLoginScreen(),
          NotifiScreen()
        ],
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
          print("numberNotifications");

          print(numberNotifications);
          // _pageController.animateToPage(index,
          //     duration: Duration(milliseconds: 300), curve: Curves.ease);
        }),
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Image.asset("assets/icons/homeIcon.png", height: 30),
            title: _selectedIndex == 0
                ? Container(
                    child: Text("Trang chủ"),
                    decoration: BoxDecoration(),
                  )
                : Container(),
          ),
          BottomNavyBarItem(
            icon: Image.asset("assets/icons/profileIcon.png", height: 30),
            title: _selectedIndex == 1
                ? Center(
                    child: Container(
                      child: Text("Cá nhân"),
                    ),
                  )
                : Container(),
          ),
          BottomNavyBarItem(
            icon: Image.asset("assets/icons/findIcon.png", height: 30),
            title: _selectedIndex == 2
                ? Container(
                    child: Text("Tìm kiếm"),
                    decoration: BoxDecoration(),
                  )
                : Container(),
          ),
          BottomNavyBarItem(
            icon: Image.asset("assets/icons/messageIcon.png", height: 30),
            title: _selectedIndex == 3
                ? Container(
                    child: Text("Tin nhắn"),
                    decoration: BoxDecoration(),
                  )
                : Container(),
          ),
          BottomNavyBarItem(
              icon: Container(
                  child: Stack(children: [
                Image.asset("assets/icons/notifiIcon.png", height: 30),
                Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 8,
                      child: Center(
                        child: Text(
                          numberNotifications.toString(),
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    ))
              ])),
              title: Text("Thông báo")),
        ],
        // type: BottomNavigationBarType.fixed,
        // backgroundColor: Colors.white,
        // unselectedItemColor: Colors.grey[500],
        // selectedFontSize: 14,
        // unselectedFontSize: 14,
        // onTap: _onItemTapped,
        // currentIndex: _selectedIndex,
        // selectedItemColor: Colors.orange,
        // iconSize: 26,
        // elevation: 5
      ),
    );
  }
}

Future<dynamic> getApi(String jwt, String pathApi) async {
  print("--------get Api---------" + pathApi);
  print(jwt);
  var res = await http.get(
    Uri.parse(SERVER_IP + pathApi),
    headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'cookie': "jwt=" + jwt,
    },
  );
  if (res.statusCode == 200 || res.statusCode == 201) {
    var data = json.decode(res.body);
    print("result " + pathApi);
    print(data);
    return data;
  } else {
    return "error";
  }
}
