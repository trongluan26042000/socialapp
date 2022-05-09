import 'dart:convert';
import 'dart:io';

import 'package:app1/main.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class CameraViewPage extends StatelessWidget {
  const CameraViewPage(
      {Key? key,
      this.path,
      this.onImageSend,
      this.file,
      required this.targetId,
      this.feedId,
      this.event})
      : super(key: key);
  final String? path;
  final XFile? file;
  final String? feedId;

  final String targetId;
  final String? event;
  final Function? onImageSend;
  static TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final RoundedLoadingButtonController _btnController =
        RoundedLoadingButtonController();
    return Scaffold(
        backgroundColor: Colors.black12,
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            IconButton(
                onPressed: () {}, icon: Icon(Icons.crop_rotate, size: 27)),
            IconButton(
                onPressed: () {},
                icon: Icon(Icons.emoji_emotions_outlined, size: 27)),
            IconButton(onPressed: () {}, icon: Icon(Icons.title, size: 27)),
            IconButton(onPressed: () {}, icon: Icon(Icons.edit, size: 27))
          ],
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 150,
                child: Image.file(
                  File(path!),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  color: Colors.black38,
                  padding:
                      EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                  width: MediaQuery.of(context).size.width,
                  //text input camera ...........................................
                  child: TextFormField(
                      controller: _controller,
                      maxLines: 6,
                      minLines: 1,
                      style: TextStyle(color: Colors.white, fontSize: 17),
                      decoration: InputDecoration(
                          hintText: "Add Caption ... ",
                          prefixIcon: Icon(Icons.add_photo_alternate,
                              color: Colors.white),
                          suffixIcon: Container(
                            height: 30,
                            width: 30,
                            child: RoundedLoadingButton(
                              controller: _btnController,
                              onPressed: () async {
                                print("-----ddang an vao ---");
                                if (onImageSend != null) {
                                  if (event == "avatar" || event == "cover") {
                                    onImageSend!(
                                        path, event, userProvider.jwtP);
                                  }
                                  if (event == "message") {
                                    print("chạy hàm gửi");
                                    onImageSend!(
                                        path,
                                        userProvider.jwtP,
                                        userProvider.userP.id,
                                        targetId,
                                        DateTime.now().toString());
                                  }
                                  if (event == "comment") {
                                    onImageSend!(
                                        path, userProvider.jwtP, feedId);
                                  }
                                }

                                _controller.clear();
                              },
                              child: CircleAvatar(
                                  radius: 27,
                                  backgroundColor: Colors.tealAccent,
                                  child: Icon(Icons.check, size: 27)),
                            ),
                          ),
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 17),
                          border: InputBorder.none)),
                ),
              )
            ])));
  }

  //--------------------------------
  postApi(String jwt, data, String sourcePath) async {
    print("----chạy hàm post api feed---------------");
    try {
      http.Response response;
      String path = SERVER_IP + sourcePath;
      print(path);
      response = await http.post(Uri.parse(path),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            'cookie': "jwt=" + jwt,
          },
          body: jsonEncode(data));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return "error";
      }
    } catch (e) {
      return "error";
    }
  }

  //-------------------------------------------
  ChangeImgUser(String jwt, data, String sourcePath) async {
    var result = await postApi(jwt, data, sourcePath);
    if (result == "done") {
      print("---da post thanh coong ---------");
    } else {
      print("---khoong guwri ddc arnh ");
    }
  }
}
