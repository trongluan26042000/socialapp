import 'dart:convert';

import 'package:app1/pageRoute/BourcePageRoute.dart';
import 'package:app1/ui.dart';
import 'package:app1/user/screen/FriendProfile.dart';
import 'package:app1/main.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:app1/user/screen/suggestFriend.dart';
import 'package:app1/widgets/app_button.dart';
import 'package:app1/widgets/dismit_keybord.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _textController = TextEditingController();
  Map<String, UserModel> allFrConfirm = {};
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    allFrConfirm = userProvider.listConfirmFrP;
    final RoundedLoadingButtonController _btnIdController =
        RoundedLoadingButtonController();
    final RoundedLoadingButtonController _btnGmailController =
        RoundedLoadingButtonController();
    TextEditingController _textModalController = TextEditingController();
    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Tìm kiếm"),
        ),
        body: Column(children: [
          Container(
              height: 120,
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () async {
                        print("----search----------");
                        await showModalBottomSheet<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: size.height * 2 / 4,
                                child: Center(
                                  child: Column(
                                    // crossAxisAlignment:
                                    //     CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      SizedBox(),
                                      // Text("ảo"),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 20.0, left: 20),
                                        child: TextField(
                                            controller: _textModalController,
                                            decoration: InputDecoration(
                                              hintText: "Nhập tìm kiếm...",
                                            )),
                                      ),
                                      Material(
                                        child: RoundedLoadingButton(
                                          child: Text("Tìm bằng Id"),
                                          controller: _btnIdController,
                                          onPressed: () async {
                                            _textModalController.text;
                                            print(_textModalController.text);
                                            // await getApi(userProvider.jwtP,
                                            //     "/user/" + userProvider.userP.id);
                                          },
                                        ),
                                      ),
                                      Material(
                                        child: RoundedLoadingButton(
                                          child: Text("Tìm bằng Email"),
                                          controller: _btnGmailController,
                                          onPressed: () async {
                                            print("---ấn vào tìm- email--");
                                            var result = await getApi(
                                                userProvider.jwtP,
                                                "/user/email/" +
                                                    _textModalController.text);
                                            print(result);
                                            if (result != "error" &&
                                                result != "not jwt") {
                                              if (result["_id"] != null) {
                                                if (result["_id"] !=
                                                    userProvider.userP.id) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (builder) =>
                                                              FriendProfile(
                                                                  frId: result[
                                                                      "_id"])));
                                                }
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset("assets/icons/findPeopleIcon.png"),
                              Text("Tìm bạn bè"),
                            ],
                          ),
                          width: size.width / 2 - 20,
                          height: 120,
                          color: Color.fromRGBO(200, 100, 400, 0.2)),
                    ),
                    InkWell(
                      onTap: () {
                        print(userProvider.listFrOfFrP);
                        Navigator.push(context,
                            BourcePageRoute(widget: SuggestFriendScreen()));
                      },
                      child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset("assets/icons/findPeopleIcon.png"),
                              Text("Có thể bạn quen"),
                            ],
                          ),
                          width: size.width / 2 - 20,
                          height: 120,
                          color: Color.fromRGBO(200, 100, 400, 0.2)),
                    )
                  ],
                ),
              )),
          Divider(),
          Container(
            height: size.height - 300,
            child: ListView.builder(
                itemCount: userProvider.listConfirmFrP.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          print(userProvider.listConfirmFrP);
                        },
                        child: Text(
                          " Lời mời kết bạn ",
                          style: AppStyles.h3,
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => FriendProfile(
                                    frId: allFrConfirm[userProvider
                                            .userP.friendConfirm[index - 1]]!
                                        .id)));
                      },
                      child: ListTile(
                          tileColor: index % 2 == 0
                              ? Colors.amberAccent[100]
                              : Colors.lightBlueAccent[100],
                          title: Text(
                              allFrConfirm[userProvider
                                      .userP.friendConfirm[index - 1]]!
                                  .realName,
                              style: AppStyles.h4),
                          leading: CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 30,
                              backgroundImage:
                                  AssetImage('assets/images/load.gif'),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(SERVER_IP +
                                    "/upload/" +
                                    allFrConfirm[userProvider
                                            .userP.friendConfirm[index - 1]]!
                                        .avatarImg[allFrConfirm[userProvider
                                                .userP
                                                .friendConfirm[index - 1]]!
                                            .avatarImg
                                            .length -
                                        1]),
                                backgroundColor: Colors.transparent,
                              ))),
                    ),
                  );
                }),
          )
        ]),
      ),
    );
  }
}

Future<dynamic> getApi(String jwt, String pathApi) async {
  print("get Api " + pathApi);
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
