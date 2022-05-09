import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:app1/chat-app/model/message_model.dart';
import 'package:app1/main.dart';
import 'package:app1/provider/message_provider.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class OwnMessageCard extends StatelessWidget {
  const OwnMessageCard({Key? key, required this.msg}) : super(key: key);
  final MessageModel msg;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    return InkWell(
      onLongPress: () async {
        print(msg.sourceId);
        print("longpress ");
        await showModalBottomSheet<String>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                  height: 100,
                  child: SizedBox(
                      height: 100,
                      width: 100,
                      child: InkWell(
                        onTap: () async {
                          var result = await showOkCancelAlertDialog(
                              context: context,
                              onWillPop: () async {
                                return true;
                              },
                              title: "Bạn có chắc chắn muốn xóa?");
                          if (result == OkCancelResult.ok) {
                            print("đã đồng ý");
                            print(msg.sourceId);

                            var res = await DeleteApi(
                                userProvider.jwtP,
                                {
                                  "time": msg.time,
                                  "targetId": msg.targetId,
                                  "sourceId": msg.sourceId,
                                  "path": "",
                                  "message": msg.message,
                                },
                                "/message/individual");
                            print("kết quả khi delete ");
                            if (res != "error" && res != "not jwt") {
                              if (res == "done") {
                                messageProvider.listMessageP[
                                        userProvider.userP.id +
                                            "/" +
                                            msg.targetId]!
                                    .remove(msg);
                              }

                              if (res == "0") {
                                userProvider.userP.hadMessageList
                                    .remove(msg.targetId);
                                userProvider.listHadChatP.remove(
                                    userProvider.userP.id + "/" + msg.targetId);
                                messageProvider.listMessageP.remove(
                                    userProvider.userP.id + "/" + msg.targetId);
                              }
                              messageProvider
                                  .userMessage(messageProvider.listMessageP);
                              Navigator.pop(context);
                            }
                          } else {
                            print("cancel");
                          }
                        },
                        child: Image.asset("assets/icons/deleteIcon.png",
                            height: 45),
                      )));
            });
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 45,
            ),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              margin: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
              color: Color(0xffdcf8c6),
              child: Stack(
                children: [
                  //tin nhắn....................................
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 60, top: 05, bottom: 20),
                    child: Text(msg.message, style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: 5),
                  //ngày tháng,.....................................
                  Positioned(
                    bottom: 4,
                    right: 10,
                    child: Row(
                      children: [
                        Text(msg.time.substring(11, 17),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            )),
                        Icon(
                          Icons.done_all,
                          size: 20,
                        )
                      ],
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}

Future<dynamic> getApi(String jwt, String pathApi) async {
  print("--------get Api---------" + pathApi);
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

Future PostApi(String jwt, data, String pathApi) async {
  http.Response response;
  print("----post---------" + pathApi);
  response = await http.post(Uri.parse(SERVER_IP + pathApi),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'cookie': "jwt=" + jwt
      },
      body: jsonEncode(data));

  if (response.statusCode == 200 || response.statusCode == 201) {
    print("-----kêt quả post--------");
    print(json.decode(response.body).toString());
    return json.decode(response.body);
  } else {
    print("---------------post lỗi---------");
    return "error";
  }
}

Future DeleteApi(String jwt, data, String pathApi) async {
  http.Response response;
  print("----post---------" + pathApi);
  response = await http.delete(Uri.parse(SERVER_IP + pathApi),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'cookie': "jwt=" + jwt
      },
      body: jsonEncode(data));

  if (response.statusCode == 200 || response.statusCode == 201) {
    print("-----kêt quả delete--------");
    print(json.decode(response.body).toString());
    return json.decode(response.body);
  } else {
    print("---------------kết quả delete---------");
    return "error";
  }
}
