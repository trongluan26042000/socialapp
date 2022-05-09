import 'dart:convert';
import 'package:app1/Screen/All_Image_Sceen.dart';
import 'package:app1/auth/screen/AgainPassword.dart';
import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/feed/widget/Card_feed_null.dart';
import 'package:app1/sflashScreen/sfScreen.dart';
import 'package:app1/user/screen/FriendProfile.dart';
import 'package:app1/Screen/LoadScreen.dart';
import 'package:app1/Screen/MainScreen.dart';
import 'package:app1/user/screen/SettingUser.dart';

import 'package:app1/auth_social/google_sign_in.dart';
import 'package:app1/chat-app/screens_chat/CameraView.dart';
import 'package:app1/feed/screen/post_feed.dart';
import 'package:app1/main.dart';

import 'package:app1/model/friendUser.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/feed_provider.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:app1/user/screen/All_Fr_Screen.dart';
import 'package:app1/widgets/background.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app1/ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../../widgets/app_button.dart';
import 'friend_avatar.dart';
import 'package:http/http.dart' as http;
import '../../feed/widget/card_feed.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int popTime = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final RoundedLoadingButtonController _btnLogoutController =
        RoundedLoadingButtonController();
    String pathAvatar = userProvider.userP.avatarImg != null &&
            userProvider.userP.avatarImg.length != 0
        ? SERVER_IP +
            "/upload/" +
            userProvider
                .userP.avatarImg[userProvider.userP.avatarImg.length - 1]
        : SERVER_IP + "/upload/avatarNull.jpg";
    String pathCover = userProvider.userP.coverImg != null &&
            userProvider.userP.coverImg.length != 0
        ? SERVER_IP +
            "/upload/" +
            userProvider.userP.coverImg[userProvider.userP.coverImg.length - 1]
        : SERVER_IP + "/upload/avatarNull.jpg";

    void onImageSend(String path, String event, String jwt) async {
      print("image.............${path}");
      var request = http.MultipartRequest(
          "POST", Uri.parse(SERVER_IP + "/file/img/upload"));
      request.fields["eventChangeImgUser"] = event;
      request.files.add(await http.MultipartFile.fromPath("img", path));
      request.headers.addAll(
          {"Content-type": "multipart/form-data", "cookie": "jwt=" + jwt});

      http.StreamedResponse response = await request.send();

      var httpResponse = await http.Response.fromStream(response);
      print(httpResponse.statusCode);
      if (httpResponse.statusCode == 201 || httpResponse.statusCode == 200) {
        var data = json.decode(httpResponse.body).toString();

        if (data == "error" || data == "not jwt") {
          print(data);
        } else {
          print(data);
          UserModel user = userProvider.userP;
          if (event == "avatar") {
            List avatar = user.avatarImg;
            avatar.add(data);
            user.avatarImg = avatar;
          }
          if (event == "cover") {
            List cover = user.coverImg;
            cover.add(data);
            user.coverImg = cover;
          }
          userProvider.userLogin(user, userProvider.jwtP);
          for (var i = 0; i < popTime; i++) {
            if (mounted) Navigator.pop(context);
          }
          if (mounted)
            setState(() {
              popTime = 0;
            });
        }
      } else {
        print("er");
      }
    }

    UserModel _userProfile;
    final ImagePicker _picker = ImagePicker();
    // final user = FirebaseAuth.instance.currentUser!;
    int numLine = 5;

    Size size = MediaQuery.of(context).size;
    ScrollController _scrollController = new ScrollController();
    print(userProvider.userP.userName);
    return Scaffold(
      body: Background(
        Column: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                itemCount: feedProvider.listFeedsP.length + 5,
                itemBuilder: (context, index) {
                  if (index == feedProvider.listFeedsP.length + 4) {
                    return CardFeedStyleNull(
                        feed: FeedBaseModel(
                            pathImg: ["khampha.jpg"],
                            pathVideo: [],
                            message: "Hãy cùng khám phá😉😍😘✌️🏖!",
                            comment: [],
                            createdAt: DateTime.now().toString(),
                            tag: [],
                            rule: ["every"],
                            like: []));
                  }
                  if (index == 0) {
                    return Container(
                      height: size.height / 3,
                      child: Stack(
                        children: [
                          Container(
                            height: size.height / 9 * 2,
                            width: size.width,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(20)),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: pathCover,
                              fit: BoxFit.fitWidth,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                          Positioned(
                              left:
                                  ((size.width - 16) - (size.height - 16) / 6) /
                                          2 -
                                      4,
                              right: null,
                              top: size.height / 36 * 5,
                              child: CircleAvatar(
                                radius: 78,
                                backgroundImage:
                                    AssetImage('assets/images/load.gif'),
                                child: CircleAvatar(
                                  radius: 75,
                                  backgroundImage: NetworkImage(pathAvatar),
                                  backgroundColor: Colors.transparent,
                                ),
                              )),
                          //------camera bia--------------------------
                          Positioned(
                              top: size.height / 36 * 6,
                              right: 10,
                              child: CircleAvatar(
                                backgroundColor: Color.fromRGBO(0, 0, 0, 0.4),
                                child: IconButton(
                                  color: Colors.grey,
                                  icon: Icon(Icons.camera_alt_sharp,
                                      color: Colors.blueAccent, size: 20),
                                  onPressed: () async {
                                    if (mounted)
                                      setState(() {
                                        popTime = 1;
                                      });
                                    print(
                                        "chuyen sang camera................................");
                                    final XFile? file = await _picker.pickImage(
                                        source: ImageSource.gallery);
                                    print(file);
                                    file != null
                                        ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    CameraViewPage(
                                                      path: file.path,
                                                      targetId: "",
                                                      event: "cover",
                                                      onImageSend: onImageSend,
                                                    )))
                                        : print("chọn file");
                                  },
                                ),
                              )),

                          ///---------------camera ở avatar------------------
                          Positioned(
                              top: size.height / 36 * 9,
                              left:
                                  ((size.width - 16) + (size.height - 16) / 6) /
                                          2 -
                                      28,
                              child: CircleAvatar(
                                backgroundColor: Color.fromRGBO(0, 0, 0, 0.4),
                                child: IconButton(
                                  color: Colors.grey,
                                  icon: Icon(Icons.camera_alt_sharp,
                                      color: Colors.blueAccent, size: 20),
                                  onPressed: () async {
                                    if (mounted)
                                      setState(() {
                                        popTime = 1;
                                      });
                                    print(
                                        "chuyen sang camera................................");
                                    final XFile? file = await _picker.pickImage(
                                        source: ImageSource.gallery);
                                    print(file);
                                    file != null
                                        ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    CameraViewPage(
                                                      path: file.path,
                                                      targetId: "",
                                                      event: "avatar",
                                                      onImageSend: onImageSend,
                                                    )))
                                        : print("chọn file");
                                  },
                                ),
                              )),
                          Positioned(
                              top: size.height / 36 * 9 - 20,
                              right: 0,
                              child: IconButton(
                                icon:
                                    Text("...", style: TextStyle(fontSize: 30)),
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (builder) => Container(
                                            height: 300,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 38.0),
                                                  child: RoundedLoadingButton(
                                                      child: Text('Đăng xuất',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                      controller:
                                                          _btnLogoutController,
                                                      onPressed: () async {
                                                        await logoutFunction(
                                                            userProvider.jwtP);
                                                        await storage.delete(
                                                            key: "jwt");
                                                        await userProvider
                                                            .UserLogOut();
                                                        _btnLogoutController
                                                            .success();
                                                        Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (builder) =>
                                                                        VideoPlayerScreen()));
                                                      }),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 38.0),
                                                  child: RoundedLoadingButton(
                                                      child: Text(
                                                          'Đổi mật khẩu',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                      controller:
                                                          _btnLogoutController,
                                                      onPressed: () async {
                                                        _btnLogoutController
                                                            .success();
                                                        print("đổi mật khẩu");
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (builder) => AgainForgotScreen(
                                                                    userName: userProvider
                                                                        .userP
                                                                        .userName,
                                                                    email: userProvider
                                                                        .userP
                                                                        .email,
                                                                    token: userProvider
                                                                        .jwtP)));
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ));
                                },
                              ))
                        ],
                      ),
                    );
                  }
                  if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 32.0, bottom: 32),
                      child: Center(
                        child: Text(userProvider.userP.realName,
                            style: AppStyles.h2
                                .copyWith(fontWeight: FontWeight.bold)),
                      ),
                    );
                  }
                  if (index == 2) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container()
                        // Container(
                        //     child: AppBTnStyle(
                        //         label: "Đổi mật khẩu",
                        //         onTap: () {
                        //           print("đổi mật khẩu");
                        //           Navigator.push(
                        //               context,
                        //               MaterialPageRoute(
                        //                   builder: (builder) => AgainForgotScreen(
                        //                       userName:
                        //                           userProvider.userP.userName,
                        //                       email: userProvider.userP.email,
                        //                       token: userProvider.jwtP)));
                        //         })),
                        // AppBTnStyle(
                        //     label: "Đăng xuất",
                        //     onTap: () async {
                        //       await logoutFunction(userProvider.jwtP);
                        //       await storage.delete(key: "jwt");
                        //       await userProvider.UserLogOut();
                        //       Navigator.pushReplacement(
                        //           context,
                        //           MaterialPageRoute(
                        //               builder: (builder) => LoadScreen()));
                        //     }),
                      ],
                    );
                  }
                  if (index == 3) {
                    return Container(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: [
                                Icon(Icons.lock_clock),
                                Text(
                                    "   Bắt đầu từ " +
                                        userProvider.userP.createdAt
                                            .substring(4, 15),
                                    style: AppStyles.h4),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.badge),
                                Text("   Học tại đh Công Nghệ",
                                    style: AppStyles.h4),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.add_to_home_screen_sharp),
                                Text(
                                    "  Quê quán " +
                                        userProvider.userP.addressTinh,
                                    style: AppStyles.h4),
                              ],
                            ),
                            TextButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.wysiwyg),
                                label: Text("   Xem chi tiết")),
                            IconButton(
                                icon:
                                    Image.asset("assets/icons/settingIcon.png"),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => SettingUser()));
                                  // print(feedProvider.listFeedsFrP[5].sourceUserId);
                                }),
                            Divider(height: 60, color: Colors.black),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(children: [
                                  Text("Bạn bè", style: AppStyles.h4),
                                  Text(
                                      (userProvider.listFriendsP.length - 1)
                                          .toString(),
                                      style: AppStyles.h4)
                                ]),
                                Icon(Icons.search)
                              ],
                            ),
                            userProvider.userP.friend.length > 0
                                ? Material(
                                    child: GridView.count(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 4,
                                        mainAxisSpacing: 4,
                                        childAspectRatio: 4 / 5,
                                        physics:
                                            NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                                        shrinkWrap:
                                            true, // You won't see infinite size error
                                        children: frGirdView(
                                            userProvider.listFriendsP,
                                            userProvider.userP.friend)),
                                  )
                                : Container(),
                            IconButton(
                                icon: Image.asset(
                                    "assets/icons/allPeopleIcon.png"),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => AllFriendScreen(
                                              tag: false,
                                              user: userProvider.userP)));
                                  print(userProvider.listFriendsP);
                                  print("----xem tất cả bạn bè-----------");
                                }),
                            Divider(
                              height: 60,
                              color: Colors.black,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Đăng",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.sort_sharp)
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, right: 8.0),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 23,
                                      backgroundImage:
                                          AssetImage('assets/images/load.gif'),
                                      child: CircleAvatar(
                                        radius: 23,
                                        backgroundImage: NetworkImage(
                                            SERVER_IP +
                                                "/upload/" +
                                                userProvider.userP.avatarImg[
                                                    userProvider.userP.avatarImg
                                                            .length -
                                                        1]),
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      width: size.width - 150,
                                      child: InkWell(
                                          child: Text("Bạn đang nghĩ gì"),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (builder) =>
                                                        PostFeedScreen())).then(
                                                (value) => setState(() {}));
                                          }))
                                ],
                              ),
                            ),
                            Divider(
                              height: 40,
                              color: Colors.black,
                            ),
                            Container(
                              height: 40,
                              child: ListView(
                                physics: ClampingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8),
                                    child: Container(
                                      // color: Colors.lightBlue[100],
                                      decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(170, 10, 60, 0.3),
                                          border: Border.all(
                                            color: Color.fromRGBO(
                                                100, 200, 30, 0.3),
                                            width:
                                                1, //                   <--- border width here
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16))),
                                      child: TextButton.icon(
                                          style: ButtonStyle(
                                            fixedSize:
                                                MaterialStateProperty.all(
                                                    Size(120, 30)),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (builder) =>
                                                        All_Avatar_Screen(
                                                            user: userProvider
                                                                .userP,
                                                            type: "feed")));
                                          },
                                          icon: Image.asset(
                                              "assets/icons/imageIcon.png"),
                                          label: Text("Ảnh")),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(100, 200, 30, 0.3),
                                          border: Border.all(
                                            width:
                                                1, //                   <--- border width here
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16))),
                                      child: TextButton.icon(
                                          style: ButtonStyle(
                                            fixedSize:
                                                MaterialStateProperty.all(
                                                    Size(120, 30)),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (builder) =>
                                                        All_Avatar_Screen(
                                                            user: userProvider
                                                                .userP,
                                                            type: "avatar")));
                                          },
                                          icon: Image.asset(
                                              "assets/icons/imageIcon.png"),
                                          label: Text("Avatar")),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(500, 10, 60, 0.3),
                                          border: Border.all(
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16))),
                                      child: TextButton.icon(
                                          style: ButtonStyle(
                                            fixedSize:
                                                MaterialStateProperty.all(
                                                    Size(120, 30)),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (builder) =>
                                                        All_Avatar_Screen(
                                                            user: userProvider
                                                                .userP,
                                                            type: "cover")));
                                          },
                                          icon: Image.asset(
                                              "assets/icons/imageIcon.png"),
                                          label: Text("Ảnh bìa")),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return index % 2 == 0
                      ? Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: CardFeedStyle(
                            feed: feedProvider.listFeedsP[index - 4],
                            ownFeedUser: userProvider.userP,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: CardFeedStyle(
                            feed: feedProvider.listFeedsP[index - 4],
                            ownFeedUser: userProvider.userP,
                          ),
                        );
                })),
      ),
    );
  }

  //.....................pop image gely-----------

  //
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

  var urlLogout = Uri.parse(SERVER_IP + '/auth/logout');
//-------logout----------------------------------------
  Future<String> logoutFunction(String token) async {
    http.Response response;
    response = await http.post(urlLogout,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"jwt": token}));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body).toString();
    } else {
      print("lỗi logout----");
      return "error";
    }

    //-------------------------------
  }
}

List<Widget> frGirdView(Map<String, UserModel> inforFr, List listFr) {
  List<Widget> list = [];
  if (inforFr.length == 0) {
  } else {
    int pop = inforFr.length < 6 ? listFr.length : 6;
    for (var i = 0; i < pop; i++) {
      list.add(AvatarFriendBtn(
        id: inforFr[listFr[i]]!.id,
        frName: inforFr[listFr[i]]!.realName,
        frImage: inforFr[listFr[i]]!.avatarImg.length > 0
            ? inforFr[listFr[i]]!.avatarImg[0]!
            : "avatarNull.jpg",
      ));
    }
  }

  return list;
}
