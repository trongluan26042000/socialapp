import 'package:app1/feed/model/comment_model.dart';
import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/model/friendUser.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/Stream/user_stream.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

class CommentProvider with ChangeNotifier {
  MyStream myStream = new MyStream();
  Map<String, List<CommentFullModel>> listCommentP = {};
  String feedId = "";
  Future userComment(
      Map<String, List<CommentFullModel>> newCommentsList) async {
    try {
      listCommentP = newCommentsList;
    } catch (e) {}
    notifyListeners();
  }

  Future userFeedId(String newFeedId) async {
    try {
      feedId = newFeedId;
    } catch (e) {}
    notifyListeners();
  }
}
