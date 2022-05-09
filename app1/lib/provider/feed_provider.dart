import 'package:app1/chat-app/model/message_model.dart';
import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/model/friendUser.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/Stream/user_stream.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

class FeedProvider with ChangeNotifier {
  MyStream myStream = new MyStream();

  List<FeedBaseModel> listFeedsP = [];
  List<FeedBaseModel> listFeedsFrP = [];
  List<FeedBaseModel> listFeedsVisionFrP = [];

  Future userFeed(List<FeedBaseModel> newFeeds) async {
    try {
      listFeedsP = newFeeds;
      myStream.setFeed(newFeeds);
    } catch (e) {}
    notifyListeners();
  }

  Future userFrFeed(List<FeedBaseModel> newFeeds) async {
    try {
      listFeedsFrP = newFeeds;
      // myStream.setFeed(newFeeds);
    } catch (e) {}
    notifyListeners();
  }

  Future userFrVisionFeed(List<FeedBaseModel> newFeeds) async {
    try {
      listFeedsVisionFrP = newFeeds;
      // myStream.setFeed(newFeeds);
    } catch (e) {}
    notifyListeners();
  }
}
