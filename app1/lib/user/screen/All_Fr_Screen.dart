import 'dart:io';
import 'dart:convert';

import 'package:app1/chat-app/model/message_model.dart';
import 'package:app1/chat-app/screens_chat/CameraScreen.dart';
import 'package:app1/chat-app/screens_chat/CameraView.dart';
import 'package:app1/feed/screen/post_feed.dart';
import 'package:app1/main.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:app1/widgets/app_button.dart';
import 'package:app1/widgets/dismit_keybord.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../../ui.dart';

class AllFriendScreen extends StatefulWidget {
  //final AllFriendScreen ? chatModel;
  const AllFriendScreen({
    Key? key,
    required this.user,
    required this.tag,
    this.onGetTag,
  }) : super(key: key);
  final UserModel user;
  final bool tag;
  final Function? onGetTag;

  @override
  _AllFriendScreen createState() => _AllFriendScreen();
}

class _AllFriendScreen extends State<AllFriendScreen> {
  final TextEditingController _inputFriendController = TextEditingController();
  late bool checkTag;
  List<bool> valueList = [];
  List<int> addressValueTag = [];
  //final List<String> ListTargetId = [];
  // final List<String> ListTargetName = [];
  List<MessageModel> messages = [];
  List ListTargerId = [];
  List ListTargetName = [];
  ScrollController _scrollController = ScrollController();
  bool checkinfo = true;

  get controller => null;
  List<UserModel> allFr = [];

  int dem = 0;

  void initState() {
    super.initState();
    checkTag = false;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      allFr = await getAllFrApi(
          userProvider.jwtP, "/user/listUser", widget.user.friend);
      if (allFr.length > 0) {
        for (var i = 0; i < widget.user.friend.length; i++) {
          valueList.add(false);
        }
        if (mounted) {
          setState(() {});
        }
      }
      // for (var i = 0; i < widget.ListTargerId.length;i++) {
      //   print(widget.ListTargerId[i]);
      //   var j =0;
      //   while(j < allFr.length) {
      //     if(widget.ListTargerId[i]==allFr[j].id) {
      //       valueList[j]=true;
      //       j=allFr.length;
      //       print("Xem người đã được tag trước ");
      //       print(allFr[j].realName);
      //     }
      //     else j=j+1;
      //   }
      //
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
        child: Scaffold(
      appBar: AppBar(title: Text("Tất cả bạn bè")),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 1, bottom: 1),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width - 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  (checkTag)

                      /// chỗ nút gắn thẻ  khi đã có chọn được bạn tag
                      ? GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: widget.tag
                                ? Text(
                                    "Gắn thẻ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black87),
                                  )
                                : Container(),
                          ),
                          onTap: () async {
                            print(ListTargetName);
                            print(ListTargerId);
                            if (widget.tag && widget.onGetTag != null) {
                              widget.onGetTag!(ListTargerId, ListTargetName);
                              Navigator.pop(context);
                            }
                          })
                      : GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black12),
                            ),
                          ),
                          onTap: null,
                        ),
                ],
              ),
            ),
          ),

          //gạch ngang
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 4, bottom: 2, top: 4),
                    child: Icon(Icons.search, size: 30, color: Colors.black87),
                  ),
                  Expanded(
                    child: TextField(
                        controller: _inputFriendController,
                        decoration: InputDecoration.collapsed(
                            hintText: "Tìm kiếm bạn bè")),
                  ),
                ],
              ),
              width: 330,
              decoration: BoxDecoration(
                color: const Color(0xff7c94b6),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ), // ô tìm biết bạn trong list

          ///hiển thị những bạn bè được tag
          (checkTag)
              ? Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dem,
                      itemBuilder: (listViewContext, index) {
                        return _buildFriendTag(index);
                      },
                    ),
                  ),
                )
              : Container(),

          ///list bạn bè
          Expanded(
            flex: 6,
            child: ListView.builder(
              itemCount: allFr.length,
              itemBuilder: (listViewContext, index) {
                return _buildRowFriend(index);
              },
            ),
          ), // list view builder comment
        ],
      ),
    ) //Scaffold
        ); // DismissKeyboard
  }

  Widget _buildFriendTag(int index) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: CircleAvatar(
          backgroundColor: Colors.red,
          radius: 30,
          backgroundImage: AssetImage('assets/images/load.gif'),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(SERVER_IP +
                "/upload/" +
                allFr[index].avatarImg[allFr[index].avatarImg.length - 1]),
            backgroundColor: Colors.transparent,
          )),
    );
  }

  Widget _buildRowFriend(int index) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/load.gif'),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(SERVER_IP +
                        "/upload/" +
                        allFr[index]
                            .avatarImg[allFr[index].avatarImg.length - 1]),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ), // Ảnh người cmt

              Text(allFr[index].realName, style: AppStyles.h4),
            ],
          ),
          widget.tag
              ? Checkbox(
                  value: valueList[index],
                  onChanged: (value) {
                    print("Vừa thay đổi người tag");
                    print(allFr[index].realName);
                    setState(() {
                      valueList[index] = value as bool;
                      if (valueList[index]) {
                        dem = dem + 1;
                        addressValueTag.add(index);
                        ListTargerId.add(allFr[index].id);
                        ListTargetName.add(allFr[index].realName);
                        for (var i = 0; i < ListTargetName.length; i++) {
                          print(ListTargetName[i]);
                        }
                        print(index);
                      } else {
                        dem = dem - 1;
                        print(index);
                        addressValueTag.remove(index);
                        ListTargerId.remove(allFr[index].id);
                        ListTargetName.remove(allFr[index].realName);
                      }
                      ;
                      print(valueList[index]);
                      for (var i = 0; i < allFr.length; i++) {
                        if (valueList[i]) {
                          checkTag = true;
                        }
                        ;
                        if (dem < 1) checkTag = false;
                      }
                    });
                  },
                )
              : Container(),
        ],
      ), // khung của mỗi người cmt
    );
  }

  Widget buildText(String text) {
    return ReadMoreText(
      text,
      trimLines: 2,
      trimMode: TrimMode.Line,
      trimCollapsedText: "Xem thêm",
      trimExpandedText: "Ẩn bớt",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
    );
  }
}

Future<List<UserModel>> getAllFrApi(
    String jwt, String pathApi, List listFr) async {
  List<UserModel> listFrResult = [];
  var result = await PostApi(jwt, {"listUser": listFr}, pathApi);
  if (result != "error" && result != "not jwt") {
    for (int i = 0; i < result.length; i++) {
      UserModel u = UserModel(
          friend: result[i]["friend"],
          hadMessageList: result[i]["hadMessageList"],
          id: result[i]["_id"],
          coverImg: result[i]["coverImg"],
          feedImg: result[i]["feedImg"],
          feedVideo: result[i]["feedVideo"],
          realName: result[i]["realName"],
          friendConfirm: result[i]["friendConfirm"],
          friendRequest: result[i]["friendRequest"],
          avatarImg: result[i]["avatarImg"]);
      listFrResult.add(u);
    }
    return listFrResult;
  }
  return [];
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
