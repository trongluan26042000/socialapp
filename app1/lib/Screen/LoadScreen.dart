import 'dart:convert';

import 'package:app1/user/screen/SettingUser.dart';
import 'package:app1/chat-app/model/message_model.dart';
import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/main.dart';
import 'package:app1/model/friendUser.dart';
import 'package:app1/model/notifi_modal.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/feed_provider.dart';
import 'package:app1/provider/message_provider.dart';
import 'package:app1/provider/notifi_provider.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import "../ui.dart";
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/screen/LoginScreen.dart';

import '../Screen/MainScreen.dart';
import 'package:http/http.dart' as http;

class LoadScreen extends StatefulWidget {
  const LoadScreen({Key? key}) : super(key: key);

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {
  int _counter = 0;
  bool isBtnLoad = false;
  bool isLoading = true;
  String jwt = "";
  UserModel userInit = UserModel(
      friend: [],
      friendConfirm: [],
      friendRequest: [],
      feedImg: [],
      feedVideo: [],
      coverImg: [],
      avatarImg: [],
      hadMessageList: []);
  Map<String, List<MessageModel>> listMsgInit = {};
  Map<String, UserModel> listFrInit = {};
  Map<String, UserModel> listHadChat = {};
  Map<String, UserModel> listConfirmFr = {};
  Map<String, UserModel> listFrOfFr = {};

  Map<String, int> listIdFrOfFr = {};

  List<NotifiModel> notifiInit = [];
  List<FeedBaseModel> listFeedsInit = [];
  List<FeedBaseModel> newListFeedOwnInit = [];
  List<FeedBaseModel> newListFeedFrInit = [];
  @override
  void initState() {
    super.initState();
    _loadJwtAndUserInit();
  }

  //-------------------load jwt lưu trong local và chạy hàm gét userinit---------------------------
  void _loadJwtAndUserInit() async {
    final prefs = await SharedPreferences.getInstance();
    jwt = await (prefs.getString('jwt') ?? "");
    print("----jwt Init ----" + jwt);
    if (jwt != null && jwt != "") {
      var data = await Future.wait(
          [getUserJwt(jwt), getApi(jwt, "/user/allAvatarFr")]);
      userInit = data[0];
      print(userInit);
      if (userInit.userName != "") {
        var result = await Future.wait([
          PostApi(jwt, {"listUser": userInit.friend}, "/user/listUser"),
          PostApi(jwt, {"listUser": userInit.hadMessageList}, "/user/listUser"),
          getApi(
              jwt,
              "/notification/findLimit?limit=50&offset=0&targetUserId=" +
                  userInit.id),
          getApi(jwt, "/notification/findLimitNotTargetId?limit=50&offset=0"),
          getFeedInit(userInit.id, jwt, userInit.friend),
          PostApi(jwt, {"listUser": userInit.friendConfirm}, "/user/listUser"),
        ]);

        listMsgInit = await getAllMsgFr(jwt, 10, 0, "/message/allMsgFR",
            userInit.id, userInit.hadMessageList);
        listFrInit = getFriendUser(result[0], userInit.friend, true)[0];
        listHadChat = getFriendUser(result[1], userInit.hadMessageList, false);
        listConfirmFr = getFriendUser(result[5], userInit.friendConfirm, false);

        listIdFrOfFr = getFriendUser(result[0], userInit.friend, true)[1];
        var notifiInitNotAvatar = getNotiifiUserInitNotAvatar(result[2], jwt);
        List keyIdFrOfFr = [];
        if (listIdFrOfFr.keys != null) {
          keyIdFrOfFr.addAll(listIdFrOfFr.keys);
        }

        var userListResultApi = await Future.wait([
          PostApi(jwt, {"listUser": notifiInitNotAvatar[1]}, "/user/listUser"),
          PostApi(jwt, {"listUser": keyIdFrOfFr}, "/user/listUser"),
        ]);
        print("lấy user notifiInit");
        print(userListResultApi[0]);

        listFrOfFr = getFriendUser(userListResultApi[1], keyIdFrOfFr, false);
        notifiInit = getNotiifiUserAll(userListResultApi[0],
            notifiInitNotAvatar[0], notifiInitNotAvatar[1]);
        print("kết quả 3 là ");
        print(result[3]);
        if (result[3].length > 0) {
          for (int i = 0; i < result[3].length; i++) {
            if (result[3][i].length > 0) {
              for (int j = 0; j < result[3][i].length; j++) {
                notifiInit.add(NotifiModel(
                    type: "newFeed",
                    targetIdUser: result[3][i][j]["targetUserId"],
                    content: result[3][i][j]["content"],
                    sourceRealnameUser:
                        listFrInit[result[3][i][j]["sourceUserId"]]!.realName,
                    createdAt: result[3][i][j]["createdAt"],
                    sourceUserPathImg:
                        listFrInit[result[3][i][j]["sourceUserId"]]!.avatarImg[
                            listFrInit[result[3][i][j]["sourceUserId"]]!
                                    .avatarImg
                                    .length -
                                1],
                    sourceIdUser: result[3][i][j]["sourceUserId"]));
              }
            }
          }
        }
        listFeedsInit = result[4];
        for (int i = 0; i < listFeedsInit.length; i++) {
          if (listFeedsInit[i].sourceUserId == userInit.id) {
            newListFeedOwnInit.add(listFeedsInit[i]);
          } else {
            newListFeedFrInit.add(listFeedsInit[i]);
          }
        }

        setState(() {
          isLoading = false;
          jwt = (prefs.getString('jwt') ?? "");
        });
      }
    }
    {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final notifiProvider = Provider.of<NotifiProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    if (userProvider.userP.userName != "") {
      setState(() {
        isLoading = false;
      });
    }

    print(userProvider.userP.userName);
    return Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Expanded(
                  child: Container(
                alignment: Alignment.centerLeft,
                child: Text("Aloha!!! <3", style: TextStyle(fontSize: 42)),
              )),
              Expanded(
                  child: Container(
                      color: Colors.blue,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text("Enjoy",
                                  style: TextStyle(fontSize: 60))),
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: Text("Have fun", style: AppStyles.h2),
                          ),
                        ],
                      ))),
              Expanded(
                  child: RawMaterialButton(
                      shape: CircleBorder(),
                      fillColor: Colors.green,
                      onPressed: isLoading == false
                          ? () async {
                              if (userInit.userName != "") {
                                userProvider.userLogin(userInit, jwt);
                                messageProvider.userMessage(listMsgInit);
                                userProvider.userFriends(listFrInit);
                                userProvider.userHadChats(listHadChat);
                                notifiProvider.userNotifi(notifiInit);
                                notifiProvider.timeSeen =
                                    userInit.seenTimeNotifi;
                                userProvider.listFrOfFrP = listFrOfFr;
                                userProvider.listConfirmFrP = listConfirmFr;
                                feedProvider.userFeed(newListFeedOwnInit);
                                feedProvider.userFrFeed(newListFeedFrInit);
                              }
                              print(userProvider.userP.userName);
                              print("realName");
                              print(userProvider.userP.realName);
                              if (userProvider.userP.realName == "user") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => SettingUser()));
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            userProvider.userP.userName != "" ||
                                                    userInit.userName != ""
                                                ? MainScreen(
                                                    UserId:
                                                        userProvider.userP.id)
                                                : LoginScreen())).then(
                                    (value) => setState(() {
                                          isLoading = true;
                                        }));
                              }
                            }
                          : null,
                      child: Image.asset(AppImages.nature)))
            ])));
  }
}

//......................lấy dữ liệu user ban đầu-------------------------
var urlGetUserJwt = Uri.parse(SERVER_IP + '/user/userJwt');

Future<UserModel> getUserJwt(String jwt) async {
  print(jwt);
  var res = await http.get(
    urlGetUserJwt,
    headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'cookie': "jwt=" + jwt,
    },
  );
  if (res.statusCode == 200 || res.statusCode == 201) {
    var data = json.decode(res.body);
    if (data != "not jwt" && data != "error") {
      if (data["userName"] != null) {
        print(data);
        print("Data cover----");
        print(data["coverImg"]);
        UserModel user = UserModel(
            userName: data["userName"],
            email: data["email"],
            id: data["_id"],
            friendRequest: data["friendRequest"],
            friendConfirm: data["friendConfirm"],
            friend: data["friend"],
            sex: data["sex"],
            feedImg: data["feedImg"],
            feedVideo: data["feedVideo"],
            seenTimeNotifi: data["seenTimeNotifi"],
            createdAt: data["createdAt"],
            addressTinh: data["addressTinh"],
            addressDetails: data["addressDetails"],
            birthDate: data["birthDate"],
            hadMessageList: data["hadMessageList"],
            avatarImg: data["avatarImg"],
            realName: data["realName"],
            coverImg: data["coverImg"]);

        return user;
      }
    }
  }

  return UserModel(
      friend: [],
      friendConfirm: [],
      friendRequest: [],
      coverImg: [],
      feedImg: [],
      feedVideo: [],
      avatarImg: [],
      hadMessageList: []);
}

//--------------------lay tat ca tin nhan ----------------------
Future<Map<String, List<MessageModel>>> getAllMsgFr(String jwt, int limit,
    int offset, String path, String sourceUserId, List hadMessageList) async {
  Map<String, List<MessageModel>> chatHad = {};
  List<MessageModel> output = [];
  chatHad["1"] = output;
  print("------chạy get all msg fr---------");
  String apiPath =
      path + "?limit=" + limit.toString() + "&offset=" + offset.toString();
  print(apiPath);
  var result = await getApi(jwt, apiPath);
  print("ket qua la :");
  print(result);

  if (result != "error" && result != "not jwt") {
    for (var i = 0; i < hadMessageList.length; i++) {
      List msg = result[sourceUserId + "/" + hadMessageList[i]];
      List<MessageModel> output = [];
      for (var j = 0; j < msg.length; j++) {
        MessageModel a = MessageModel(
            path: msg[j]["path"],
            time: msg[j]["time"],
            message: msg[j]["message"],
            targetId: msg[j]["targetId"],
            sourceId: msg[j]["sourceId"]);
        output.add(a);
      }
      output.sort((a, b) => a.time.compareTo(b.time));
      chatHad[sourceUserId + "/" + hadMessageList[i]] = output;
    }
    return chatHad;
  }
  return chatHad;
}

//----------------------lay thoong tin cua toan bo ban be---------------
getFriendUser(result, List listFr, bool isFr) {
  Map<String, UserModel> chatFriend = {};
  print("------chạy get avatar---------");
  Map<String, int> frOfFr = {};
  print("ket qua la :");
  print(result);
  if (result != "error" && result != "not jwt" && listFr.length > 0) {
    for (var i = 0; i < listFr.length; i++) {
      chatFriend[listFr[i]] = UserModel(
        friend: result[i]["friend"],
        friendConfirm: [],
        friendRequest: [],
        feedImg: [],
        feedVideo: [],
        coverImg: [],
        addressTinh: result[i]["addressTinh"],
        hadMessageList: [],
        id: result[i]["_id"],
        avatarImg: result[i]["avatarImg"],
        realName: result[i]["realName"],
      );
      if (isFr && chatFriend[listFr[i]]!.friend.length > 0) {
        for (int j = 0; j < chatFriend[listFr[i]]!.friend.length; j++) {
          if (frOfFr[chatFriend[listFr[i]]!.friend[j]] == null) {
            frOfFr[chatFriend[listFr[i]]!.friend[j]] = 1;
          } else {
            frOfFr[chatFriend[listFr[i]]!.friend[j]] =
                frOfFr[chatFriend[listFr[i]]!.friend[j]]! + 1;
          }
        }
      }
    }
  }
  if (isFr) {
    return [chatFriend, frOfFr];
  } else {
    return chatFriend;
  }
}

///lấy  các thông báo của user-------------
getNotiifiUserInitNotAvatar(result, String jwt) {
  List<NotifiModel> notifiInit = [];
  List<String> idSources = [];
  print("------chạy get notifi Init---------");
  print("ket qua la :");
  print(result);
  if (result != "error" && result != "not jwt") {
    for (int i = 0; i < result.length; i++) {
      NotifiModel not = NotifiModel(
        type: result[i]["type"],
        sourceIdUser: result[i]["sourceUserId"],
        targetIdUser: result[i]["targetUserId"],
        content: result[i]["content"],
        isSeen: result[i]["isSeen"],
        createdAt: result[i]["createdAt"],
      );
      if (idSources.indexOf(result[i]["sourceUserId"]) < 0) {
        idSources.add(result[i]["sourceUserId"]);
      }
      notifiInit.add(not);
    }
  }
  return [notifiInit, idSources];
}

getNotiifiUserAll(result, List<NotifiModel> notifiInit, List idSources) {
  Map<String, UserModel> notifiUser = {};

  if (result != "error" && result != "not jwt") {
    for (var i = 0; i < idSources.length; i++) {
      notifiUser[idSources[i]] = UserModel(
          friend: [],
          friendConfirm: [],
          feedImg: [],
          feedVideo: [],
          friendRequest: [],
          coverImg: [],
          hadMessageList: [],
          id: result[i]["_id"],
          avatarImg: result[i]["avatarImg"],
          realName: result[i]["realName"]);
    }
  }
  if (notifiInit.length > 0) {
    for (int i = 0; i < notifiInit.length; i++) {
      notifiInit[i].sourceRealnameUser =
          notifiUser[notifiInit[i].sourceIdUser]!.realName;
      notifiInit[i].sourceUserPathImg =
          notifiUser[notifiInit[i].sourceIdUser]!.avatarImg[
              notifiUser[notifiInit[i].sourceIdUser]!.avatarImg.length - 1];
    }
  }

  return notifiInit;
}

Future<dynamic> getApi(String jwt, String pathApi) async {
  print("get Api " + pathApi);
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

Future fetchApiFeedInit(
    String sourceId, String jwt, String limit, String offset) async {
  try {
    http.Response response;
    List<FeedBaseModel> data1 = [];
    //tim tin nhan cua nguoi gui cho ban
    String query =
        '?limit=' + limit + '&offset=' + offset + '&sourceId=' + sourceId;
    String path = SERVER_IP + '/feed/limitFeedOwn' + query;
    print(query);
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
      return json.decode(response.body);
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}

//lay tin nhan ban dau................
Future getFeedInit(sourceId, jwt, List listFr) async {
  List<FeedBaseModel> listFeedsInit = [];
  List<Future> fetchAllFeedFr = [];
  for (var i = 0; i < listFr.length; i++) {
    fetchAllFeedFr.add(
      fetchApiFeedInit(listFr[i], jwt, 3.toString(), 0.toString()),
    );
  }
  List data = await Future.wait([
    fetchApiFeedInit(sourceId, jwt, 50.toString(), 0.toString()),
    ...fetchAllFeedFr
    //  fetchData(targetId, sourceId)
  ]);
  if (data[0] == "not jwt" || data[0] == "error") {
    return listFeedsInit;
  } else {
    print("data 0");
    print(data[0]);
    for (int k = 0; k <= listFr.length; k++) {
      if (data[k].length > 0) {
        for (int i = 0; i < data[k].length; i++) {
          if (data[k] != []) {
            FeedBaseModel a = FeedBaseModel(
              pathImg: data[k][i]["pathImg"],
              rule: data[k][i]["rule"],
              pathVideo: data[k][i]["pathVideo"],
              comment: data[k][i]["comment"],
              feedId: data[k][i]["_id"].toString(),
              message: data[k][i]["messages"],
              tag: data[k][i]["tag"],
              like: data[k][i]["like"],
              sourceUserId: data[k][i]["sourceUserId"].toString(),
              createdAt: data[k][i]["createdAt"],
              sourceUserName: data[k][i]["sourceUserName"].toString(),
            );
            listFeedsInit.add(a);
          }
        }
      }
    }

    listFeedsInit.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return listFeedsInit;
  }
}
