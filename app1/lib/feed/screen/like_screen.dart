import 'dart:convert';

import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/feed/model/like_modal.dart';
import 'package:app1/main.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/feed_provider.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({Key? key, required this.feed}) : super(key: key);
  final FeedBaseModel feed;
  @override
  _LikeScreenState createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  List<LikeBaseModel> listLikes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      List<String> idLike = [];
      List<UserModel> users = [];
      List<LikeBaseModel> likes = [];
      var result = await Future.wait([
        getApi(userProvider.jwtP, "/feed/" + widget.feed.feedId),
      ]);
      if (result[0] != "not jwt" && result[0] != "error") {
        print(result[0]);
        print(result[0]["like"]);
        if (result[0]["like"] != null)
          for (int i = 0; i < result[0]["like"].length; i++) {
            idLike.add(result[0]["like"][i].toString());
          }
      }
      print("idLike là:");
      print(idLike);
      var resultApiUser = await Future.wait([
        PostApi(userProvider.jwtP, {"listUser": idLike}, "/user/listUser")
      ]);
      if (resultApiUser[0] != "not jwt" && resultApiUser[0] != "error") {
        print(resultApiUser[0]);
        if (resultApiUser[0].length >= 0) {
          for (int i = 0; i < resultApiUser[0].length; i++) {
            print("kêt quả số 0");
            print(resultApiUser[0][0]);
            UserModel user = UserModel(
                friend: [],
                hadMessageList: [],
                coverImg: [],
                feedImg: [],
                feedVideo: [],
                friendConfirm: [],
                friendRequest: [],
                realName: resultApiUser[0][i]["realName"],
                userName: resultApiUser[0][i]["userName"],
                id: resultApiUser[0][i]["_id"],
                avatarImg: resultApiUser[0][i]["avatarImg"]);
            users.add(user);
          }
        }
      }
      print("users-- lấy đc là");
      print(users);

      for (int i = 0; i < idLike.length; i++) {
        for (int j = 0; j < users.length; j++) {
          if (idLike[i] == users[j].id) {
            print("bằng ");
            print(users[j].id);
            LikeBaseModel like = LikeBaseModel(
                userLikeId: idLike[i],
                userLikeRealName: users[j].realName,
                userLikePathImg:
                    users[j].avatarImg[users[j].avatarImg.length - 1] != null
                        ? users[j].avatarImg[users[j].avatarImg.length - 1]
                        : "avatarNull");
            likes.add(like);
          }
        }
      }
      print("kêt quả cuối cùng like là");
      print(likes);
      if (mounted) {
        setState(() {
          listLikes = likes;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String getIsFriend(String id) {
      if (userProvider.userP.friend.indexOf(id) != -1) {
        return "Bạn bè";
      }
      if (userProvider.userP.id == id) {
        return "";
      }
      if (userProvider.userP.friendConfirm.indexOf(id) != -1) {
        return "Chấp nhận lời mời";
      }
      if (userProvider.userP.friendRequest.indexOf(id) != -1) {
        return "Đã gửi lời mời";
      }
      return "Kết bạn";
    }

    Future<String> addFr(String isFrTextModal, String jwt, String id) async {
      if (isFrTextModal == "Hủy kết bạn") {
        print("huy ket bạn");
        var result = await getApi(jwt, "/user/removeFriend/" + id);
        if (result != "not jwt" &&
            result != "error" &&
            result != "not friend") {
          userProvider.listFriendsP.remove(id);
          userProvider.userP.friend.remove(id);
          return "Kết bạn";
        } else {
          print(result);
        }
      }
      if (isFrTextModal == "Gửi yêu cầu kết bạn") {
        print("ket bạn");
        var result = await getApi(jwt, "/user/addfr/" + id);
        if (result != "not jwt" &&
            result != "error" &&
            result != "had friendConfirm" &&
            result != "had friendRequest" &&
            result != "had friend") {
          userProvider.userP.friendRequest.add(id);
          return "Đã gửi lời mời";
        } else {
          print(result);
        }
      }
      if (isFrTextModal == "Đồng ý kết bạn") {
        print("ket bạn");
        var result = await getApi(jwt, "/user/addfrConfirm/" + id);
        print("kết quả trả về khi add Fr là");
        print(result);
        if (result != "not jwt" &&
            result != "error" &&
            result != "had not request" &&
            result != "had not confirm" &&
            result != "had friend") {
          userProvider.userP.friend.add(id);
          userProvider.userP.friendConfirm.remove(id);
          userProvider.listFriendsP[id] = UserModel(
              friend: [],
              friendConfirm: [],
              friendRequest: [],
              coverImg: [],
              feedImg: [],
              feedVideo: [],
              hadMessageList: [],
              id: result["_id"].toString(),
              avatarImg: result["avatarImg"],
              realName: result["realName"]);
          print("----đã kết bạn--");
          return "Bạn bè";
        }
      }
      if (isFrTextModal == "Hủy lời mời") {
        print("hủy ket bạn");
        var result = await getApi(jwt, "/user/removeFrRequest/" + id);
        if (result != "not jwt" &&
            result != "error" &&
            result != "had not confirm" &&
            result != "had not request") {
          if (mounted) {
            userProvider.userP.friendRequest.remove(id);
            return "Kết bạn";
          }
        } else {
          print(result);
        }
      }

      if (isFrTextModal == "Xóa lời mời") {
        print("ket bạn");
        var result = await getApi(jwt, "/user/removeFrConfirm/" + id);
        if (result != "not jwt" &&
            result != "error" &&
            result != "had not confirm" &&
            result != "had not request") {
          if (mounted) {
            userProvider.userP.friendConfirm.remove(id);
            return "Kết bạn";
          }
        } else {
          print(result);
        }
      }

      return "error";
    }

    Widget modalChild(String isFr, String textIsFr, String frId) {
      String text = "";
      if (isFr == "Bạn bè") {
        text = "Hủy kết bạn";
      }
      if (isFr == "Kết bạn") {
        text = "Gửi yêu cầu kết bạn";
      }
      if (isFr == "Chấp nhận lời mời") {
        text = "Đồng ý kết bạn";
      }
      if (isFr == "Xóa lời mời") {
        text = "Xóa lời mời";
      }
      if (isFr == "Đã gửi lời mời") {
        text = "Hủy lời mời";
      }
      if (textIsFr == "Xóa lời mời") {
        text = "Xóa lời mời";
      }

      return Container(
        width: 250,
        height: 35,
        child: Material(
          color: Color.fromRGBO(80, 0, 80, 0.2),
          child: InkWell(
              onTap: () async {
                print(isFr);
                print(text);
                String a = await addFr(text, userProvider.jwtP, frId);
                print(a);
                if (a != "not jwt" && a != "error") {
                  setState(() {});
                  Navigator.pop(
                    context,
                    isFr = a,
                  );
                } else {
                  print("--addFr có lỗi");
                }
              },
              hoverColor: Colors.amber,
              child: Text(text,
                  style: TextStyle(fontSize: 24), textAlign: TextAlign.center)),
        ),
      );
    }

    return Scaffold(
      body: listLikes.length <= 0
          ? Center(child: Text("Không có ai thèm like"))
          : ListView.builder(
              itemCount: listLikes.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SizedBox(
                    height: 50,
                    child: Row(
                      children: [Text("Tất cả " + listLikes.length.toString())],
                    ),
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(),
                        Text(listLikes[index - 1].userLikeRealName),
                      ],
                    ),
                    InkWell(
                      onTap: () async {
                        String isFr =
                            getIsFriend(listLikes[index - 1].userLikeId);
                        print(userProvider.userP.friend);
                        await showModalBottomSheet<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 200,
                                child: Center(
                                  child: Column(
                                    // crossAxisAlignment:
                                    //     CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      SizedBox(),
                                      modalChild(isFr, "",
                                          listLikes[index - 1].userLikeId),
                                      isFr == "Chấp nhận lời mời"
                                          ? modalChild(isFr, "Xóa lời mời",
                                              listLikes[index - 1].userLikeId)
                                          : Container(),
                                      SizedBox(),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: Text(getIsFriend(listLikes[index - 1].userLikeId)),
                    )
                  ],
                );
              }),
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

  //
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
