import 'package:app1/chat-app/screens_chat/CameraScreen.dart';
import 'package:flutter/cupertino.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CameraScreen(
      targetId: "camera",
      event: "",
    );
  }
}
