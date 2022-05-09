import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

class FacebookSignInProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _facebooklogin = FacebookLogin();
  Future facebookLogin() async {
    try {
      print("login fb");
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        print("login fb done");

        final userData = await FacebookAuth.instance.getUserData();
      } else {
        print(result.status);
        print(result.message);
      }
    } catch (e) {}

    notifyListeners();
  }

  Future FaceBookLogOut() async {
    Future _logout() async {
      // SignOut khỏi Firebase Auth
      await _auth.signOut();
      // Logout facebook
      await _facebooklogin.logOut();
    }
  }
}
