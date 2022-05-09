import 'dart:async';

import 'package:app1/chat-app/model/message_model.dart';
import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/model/friendUser.dart';
import 'package:app1/model/user_model.dart';

class MyStream {
  UserModel userS = UserModel(
      friend: [],
      friendConfirm: [],
      friendRequest: [],
      feedImg: [],
      feedVideo: [],
      coverImg: [],
      avatarImg: [],
      hadMessageList: []);
  List<FeedBaseModel> listFeedsS = [];
  StreamController<UserModel> userController =
      new StreamController<UserModel>.broadcast();

  StreamController<UserModel> inforFrController =
      new StreamController<UserModel>.broadcast();

  StreamController<List<FeedBaseModel>> feedController =
      new StreamController<List<FeedBaseModel>>.broadcast();

  StreamController<Map<String, List<MessageModel>>> messageController =
      new StreamController<Map<String, List<MessageModel>>>.broadcast();

  StreamController<Map<String, UserModel>> friendController =
      new StreamController<Map<String, UserModel>>.broadcast();

  StreamController<Map<String, UserModel>> hadChatController =
      new StreamController<Map<String, UserModel>>.broadcast();

  Stream<UserModel> get userStream => userController.stream;
  Stream<UserModel> get inforFrStream => inforFrController.stream;

  Stream<List<FeedBaseModel>> get feedStream => feedController.stream;
  Stream<Map<String, List<MessageModel>>> get messageStream =>
      messageController.stream;
  Stream<Map<String, UserModel>> get FriendStream => friendController.stream;
  Stream<Map<String, UserModel>> get HadChatStream => hadChatController.stream;

  void setUser(user) {
    print("setUser");
    userController.sink.add(user);
  }

  void setInforFr(user) {
    print("setUser");
    inforFrController.sink.add(user);
  }

  void setFeed(feed) {
    feedController.sink.add(feed);
  }

  void setMessage(message) {
    messageController.sink.add(message);
  }

  void setFriend(friend) {
    friendController.sink.add(friend);
  }

  void setHadChat(friend) {
    hadChatController.sink.add(friend);
  }

  void clearUser() {
    print("clearUser");
    userController.sink.add(UserModel(
        friend: [],
        friendConfirm: [],
        friendRequest: [],
        coverImg: [],
        feedImg: [],
        feedVideo: [],
        avatarImg: [],
        hadMessageList: []));
  }

  void dispose() {
    userController.close();
  }
}
