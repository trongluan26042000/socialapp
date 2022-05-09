import 'dart:convert';
import 'dart:io';

import 'package:app1/user/screen/All_Fr_Screen.dart';
import 'package:app1/Screen/HomeScreen.dart';
import 'package:app1/chat-app/customs/OwnFile_card.dart';
import 'package:app1/chat-app/customs/OwnMessageCard.dart';
import 'package:app1/chat-app/customs/ReplyFile_card.dart';
import 'package:app1/chat-app/customs/ReplyMessageCard.dart';
import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:app1/chat-app/model/message_model.dart';
import 'package:app1/chat-app/screens_chat/CameraScreen.dart';
import 'package:app1/chat-app/screens_chat/CameraView.dart';
import 'package:app1/chat-app/screens_chat/VideoView.dart';
import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/main.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/feed_provider.dart';
import 'package:app1/provider/message_provider.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:app1/widgets/dismit_keybord.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:video_player/video_player.dart';

class PostFeedScreen extends StatefulWidget {
  const PostFeedScreen({
    Key? key,
  }) : super(key: key);

  @override
  _PostFeedScreenState createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends State<PostFeedScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isEmojiShowing = false;
  bool isVisible = false;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  bool checkTag = true;
  String photopath = "";
  FocusNode focusNode = FocusNode();
  late Socket socket;
  final ImagePicker _picker = ImagePicker();
  //late final fileImage;
  List listIdTag = [];
  List listRealNameTag = [];
  List<XFile> listFileImage = [];
  List<XFile> listFileVideo = [];
  late VideoPlayerController _videoPlayerController;
  bool isSendBtn = false;
  int dem = 0;
  List<MessageModel> messages = [];
  ScrollController _scrollController = ScrollController();
  bool tag = false;
  int popTime = 0;
  bool isSendApi = false;
  String rule = "every";
  //.......................................................
  @override
  void initState() {
    super.initState();
    isSendApi = false;
    //tắt emoji khi nhập text
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        if (mounted)
          setState(() {
            isEmojiShowing = false;
          });
      }
    });
  }

  late Future<void> _initializeVideoPlayerFuture;

  _onEmojiSelected(Emoji emoji) {
    // setState(() {
    //   _controller.text = _controller.text + emoji.emoji;
    // });
    if (mounted) {
      _controller
        ..text += emoji.emoji
        ..selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length));
    }
  }

  _onBackspacePressed() {
    if (mounted) {
      _controller
        ..text = _controller.text.characters.skipLast(1).toString()
        ..selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<XFile> listFileAll = [];
    if (listFileImage.length > 0) {
      listFileAll = listFileImage;
    } else {
      listFileAll = listFileVideo;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    var urlPostFeed = Uri.parse(SERVER_IP + '/feed');
    Size size = MediaQuery.of(context).size;

    Future<String> PostFeedFunction(FeedBaseModel feed) async {
      print("chạy funcin");
      http.Response response;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      response = await http.post(urlPostFeed,
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            'cookie': "jwt=" + userProvider.jwtP,
          },
          body: jsonEncode({
            "sourceUserId": feed.sourceUserId,
            "sourceUserName": feed.sourceUserName,
            "pathImg": feed.pathImg,
            "pathVideo": feed.pathVideo,
            "messages": feed.message,
            "rule": feed.rule,
            "tag": feed.tag,
            "createdAt": feed.createdAt,
          }));
      print(json.decode(response.body).toString());
      return json.decode(response.body).toString();
    }

    return DismissKeyboard(
      child: Stack(children: [
        Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: AppBar(
                backgroundColor: Colors.pinkAccent,
                title: Text("Tạo bài viêt"),
                leadingWidth: 60,
                titleSpacing: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 22, right: 12),
                  child: InkWell(
                      onTap: () async {
                        print("oki");
                        focusNode.unfocus();
                        if (!focusNode.hasFocus) {
                          Navigator.of(context).pop(true);
                        }

                        //
                      },
                      child: Icon(Icons.arrow_back, size: 24)),
                ),
                actions: [
                  // nút đăng  hiển thị ở trên appbar ............................
                  (_controller.text.length > 0 == true ||
                          dem >
                              0) // kiểm tra có chữ hoặc có ảnh chưa để có thể ấn nút đăng
                      ? RoundedLoadingButton(
                          width: 50,
                          controller: _btnController,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, right: 5, left: 5),
                            child: Text(
                              "ĐĂNG",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87),
                            ),
                          ),
                          onPressed: !isSendApi
                              ? () async {
                                  setState(() {
                                    isSendApi = true;
                                  });
                                  print("list tag là");
                                  print(listIdTag);
                                  List<String> listPathSv = [];
                                  print(listFileImage);
                                  if (listFileImage != null) {
                                    if (listFileImage.length > 0) {
                                      listPathSv = await onImageSend(
                                          listFileImage, userProvider.jwtP);
                                    }
                                  }
                                  if (listFileVideo.length > 0) {
                                    listPathSv = await onImageSend(
                                        listFileVideo, userProvider.jwtP);
                                  }
                                  print("listPathSv: ");
                                  print(listPathSv);
                                  print(_controller.text);
                                  FeedBaseModel feed = new FeedBaseModel(
                                      like: [],
                                      rule: [rule],
                                      comment: [],
                                      pathVideo: listFileVideo.length > 0
                                          ? listPathSv
                                          : [],
                                      tag: listIdTag,
                                      pathImg: listFileImage.length > 0
                                          ? listPathSv
                                          : [],
                                      createdAt: DateTime.now().toString(),
                                      sourceUserId: userProvider.userP.id,
                                      message: _controller.text,
                                      sourceUserName:
                                          userProvider.userP.userName);
                                  print('ND : ' + _controller.text);
                                  String newIdFeed =
                                      await PostFeedFunction(feed);
                                  if (newIdFeed == "not jwt") {
                                    print(newIdFeed);
                                  } else {
                                    if (newIdFeed != "error") {
                                      FeedBaseModel a = new FeedBaseModel(
                                          like: [],
                                          rule: [rule],
                                          comment: [],
                                          tag: listIdTag,
                                          pathVideo: listFileVideo.length > 0
                                              ? listPathSv
                                              : [],
                                          pathImg: listFileVideo.length == 0
                                              ? listPathSv
                                              : [],
                                          feedId: newIdFeed,
                                          createdAt: DateTime.now().toString(),
                                          sourceUserId: userProvider.userP.id,
                                          message: _controller.text,
                                          sourceUserName:
                                              userProvider.userP.userName);
                                      List<FeedBaseModel> b =
                                          feedProvider.listFeedsP;
                                      b.insert(0, a);
                                      print("đã tạo mới bài viết rồi!");
                                      feedProvider.userFeed(b);
                                      Navigator.pop(context);
                                    }
                                  }
                                  _btnController.success();
                                  CoolAlert.show(
                                    context: context,
                                    type: CoolAlertType.success,
                                    text: "Tạo mới thành công !",
                                  );
                                  setState(() {
                                    isSendApi = false;
                                    for (var i = 0; i < listIdTag.length; i++) {
                                      print("Người thứ " + i.toString());
                                      print(listRealNameTag[i]);
                                    }
                                  });
                                }
                              : null,
                        )
                      : InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, right: 5, left: 5),
                            child: Text(
                              "ĐĂNG",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black12),
                            ),
                          ),
                          onTap: null,
                        ),
                  PopupMenuButton<String>(onSelected: (value) {
                    print(value);
                  }, itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                          child: Text("View Contact"), value: "View Contact"),
                      PopupMenuItem(
                          child: Text("Media,Link"), value: "Media,Link"),
                      PopupMenuItem(
                          child: Text("Whatsapp Wed"), value: "Whatsapp Wed"),
                      PopupMenuItem(child: Text("Search"), value: "Search"),
                      PopupMenuItem(
                          child: Text("WallPaper"), value: "WallPaper"),
                      PopupMenuItem(
                          child: Text("Not notification"),
                          value: "Not notification"),
                    ];
                  })
                ],
              ),
            ),
            body: SingleChildScrollView(
              //reverse: true,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: WillPopScope(
                  child: Column(
                    children: [
                      //Avatar.............................................
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 2, 8, 8),
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
                                    // child: Container(
                                    //   width: 48,
                                    //   height: 48,
                                    //     child: Image.asset('assets/images/nature1.jpg',),
                                    // ),
                                  ), // Ảnh người cmt

                                  Column(
                                    //mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Tên cá nhân
                                      (tag)
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 2),
                                                      child: Text(
                                                        userProvider
                                                            .userP.realName,
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        " cùng với - ",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.black54),
                                                      ),
                                                    ),
                                                    Text(
                                                      listRealNameTag[0],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  ],
                                                ),
                                                (listRealNameTag.length > 1)
                                                    ? Text(
                                                        listRealNameTag[1],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color:
                                                                Colors.black87),
                                                      )
                                                    : Container(),
                                                (listRealNameTag.length > 2)
                                                    ? Text(
                                                        "và " +
                                                            (listRealNameTag
                                                                        .length -
                                                                    2)
                                                                .toString() +
                                                            " người khác",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color:
                                                                Colors.black87),
                                                      )
                                                    : Container()
                                              ],
                                            )
                                          : Container(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 2),
                                                child: Text(
                                                  userProvider.userP.realName,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.black54),
                                                ),
                                              ),
                                            ),
                                      //cột chọn chế độ
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Row(
                                            children: [
                                              // ví dụ sẵn chọn chế độ một mình
                                              InkWell(
                                                onTap: () async {
                                                  await showModalBottomSheet<
                                                          String>(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return Container(
                                                            height: 300,
                                                            child: Column(
                                                                children: [
                                                                  Expanded(
                                                                      child: Container(
                                                                          child:
                                                                              Text(""))),
                                                                  Expanded(
                                                                      child: InkWell(
                                                                          onTap: () async {
                                                                            print(rule);
                                                                            print("Tất cả mọi người");
                                                                            setState(() {});

                                                                            Navigator.pop(context,
                                                                                rule = "every");
                                                                          },
                                                                          child: Text("Tất cả mọi người", textAlign: TextAlign.center))),
                                                                  Expanded(
                                                                      child: InkWell(
                                                                          onTap: () async {
                                                                            print("Bạn bè");
                                                                            setState(() {});
                                                                            Navigator.pop(context,
                                                                                rule = "friend");
                                                                          },
                                                                          child: Text("Bạn bè", textAlign: TextAlign.center))),
                                                                  Expanded(
                                                                      child: InkWell(
                                                                          onTap: () async {
                                                                            print("Chỉ mình tôi");
                                                                            setState(() {});

                                                                            Navigator.pop(context,
                                                                                rule = "only me");
                                                                          },
                                                                          child: Text("Chỉ mình tôi", textAlign: TextAlign.center))),
                                                                ]));
                                                      });
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.lock,
                                                        size: 20,
                                                        color: Colors
                                                            .black87), // icon ổ khóa
                                                    Text(
                                                      rule,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff7c94b6),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      //put text............................................
                      //Khung status
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, top: 8, right: 8, bottom: 8),
                        child: Container(
                          color: Colors.black12,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: _controller,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 8,
                                  decoration: InputDecoration.collapsed(
                                    hintText: "Bạn đang nghĩ gì?",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // góc test hiển thị ảnh ...............
                      if (listFileImage.length == 0 &&
                          listFileVideo.length == 0)
                        SizedBox()
                      else
                        Expanded(
                          flex: 1,
                          child: GridView.builder(
                              itemCount: listFileAll.length,
                              itemBuilder: (listViewContext, index) => Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Container(
                                      child:

                                          /// Điều kiện hiển thị ảnh
                                          (listFileAll[index].path.substring(
                                                          listFileAll[index]
                                                                  .path
                                                                  .length -
                                                              3,
                                                          listFileAll[index]
                                                              .path
                                                              .length) ==
                                                      "png" ||
                                                  listFileAll[index]
                                                          .path
                                                          .substring(
                                                              listFileAll[index]
                                                                      .path
                                                                      .length -
                                                                  3,
                                                              listFileAll[index]
                                                                  .path
                                                                  .length) ==
                                                      "jpg" ||
                                                  listFileAll[index]
                                                          .path
                                                          .substring(
                                                              listFileAll[index]
                                                                      .path
                                                                      .length -
                                                                  3,
                                                              listFileAll[index]
                                                                  .path
                                                                  .length) ==
                                                      "gif")
                                              ? Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    Image.file(
                                                      File(listFileImage[index]
                                                          .path),
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Positioned(
                                                      right: 0,
                                                      top: 0,
                                                      child: Container(
                                                        color: Color.fromRGBO(
                                                            255, 255, 255, 0.4),
                                                        child: IconButton(
                                                          onPressed: () async {
                                                            print(
                                                                listFileVideo);
                                                            if (listFileImage
                                                                    .length >
                                                                0) {
                                                              listFileImage
                                                                  .removeAt(
                                                                      index);
                                                            } else {
                                                              listFileVideo
                                                                  .removeAt(
                                                                      index);
                                                            }

                                                            setState(() {
                                                              dem--;
                                                            });
                                                          },
                                                          icon: Icon(
                                                              Icons.delete),
                                                        ),
                                                      ),
                                                    ) //position
                                                  ],
                                                )

                                              /// hiển thị video
                                              : Container(
                                                  child: Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      VideoPlayer(
                                                          _videoPlayerController),
                                                      Positioned(
                                                        top: 0,
                                                        bottom: 0,
                                                        left: 0,
                                                        right: 0,
                                                        child: Container(
                                                          color: Color.fromRGBO(
                                                              255,
                                                              255,
                                                              255,
                                                              0.4),
                                                          child: IconButton(
                                                            onPressed:
                                                                () async {},
                                                            icon: Icon(Icons
                                                                .play_circle_fill_outlined),
                                                          ),
                                                        ),
                                                      ), //position hiển thi icon video
                                                      Positioned(
                                                        right: 0,
                                                        top: 0,
                                                        child: Container(
                                                          color: Color.fromRGBO(
                                                              255,
                                                              255,
                                                              255,
                                                              0.4),
                                                          child: IconButton(
                                                            onPressed:
                                                                () async {
                                                              if (listFileImage
                                                                      .length >
                                                                  0) {
                                                                listFileImage
                                                                    .removeAt(
                                                                        index);
                                                              } else {
                                                                listFileVideo
                                                                    .removeAt(
                                                                        index);
                                                              }

                                                              setState(() {
                                                                dem--;
                                                              });
                                                            },
                                                            icon: Icon(
                                                                Icons.delete),
                                                          ),
                                                        ),
                                                      ), //position nút xóa
                                                    ],
                                                  ),
                                                ),
                                    ),
                                  ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4)),
                        ),

                      //các tiện ích
                      Expanded(
                        flex: 3,
                        child: ListView(
                          children: [
                            // Thêm ảnh
                            FlatButton(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 4, bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      color: Colors.green,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        "Ảnh/Video",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (builder) => bottomSheet());
                              },
                            ),

                            // Gắn thẻ
                            // Gắn thẻ
                            FlatButton(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 4, bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_add_alt_1_outlined,
                                      color: Colors.pink,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        "Gắn thẻ bạn bè",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: () {
                                print("heyy");

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => AllFriendScreen(
                                              tag: true,
                                              user: userProvider.userP,
                                              onGetTag: (List listId,
                                                  List listRealName) {
                                                listIdTag = listId;

                                                listRealNameTag = listRealName;
                                                if (listIdTag.length > 0) {
                                                  tag = true;
                                                }
                                                setState(() {});
                                                print("hihi");
                                              },
                                            )));

                                print(userProvider.listFriendsP);
                                print("----xem tất cả bạn bè-----------");
                              },
                            ),

                            // Thêm vị trí
                          ],
                        ),
                      ),

                      // Nút đăng ở dưới cùng có hoặc không ...................................
                      // Container(
                      //   width: size.width,
                      //   height: 40,
                      //   color: Colors.green,
                      //   child: InkWell(
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: Text(
                      //         "ĐĂNG",
                      //         textAlign: TextAlign.center,
                      //         style: TextStyle(
                      //             fontSize: 18,
                      //             fontWeight: FontWeight.w800,
                      //             color: Colors.black87),
                      //       ),
                      //     ),
                      //     onTap: () async {
                      //       print(_controller.text);
                      //       FeedBaseModel feed = new FeedBaseModel(
                      //           like: [],
                      //           rule: [],
                      //           comment: [],
                      //           pathImg: [],
                      //           createdAt: DateTime.now().toString(),
                      //           sourceUserId: userProvider.userP.id,
                      //           message: _controller.text,
                      //           sourceUserName: userProvider.userP.userName);
                      //       print('ND : ' + _controller.text);
                      //       String newIdFeed = await PostFeedFunction(feed);
                      //       if (newIdFeed == "not jwt") {
                      //         print(newIdFeed);
                      //       } else {
                      //         if (newIdFeed != "error") {
                      //           FeedBaseModel a = new FeedBaseModel(
                      //               like: [],
                      //               rule: [],
                      //               comment: [],
                      //               pathImg: [],
                      //               feedId: newIdFeed,
                      //               createdAt: DateTime.now().toString(),
                      //               sourceUserId: userProvider.userP.id,
                      //               message: _controller.text,
                      //               sourceUserName: userProvider.userP.userName);
                      //           List<FeedBaseModel> b = feedProvider.listFeedsP;
                      //           b.insert(0, a);
                      //           print("đã tạo mới bài viết rồi!");
                      //           feedProvider.userFeed(b);
                      //           Navigator.pop(context);
                      //         }
                      //       }
                      //     },
                      //   ),
                      // ),
                      // (_controller.text.length > 0 == true)
                      //     ? Container(
                      //   width: size.width,
                      //   height: 40,
                      //   color: Colors.green,
                      //   child: InkWell(
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: Text(
                      //         "ĐĂNG",
                      //         textAlign: TextAlign.center,
                      //         style: TextStyle(
                      //             fontSize: 18,
                      //             fontWeight: FontWeight.w800,
                      //             color: Colors.black87),
                      //       ),
                      //     ),
                      //     onTap: () async {
                      //       print(_controller.text);
                      //       FeedBaseModel feed = new FeedBaseModel(
                      //           like: [],
                      //           rule: [],
                      //           comment: [],
                      //           pathImg: [],
                      //           createdAt: DateTime.now().toString(),
                      //           sourceUserId: userProvider.userP.id,
                      //           message: _controller.text,
                      //           sourceUserName: userProvider.userP.userName);
                      //       print('ND : ' + _controller.text);
                      //       String newIdFeed = await PostFeedFunction(feed);
                      //       if (newIdFeed == "not jwt") {
                      //         print(newIdFeed);
                      //       } else {
                      //         if (newIdFeed != "error") {
                      //           FeedBaseModel a = new FeedBaseModel(
                      //               like: [],
                      //               rule: [],
                      //               comment: [],
                      //               pathImg: [],
                      //               feedId: newIdFeed,
                      //               createdAt: DateTime.now().toString(),
                      //               sourceUserId: userProvider.userP.id,
                      //               message: _controller.text,
                      //               sourceUserName: userProvider.userP.userName);
                      //           List<FeedBaseModel> b = feedProvider.listFeedsP;
                      //           b.insert(0, a);
                      //           print("đã tạo mới bài viết rồi!");
                      //           feedProvider.userFeed(b);
                      //           Navigator.pop(context);
                      //         }
                      //       }
                      //     },
                      //   ),
                      // )
                      //     :Container(
                      //   width: size.width,
                      //   height: 40,
                      //   color: Colors.greenAccent,
                      //   child: InkWell(
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: Text(
                      //         "ĐĂNG",
                      //         textAlign: TextAlign.center,
                      //         style: TextStyle(
                      //             fontSize: 18,
                      //             fontWeight: FontWeight.w800,
                      //             color: Colors.black87),
                      //       ),
                      //     ),
                      //     onTap: null
                      //   ),
                      // ),
                    ],
                  ),
                  //ấn quay lại thì kiểm tra xem có bật emoji k?
                  onWillPop: () {
                    if (isEmojiShowing) {
                      if (mounted)
                        setState(() {
                          isEmojiShowing = false;
                        });
                    } else {
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    }
                    return Future.value(false);
                  },
                ),
              ),
            )),
      ]),
    );
  }

  Widget bottomSheet() {
    return Container(
        height: 278,
        width: MediaQuery.of(context).size.width,
        child: Card(
          margin: EdgeInsets.all(18),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 20, bottom: 10),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.camera_alt,
                    Colors.pink,
                    "Camera",
                    dem < 7
                        ? () async {
                            if (mounted)
                              setState(() {
                                popTime = 3;
                              });
                            print("chup ảnh................................");
                            dem = 0;

                            final XFile? file = await _picker.pickImage(
                                source: ImageSource.camera);
                            if (file != null && dem < 20) {
                              listFileImage.add(file);
                              dem = dem + 1;
                              print("Đã chụp ảnh");
                              setState(() {});
                            }
                          }
                        : () {},
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.insert_photo,
                    Colors.purple,
                    "Gallary",
                    listFileVideo.length == 0 && dem < 7
                        ? () async {
                            if (mounted)
                              setState(() {
                                popTime = 2;
                              });
                            isVisible = true;

                            print(
                                "chuyen sang ảnh................................");
                            final List<XFile>? selectedFile =
                                await _picker.pickMultiImage();
                            if (selectedFile != null) {
                              if (selectedFile.isNotEmpty) {
                                listFileImage.addAll(selectedFile);
                                dem = listFileImage.length;
                                print("Số ảnh chọn là " + dem.toString());
                                setState(() {});
                              }
                            }
                          }
                        : () {},
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 20, bottom: 10),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  iconcreation(
                    Icons.ondemand_video,
                    Colors.orange,
                    "Video",
                    listFileImage.length == 0 && dem < 7
                        ? () async {
                            if (mounted)
                              setState(() {
                                popTime = 4;
                              });
                            print("Video................................");
                            final XFile? file = await _picker.pickVideo(
                                source: ImageSource.gallery);
                            //video = File(file.path);
                            //_videoPlayerController = VideoPlayerController.file(file.path);
                            if (file != null) {
                              listFileVideo.add(file);
                              print("1 video vừa được chọn ");
                              print(file.path);
                              setState(() {
                                dem = listFileVideo.length;
                                _videoPlayerController =
                                    VideoPlayerController.file(File(file.path));
                                _initializeVideoPlayerFuture =
                                    _videoPlayerController.initialize();
                              });
                            }
                          }
                        : () {},
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.location_pin,
                    Colors.pink,
                    "Location",
                    () {},
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.person,
                    Colors.blue,
                    "Contact",
                    () {},
                  )
                ]),
              )
            ],
          ),
        ));
  }

//widget
  Widget iconcreation(IconData icon, Color color, String text, Function onTap) {
    return InkWell(
      onTap: () => onTap(),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 30,
            child: Icon(
              icon,
              size: 29,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(text, style: TextStyle(fontSize: 12))
        ],
      ),
    );
  }
}

Future<List<String>> onImageSend(List<XFile> file, String jwt) async {
  List<String> result = [];
  var request = http.MultipartRequest(
    "POST",
    Uri.parse(SERVER_IP + "/file/uploadFiles"),
  );
  request.fields["eventChangeImgUser"] = "feed";

  request.headers
      .addAll({"Content-type": "multipart/form-data", "cookie": "jwt=" + jwt});

  for (int i = 0; i < file.length; i++) {
    request.files.add(await http.MultipartFile.fromPath("img", file[i].path));
  }

  http.StreamedResponse response = await request.send();
  var httpResponse = await http.Response.fromStream(response);
  if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
    var data = json.decode(httpResponse.body);
    print(data.length);
    if (data != "not jwt" && data != "error") {
      for (int i = 0; i < data.length; i++) {
        String pathAll = data[i].toString();
        String path = pathAll.substring(10);
        print(path);
        result.add(path);
      }
    }
  }
  return result;
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
