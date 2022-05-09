import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class GoogleSingInProvider extends ChangeNotifier {
  final googleSingIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;
  Future googleLogin() async {
    try {
      final googleUser = await googleSingIn.signIn();
      if (googleUser == null) {
        return;
      }
      _user = googleUser;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("googleAuth ....... ${googleAuth}");
      print("credebtial ....... ${credential}");
      print("credebtial ....... ${_user}");

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  Future GoogleLogout() async {
    await googleSingIn.disconnect();
    FirebaseAuth.instance.signOut();
  }

  Future FacebookLogin() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status == LoginStatus.success) {
        print("login fb done");
        final userData = await FacebookAuth.instance.getUserData();
        print(userData);
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(loginResult.accessToken!.token);
        await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);
      } else {
        print(loginResult.status);
        print(loginResult.message);
      }
    } catch (e) {}
    // Trigger the sign-in flow

    notifyListeners();
  }

  Future FaceBookLogOut() async {}
}
