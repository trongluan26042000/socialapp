import 'package:app1/chat-app/model/message_model.dart';
import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/model/friendUser.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/Stream/user_stream.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

class UserProvider with ChangeNotifier {
  MyStream myStream = new MyStream();
  UserModel userP = UserModel(
      userName: "",
      friend: [],
      feedImg: [],
      feedVideo: [],
      friendConfirm: [],
      friendRequest: [],
      coverImg: [],
      avatarImg: [],
      hadMessageList: []);
  UserModel inforFrP = UserModel(
      userName: "",
      friend: [],
      friendConfirm: [],
      friendRequest: [],
      feedImg: [],
      feedVideo: [],
      coverImg: [],
      avatarImg: [],
      hadMessageList: []);
  String jwtP = "";

  Map<String, UserModel> listFriendsP = {};
  Map<String, UserModel> listFrOfFrP = {};

  Map<String, UserModel> listHadChatP = {};
  Map<String, UserModel> listConfirmFrP = {};

  Future userLogin(UserModel user, String jwt) async {
    try {
      userP = user;
      jwtP = jwt;
      myStream.setUser(user);
    } catch (e) {}
    notifyListeners();
  }

  Future setInforFr(UserModel user) async {
    try {
      inforFrP = user;

      myStream.setUser(user);
    } catch (e) {}
    notifyListeners();
  }

  Future userFriends(Map<String, UserModel> newFrList) async {
    try {
      listFriendsP = newFrList;
      myStream.setMessage(newFrList);
    } catch (e) {}
    notifyListeners();
  }

  Future userHadChats(Map<String, UserModel> newFrList) async {
    try {
      listHadChatP = newFrList;
      myStream.setMessage(newFrList);
    } catch (e) {}
    notifyListeners();
  }

  Future userConfirmFr(Map<String, UserModel> newFrList) async {
    try {
      listConfirmFrP = newFrList;
    } catch (e) {}
    notifyListeners();
  }

  Future userFrOfFr(Map<String, UserModel> newFrListNew) async {
    try {
      listFrOfFrP = newFrListNew;
    } catch (e) {}
    notifyListeners();
  }

  Future UserLogOut() async {
    userP = UserModel(
        friend: [],
        friendConfirm: [],
        friendRequest: [],
        coverImg: [],
        feedImg: [],
        feedVideo: [],
        avatarImg: [],
        hadMessageList: []);
  }
}
