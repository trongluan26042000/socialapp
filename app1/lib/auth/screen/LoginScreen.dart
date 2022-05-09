import 'dart:convert';

import 'package:app1/user/screen/Profile.dart';
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
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/text_input_style.dart';
import 'package:http/http.dart' as http;
import '../../widgets/dismit_keybord.dart';
import '../../widgets/app_button.dart';
import '../../widgets/background.dart';
import '../../ui.dart';
import 'RegisterScreen.dart';
import 'ForgotScreen.dart';
import '../../Screen/MainScreen.dart';
import 'package:provider/provider.dart';
import '../../auth_social/google_sign_in.dart';
import '../../auth_social/facebook_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  late FocusNode? myFocusNode;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var urlGetUserJwt = Uri.parse(SERVER_IP + '/user/userJwt');
  var urlLogin = Uri.parse(SERVER_IP + '/auth/login');
  bool isValidInput = false;
  Future<String> attemptLogIn(String userName, String password) async {
    var res = await http.post(urlLogin,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"userName": userName, "password": password}));
    if (res.statusCode == 200 || res.statusCode == 201) {
      var jwt = (res.body);
      print(jwt);
      return jwt;
    }
    return "error";
  }

  Future<UserModel> getUserJwt(String jwt) async {
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
      if (data != "not jwt") {
        if (data["userName"] != null) {
          print(data);
          UserModel user = UserModel(
              userName: data["userName"],
              email: data["email"],
              id: data["_id"],
              realName: data["realName"],
              friend: data["friend"],
              friendRequest: data["friendRequest"],
              friendConfirm: data["friendConfirm"],
              avatarImg: data["avatarImg"],
              sex: data["sex"],
              feedVideo: data["feedVideo"],
              feedImg: data["feedImg"],
              seenTimeNotifi: data["seenTimeNotifi"],
              createdAt: data["createdAt"],
              addressTinh: data["addressTinh"],
              addressDetails: data["addressDetails"],
              birthDate: data["birthDate"],
              hadMessageList: data["hadMessageList"],
              coverImg: data["coverImg"]);
          return user;
        }
      }
    }
    return UserModel(
        friend: [],
        friendConfirm: [],
        friendRequest: [],
        feedImg: [],
        feedVideo: [],
        coverImg: [],
        avatarImg: [],
        hadMessageList: []);
  }

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);

    final notifiProvider = Provider.of<NotifiProvider>(context, listen: false);

    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    print(userMain.userName);
    Size size = MediaQuery.of(context).size;

    String initText = "";
    // _passwordController.text = "hihi";
    var currentFocus;
    return Scaffold(
      appBar: AppBar(
        title: Text("Đăng nhập"),
        backgroundColor: Color.fromRGBO(200, 100, 400, 0.2),
      ),
      body: DismissKeyboard(
        child: Background(
            Column: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Text(
                  "Đăng nhập",
                  style: AppStyles.h2,
                ),
              ),
              CustomTextInput(
                textEditController: _userNameController,
                hintTextString: 'Tên đăng nhập',
                inputType: InputType.Default,
                enableBorder: true,
                themeColor: Theme.of(context).primaryColor,
                cornerRadius: 48.0,
                maxLength: 24,
                prefixIcon:
                    Icon(Icons.person, color: Theme.of(context).primaryColor),
                textColor: Colors.black,
                textInit: initText,
              ),
              CustomTextInput(
                textEditController: _passwordController,
                hintTextString: 'Mật khẩu',
                inputType: InputType.Default,
                enableBorder: true,
                themeColor: Theme.of(context).primaryColor,
                cornerRadius: 48.0,
                maxLength: 24,
                prefixIcon:
                    Icon(Icons.lock, color: Theme.of(context).primaryColor),
                textColor: Colors.black,
                textInit: initText,
              ),
              (_userNameController.text.length >= 6 == true &&
                      _passwordController.text.length >= 6 == true)
                  ? RoundedLoadingButton(
                      child: Text("Đăng nhập"),
                      controller: _btnController,
                      onPressed: isLoading == false
                          ? () async {
                              isLoading = true;
                              print(isValidInput);
                              var userName = _userNameController.text;
                              var password = _passwordController.text;
                              print("userName: " +
                                  userName +
                                  " password: " +
                                  password);
                              var jwt = await attemptLogIn(userName, password);
                              print("jwt: " + jwt);
                              if (jwt != "" &&
                                  jwt != "isLogin" &&
                                  jwt != "error") {
                                if (jwt.substring(36, 37) == ".") {
                                  await storage.write(key: "jwt", value: jwt);
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setString('jwt', jwt);
                                  UserModel user = await getUserJwt(jwt);
                                  if (user.userName != "") {
                                    userProvider.userLogin(user, jwt);
                                    Map<String, List<MessageModel>>
                                        listMsgInit = {};
                                    Map<String, UserModel> listFrInit = {};
                                    Map<String, UserModel> listHadChat = {};
                                    List<FeedBaseModel> listFeedsInit = [];
                                    Map<String, UserModel> listConfirmFr = {};
                                    Map<String, UserModel> listFrOfFr = {};

                                    Map<String, int> listIdFrOfFr = {};
                                    List<FeedBaseModel> newListFeedOwnInit = [];
                                    List<FeedBaseModel> newListFeedFrInit = [];
                                    listMsgInit = await getAllMsgFr(
                                        jwt,
                                        20,
                                        0,
                                        "/message/allMsgFR",
                                        user.id,
                                        user.hadMessageList);
                                    var result = await Future.wait([
                                      PostApi(jwt, {"listUser": user.friend},
                                          "/user/listUser"),
                                      PostApi(
                                          jwt,
                                          {"listUser": user.hadMessageList},
                                          "/user/listUser"),
                                      getApi(
                                          jwt,
                                          "/notification/findLimit?limit=50&offset=0&targetUserId=" +
                                              user.id),
                                      getApi(jwt,
                                          "/notification/findLimitNotTargetId?limit=50&offset=0"),
                                      getFeedInit(user.id, jwt, user.friend),
                                      PostApi(
                                          jwt,
                                          {"listUser": user.friendConfirm},
                                          "/user/listUser"),
                                    ]);
                                    listFrInit = getFriendUser(
                                        result[0], user.friend, true)[0];
                                    listConfirmFr = getFriendUser(
                                        result[5], user.friendConfirm, false);

                                    listIdFrOfFr = getFriendUser(
                                        result[0], user.friend, true)[1];
                                    listHadChat = getFriendUser(
                                        result[1], user.hadMessageList, false);
                                    var notifiInitNotAvatar =
                                        getNotiifiUserInitNotAvatar(
                                            result[2], jwt);
                                    List keyIdFrOfFr = [];
                                    if (listIdFrOfFr.keys != null) {
                                      keyIdFrOfFr.addAll(listIdFrOfFr.keys);
                                    }
                                    var userListResultApi = await Future.wait([
                                      PostApi(
                                          jwt,
                                          {"listUser": notifiInitNotAvatar[1]},
                                          "/user/listUser"),
                                      PostApi(jwt, {"listUser": keyIdFrOfFr},
                                          "/user/listUser"),
                                    ]);
                                    print("lấy user notifiInit");
                                    print(userListResultApi[0]);
                                    listFrOfFr = getFriendUser(
                                        userListResultApi[1],
                                        keyIdFrOfFr,
                                        false);

                                    List<NotifiModel> notifiInit = [];
                                    notifiInit = getNotiifiUserAll(
                                        userListResultApi[0],
                                        notifiInitNotAvatar[0],
                                        notifiInitNotAvatar[1]);
                                    if (result[3].length > 0) {
                                      for (int i = 0;
                                          i < result[3].length;
                                          i++) {
                                        if (result[3][i].length > 0) {
                                          for (int j = 0;
                                              j < result[3][i].length;
                                              j++) {
                                            notifiInit.add(NotifiModel(
                                                type: "newFeed",
                                                content: result[3][i][j]
                                                    ["content"],
                                                targetIdUser: result[3][i][j]
                                                    ["targetUserId"],
                                                sourceRealnameUser:
                                                    listFrInit[result[3][i][j]["sourceUserId"]]!
                                                        .realName,
                                                createdAt: result[3][i][j]
                                                    ["createdAt"],
                                                sourceUserPathImg: listFrInit[result[3][i][j]["sourceUserId"]]!.avatarImg[
                                                    listFrInit[result[3][i][j]["sourceUserId"]]!
                                                            .avatarImg
                                                            .length -
                                                        1],
                                                sourceIdUser: result[3][i][j]
                                                    ["sourceUserId"]));
                                          }
                                        }
                                      }
                                    }
                                    listFeedsInit = result[4];
                                    for (int i = 0;
                                        i < listFeedsInit.length;
                                        i++) {
                                      if (listFeedsInit[i].sourceUserId ==
                                          user.id) {
                                        newListFeedOwnInit
                                            .add(listFeedsInit[i]);
                                      } else {
                                        newListFeedFrInit.add(listFeedsInit[i]);
                                      }
                                    }
                                    notifiInit.sort((a, b) =>
                                        b.createdAt.compareTo(a.createdAt));
                                    notifiProvider.userNotifi(notifiInit);
                                    messageProvider.userMessage(listMsgInit);
                                    userProvider.userFriends(listFrInit);
                                    userProvider.listFrOfFrP = listFrOfFr;
                                    userProvider.listConfirmFrP = listConfirmFr;
                                    userProvider.userHadChats(listHadChat);
                                    notifiProvider.timeSeen =
                                        user.seenTimeNotifi;
                                    notifiInit.sort((a, b) =>
                                        b.createdAt.compareTo(a.createdAt));
                                    feedProvider.userFeed(newListFeedOwnInit);
                                    feedProvider.userFrFeed(newListFeedFrInit);
                                    isLoading = false;

                                    if (user.realName == "user") {
                                      print("---chưa nhập thông tin---mới ");
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SettingUser()));
                                    } else {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MainScreen(
                                                    UserId: user.id,
                                                  )));
                                    }
                                  } else {
                                    CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.error,
                                      text: "Lỗi !",
                                    );
                                  }
                                } else {
                                  CoolAlert.show(
                                    context: context,
                                    type: CoolAlertType.error,
                                    text: "Lỗi !",
                                  );
                                }
                              } else {
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.error,
                                  text: "Lỗi !",
                                );
                              }
                              // UserModel userTest = UserModel(userName: "linh tinh ");
                              // userProvider.userLogin(userTest);
                              // Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => MainScreen()));

                              _btnController.reset();
                            }
                          : null)
                  : AppBTnStyle(
                      onTap: null,
                      color: Color.fromRGBO(255, 255, 255, 0.4),
                      label: "Đăng nhập",
                    ),
              Divider(height: 60, color: Colors.black),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ForgotScreen()));
                    },
                    child: Text(
                      "Quên mật khẩu",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    )),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()));
                  },
                  child: RichText(
                      text: TextSpan(
                          text: "bạn chưa có tài khoản     ",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          children: [
                        TextSpan(
                          text: "ĐĂNG KÝ",
                          style: TextStyle(color: Colors.orangeAccent),
                        )
                      ]))),
            ],
          ),
        )),
      ),
    );
  }
}

Future<Map<String, List<MessageModel>>> getAllMsgFr(String jwt, int limit,
    int offset, String path, String sourceUserId, List hadMessageList) async {
  Map<String, List<MessageModel>> chatHad = {};

  print("------chạy get all msg fr---------");
  String apiPath =
      path + "?limit=" + limit.toString() + "&offset=" + offset.toString();
  print(apiPath);
  var result = await getApi(jwt, apiPath);
  print("ket qua la :");
  print(result);

  if (result != "error" && result != "not listFrjwt") {
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

getNotiifiUserAll(result, List<NotifiModel> notifiInit, List idSources) {
  Map<String, UserModel> notifiUser = {};

  if (result != "error" && result != "not jwt") {
    for (var i = 0; i < idSources.length; i++) {
      notifiUser[idSources[i]] = UserModel(
          friend: [],
          friendConfirm: [],
          friendRequest: [],
          coverImg: [],
          feedVideo: [],
          feedImg: [],
          hadMessageList: [],
          id: result[i]["_id"],
          avatarImg: result[i]["avatarImg"],
          realName: result[i]["realName"]);
    }
  }
  for (int i = 0; i < notifiInit.length; i++) {
    notifiInit[i].sourceRealnameUser =
        notifiUser[notifiInit[i].sourceIdUser]!.realName;
    notifiInit[i].sourceUserPathImg =
        notifiUser[notifiInit[i].sourceIdUser]!.avatarImg[
            notifiUser[notifiInit[i].sourceIdUser]!.avatarImg.length - 1];
  }
  return notifiInit;
}

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
              comment: data[k][i]["comment"],
              feedId: data[k][i]["_id"].toString(),
              message: data[k][i]["messages"],
              tag: data[k][i]["tag"],
              pathVideo: data[k][i]["pathVideo"],
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
