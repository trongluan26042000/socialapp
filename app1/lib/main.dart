import 'package:app1/Screen/All_Image_Sceen.dart';
import 'package:app1/chat-app/screens_chat/CameraScreen.dart';
import 'package:app1/chat-app/screens_chat/LoginScreen.dart';
import 'package:app1/chat-app/screens_chat/home.dart';
import 'package:app1/feed/screen/comment.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/comment_provider.dart';
import 'package:app1/provider/feed_provider.dart';
import 'package:app1/provider/message_provider.dart';
import 'package:app1/provider/notifi_provider.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:app1/sflashScreen/sfScreen.dart';
import 'package:app1/test_emoji.dart';
import 'package:app1/widgets/search.dart';
import 'package:camera/camera.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:page_transition/page_transition.dart';
import "package:app1/ui.dart";
import "Screen/LoadScreen.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_social/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

final InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
);
final storage = FlutterSecureStorage();
final UserModel userMain = UserModel(
    friend: [],
    friendConfirm: [],
    feedImg: [],
    feedVideo: [],
    friendRequest: [],
    coverImg: [],
    avatarImg: [],
    hadMessageList: []);
const SERVER_IP = 'http://3ef0-2402-800-6118-383e-7815-ba08-2d5f-5bbb.ngrok.io';
String _onNotificationClicked() {
  return "";
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  var selectNotification;
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
  print("start");
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) {
            return UserProvider();
          }),
          ChangeNotifierProvider(create: (context) {
            return MessageProvider();
          }),
          ChangeNotifierProvider(create: (context) {
            return FeedProvider();
          }),
          ChangeNotifierProvider(create: (context) {
            return NotifiProvider();
          }),
          ChangeNotifierProvider(create: (context) {
            return CommentProvider();
          })
        ],
        child: MaterialApp(
            title: "app1",
            // home: ChatLoginScreen()
            home: VideoPlayerScreen()
            //  home: Search()
            // home: Test()
            // home: Test()

            ));
  }
}
