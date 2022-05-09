import 'dart:convert';
import 'dart:io';

import 'package:app1/chat-app/customs/OwnFile_card.dart';
import 'package:app1/chat-app/customs/OwnMessageCard.dart';
import 'package:app1/chat-app/customs/ReplyFile_card.dart';
import 'package:app1/chat-app/customs/ReplyMessageCard.dart';
import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:app1/chat-app/model/message_model.dart';
import 'package:app1/chat-app/screens_chat/CameraScreen.dart';
import 'package:app1/chat-app/screens_chat/CameraView.dart';
import 'package:app1/feed/model/comment_model.dart';
import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/feed/screen/like_screen.dart';
import 'package:app1/main.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/comment_provider.dart';
import 'package:app1/provider/feed_provider.dart';
import 'package:app1/provider/message_provider.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:app1/ui.dart';
import 'package:app1/widgets/dismit_keybord.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({Key? key, required this.feed}) : super(key: key);

  final FeedBaseModel feed;
  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerModal = TextEditingController();
  late Socket socket;
  bool isEmojiShowing = false;
  FocusNode focusNode = FocusNode();

  final ImagePicker _picker = ImagePicker();
  bool isSendBtn = false;

  int popTime = 0;
  ScrollController _scrollController = ScrollController();

  List<CommentFullModel> fullComment = [];
  //.......................................................
  void connect() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final commentProvider =
        Provider.of<CommentProvider>(context, listen: false);

    print("begin connect....................");
    socket = io(SERVER_IP, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();
    print(socket.connected);
    print(widget.feed.feedId);
    socket.emit("signin", userProvider.userP.id);
  }

  @override
  void dispose() {
    print("dispose      chạy");
    super.dispose();
    // socket.disconnect();
    // _scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();

    //tắt emoji khi nhập text
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        if (mounted)
          setState(() {
            isEmojiShowing = false;
          });
      }
    });
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset == 0) {
          print("bằng");
          Navigator.pop(context);
        }
        print("offset = ${_scrollController.offset}");
      });

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      final commentProvider =
          Provider.of<CommentProvider>(context, listen: false);

      List<String> idComment = [];
      List<UserModel> users = [];
      List<CommentBaseModel> comments = [];
      var result = await Future.wait([
        getApi(userProvider.jwtP, "/feed/" + widget.feed.feedId),
      ]);
      if (result[0] != "not jwt" && result[0] != "error") {
        print(result[0]);
        if (result[0]["comment"].length > 0) {
          for (int i = 0; i < result[0]["comment"].length; i++) {
            print("kêt quả comment");
            print(result[0]["comment"][i]["messages"]);
            CommentBaseModel comment = CommentBaseModel(
                pathImg: result[0]["comment"][i]["pathImg"],
                messages: result[0]["comment"][i]["messages"],
                sourceUserId: result[0]["comment"][i]["sourceUserId"],
                createdAt: result[0]["comment"][i]["createdAt"]);
            comments.add(comment);
          }
        }
        for (int i = 0; i < result[0]["comment"].length; i++) {
          if (idComment.indexOf(result[0]["comment"][i]["sourceUserId"]) ==
              -1) {
            idComment.add(result[0]["comment"][i]["sourceUserId"]);
          }
        }
      }
      var resultApiUser = await Future.wait([
        PostApi(userProvider.jwtP, {"listUser": idComment}, "/user/listUser")
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
                feedImg: [],
                feedVideo: [],
                coverImg: [],
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
      for (int i = 0; i < comments.length; i++) {
        print("Test index");
        for (int j = 0; j < users.length; j++) {
          if (comments[i].sourceUserId == users[j].id) {
            print("bằng ");
            print(users[j].id);
            CommentFullModel cmt = CommentFullModel(
                comment: comments[i],
                avatarImg: users[j].avatarImg[users[j].avatarImg.length - 1],
                realName: users[j].realName);
            fullComment.add(cmt);
          }
        }
      }
      commentProvider.listCommentP[widget.feed.feedId] = fullComment;

      if (mounted) {
        setState(() {});
      }
    });
    connect();
  }

  ///////////--------------------------------gửi bfinh luân--------------
  _sendCmt(userProvider, fullComment, text, commentProvider) async {
    var result = await PostApi(
        userProvider.jwtP,
        {
          "pathImg": "",
          "messages": _controller.text,
          "sourceUserId": userProvider.userP.id,
          "createdAt": DateTime.now().toString(),
          "sourceUserName": userProvider.userP.userName,
        },
        "/feed/" + widget.feed.feedId + "/comment");
    if (result == "done") {
      CommentBaseModel newCmt = CommentBaseModel(
        pathImg: "",
        messages: text,
        sourceUserId: userProvider.userP.id,
        createdAt: DateTime.now().toString(),
      );

      fullComment.add(CommentFullModel(
          comment: newCmt,
          realName: userProvider.userP.realName,
          avatarImg: userProvider.userP.avatarImg.length > 0
              ? userProvider
                  .userP.avatarImg[userProvider.userP.avatarImg.length - 1]
              : "avatarNull"));
      commentProvider.listCommentP[widget.feed.feedId] = fullComment;
      if (mounted) {
        _controller.clear();
      }

      if (mounted)
        setState(() {
          isSendBtn = false;
        });
    }
  }

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

  //gửi hình ảnh................................
  void onImageSend(String path, String jwt, String feedId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    print("---------------bình luận bằng ảnh.............${path}");
    var request = http.MultipartRequest(
      "POST",
      Uri.parse(SERVER_IP + "/file/img/upload"),
    );
    request.fields["eventChangeImgUser"] = "comment";
    request.fields["feedId"] = feedId;
    request.fields["createdAt"] = DateTime.now().toString();

    request.headers.addAll(
        {"Content-type": "multipart/form-data", "cookie": "jwt=" + jwt});
    request.files.add(await http.MultipartFile.fromPath("img", path));

    http.StreamedResponse response = await request.send();
    var httpResponse = await http.Response.fromStream(response);
    if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
      var data = json.decode(httpResponse.body).toString();
      print("kết quả khi conment bằng ảnh ");
      print(data);
      for (var i = 0; i < popTime; i++) {
        if (mounted) Navigator.pop(context);
      }

      if (mounted)
        setState(() {
          CommentBaseModel newCmt = CommentBaseModel(
            pathImg: data,
            messages: "",
            sourceUserId: userProvider.userP.id,
            createdAt: DateTime.now().toString(),
          );

          fullComment.add(CommentFullModel(
              comment: newCmt,
              realName: userProvider.userP.realName,
              avatarImg: userProvider.userP.avatarImg.length > 0
                  ? userProvider
                      .userP.avatarImg[userProvider.userP.avatarImg.length - 1]
                  : "avatarNull"));

          popTime = 0;
        });
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Map<String, List<CommentFullModel>> comments = {};
    return Consumer<CommentProvider>(
        builder: (context, commentProvider, child) {
      comments = commentProvider.listCommentP;
      if (comments[widget.feed.feedId] != null) {
        comments[widget.feed.feedId]!
            .sort((a, b) => a.comment.createdAt.compareTo(b.comment.createdAt));
        fullComment == comments[widget.feed.feedId];
      }

      return DismissKeyboard(
        child: Stack(children: [
          Scaffold(
              appBar: AppBar(),
              backgroundColor: Colors.white,
              body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: WillPopScope(
                  child: Column(
                    children: [
                      Expanded(
                          child: ListView.builder(
                              controller: _scrollController,
                              itemCount: fullComment.length + 2,
                              itemBuilder: (context, index) {
                                if (index == fullComment.length + 1) {
                                  if (fullComment.length == 0) {
                                    return Text("Hãy bình luận đầu tiên!");
                                  } else {
                                    return Container();
                                  }
                                }
                                if (index == 0) {
                                  return Material(
                                    child: InkWell(
                                      onTap: () async {
                                        print("---ấn vào like--");
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    LikeScreen(
                                                        feed: widget.feed)));
                                      },
                                      child: Column(
                                        children: [
                                          SizedBox(
                                              height: 50,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      "   " +
                                                          widget
                                                              .feed.like.length
                                                              .toString() +
                                                          " người thích ",
                                                      style: AppStyles.h4),
                                                  IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(Icons.ac_unit))
                                                ],
                                              )),
                                          Divider(
                                            indent: 32,
                                            endIndent: 16,
                                            thickness: 3,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                if (fullComment[index - 1].comment.pathImg ==
                                    "") {
                                  return Column(
                                    children: [
                                      Container(
                                        color: Colors.orange[100],
                                        child: ListTile(
                                          onTap: () {
                                            showModalBottomSheet<String>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  height: 400,
                                                  child: Center(
                                                    child: Column(
                                                      // crossAxisAlignment:
                                                      //     CrossAxisAlignment.center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        TextField(
                                                            controller:
                                                                _controllerModal,
                                                            decoration:
                                                                InputDecoration(
                                                              hintText: "nhập",
                                                            )),
                                                        SizedBox(),
                                                        Material(
                                                          child: InkWell(
                                                              onTap: () async {
                                                                var result =
                                                                    await PutApi(
                                                                        userProvider
                                                                            .jwtP,
                                                                        {
                                                                          "baseCommentDto":
                                                                              {
                                                                            "pathImg":
                                                                                "",
                                                                            "messages":
                                                                                fullComment[index - 1].comment.messages,
                                                                            "sourceUserId":
                                                                                userProvider.userP.id,
                                                                            "createdAt":
                                                                                fullComment[index - 1].comment.createdAt,
                                                                          },
                                                                          "newMessage":
                                                                              _controllerModal.text,
                                                                          "newPathImg":
                                                                              ""
                                                                        },
                                                                        "/feed/" +
                                                                            widget.feed.feedId +
                                                                            "/comment");
                                                                print(
                                                                    "kết quả trả về khi put");
                                                                print(result);
                                                                if (result ==
                                                                    "done") {
                                                                  fullComment[index -
                                                                              1]
                                                                          .comment
                                                                          .messages ==
                                                                      _controllerModal
                                                                          .text;
                                                                  if (mounted) {
                                                                    //nguyên nhân chưa đổi vì set state của bottom chứ k phải của màn hình ,
                                                                    // phải pop về rồi set hoặc dùng provider
                                                                    setState(
                                                                        () {});
                                                                  }
                                                                }
                                                              },
                                                              child: Text(
                                                                  "Sửa bình luận")),
                                                        ),
                                                        SizedBox(),
                                                        Material(
                                                          child: InkWell(
                                                              onTap: () async {
                                                                var result =
                                                                    await DeleteApi(
                                                                        userProvider
                                                                            .jwtP,
                                                                        {
                                                                          "pathImg":
                                                                              "",
                                                                          "messages": fullComment[index - 1]
                                                                              .comment
                                                                              .messages,
                                                                          "sourceUserId": userProvider
                                                                              .userP
                                                                              .id,
                                                                          "createdAt": fullComment[index - 1]
                                                                              .comment
                                                                              .createdAt,
                                                                        },
                                                                        "/feed/" +
                                                                            widget.feed.feedId +
                                                                            "/comment");
                                                                print(
                                                                    "kết quả trả về khi put");
                                                                print(result);
                                                              },
                                                              child: Text(
                                                                  "Xóa bình luận")),
                                                        ),
                                                        SizedBox(),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                            print(fullComment.length);
                                            print(index.toString());
                                          },
                                          hoverColor: Colors.blue,
                                          leading: InkWell(
                                            onTap: () {
                                              print("ấn vào avatar");
                                            },
                                            child: CircleAvatar(
                                              radius: 30,
                                              child: CircleAvatar(
                                                radius: 30,
                                                backgroundImage: NetworkImage(
                                                    SERVER_IP +
                                                        "/upload/" +
                                                        fullComment[index - 1]
                                                            .avatarImg),
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                              fullComment[index - 1].realName,
                                              style: AppStyles.h4.copyWith(
                                                  color: Colors.lightBlue,
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Text(fullComment[index - 1]
                                              .comment
                                              .messages),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  );
                                } else {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              SERVER_IP +
                                                  "/upload/" +
                                                  fullComment[index - 1]
                                                      .avatarImg),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(fullComment[index - 1]
                                                .realName),
                                          ),
                                          ReplyFileCard(
                                              path: fullComment[index - 1]
                                                  .comment
                                                  .pathImg),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                              })),
                      //tin nhắn..............................................
                      //put text............................................
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 70,
                              child: Row(
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width -
                                          57,
                                      child: Card(
                                          margin: const EdgeInsets.only(
                                              left: 2, right: 2, bottom: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25)),
                                          //input text...........................................
                                          child: TextField(
                                            focusNode: focusNode,
                                            controller: _controller,
                                            onChanged: (value) {
                                              if (value.length > 0) {
                                                if (mounted)
                                                  setState(() {
                                                    isSendBtn = true;
                                                  });
                                              } else {
                                                if (mounted)
                                                  setState(() {
                                                    isSendBtn = false;
                                                  });
                                              }
                                            },
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: 5,
                                            minLines: 1,
                                            decoration: InputDecoration(
                                              hintText: "Nhập ... ",
                                              border: InputBorder.none,
                                              prefixIcon: IconButton(
                                                icon:
                                                    Icon(Icons.emoji_emotions),
                                                onPressed: () {
                                                  if (mounted)
                                                    setState(() {
                                                      focusNode.unfocus();
                                                      focusNode
                                                              .canRequestFocus =
                                                          false;
                                                      isEmojiShowing =
                                                          !isEmojiShowing;
                                                    });
                                                },
                                              ),
                                              suffixIcon: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                          Icons.camera_alt),
                                                      onPressed: () {
                                                        if (mounted)
                                                          setState(() {
                                                            popTime = 2;
                                                          });
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (builder) =>
                                                                        CameraScreen(
                                                                          targetId:
                                                                              "",
                                                                          event:
                                                                              "comment",
                                                                          onImageSend:
                                                                              onImageSend,
                                                                        )));
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                          Icons.attach_file),
                                                      onPressed: () {
                                                        showModalBottomSheet(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            context: context,
                                                            builder: (builder) =>
                                                                bottomSheet());
                                                      },
                                                    ),
                                                  ]),
                                              contentPadding: EdgeInsets.all(5),
                                            ),
                                          ))),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0, left: 2, right: 2),
                                    child: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.blueGrey,
                                        child: IconButton(
                                          icon: isSendBtn
                                              ? Image.asset(
                                                  "assets/icons/sendIcon.png",
                                                  height: 40)
                                              : Image.asset(
                                                  "assets/icons/notSendIcon.png",
                                                  height: 40),
                                          onPressed: isSendBtn
                                              ? () async {
                                                  setState(() {
                                                    isSendBtn = false;
                                                  });
                                                  await _sendCmt(
                                                      userProvider,
                                                      fullComment,
                                                      _controller.text,
                                                      commentProvider);

                                                  if (mounted) {
                                                    _scrollController.animateTo(
                                                        _scrollController
                                                            .position
                                                            .maxScrollExtent,
                                                        duration: Duration(
                                                            milliseconds: 100),
                                                        curve: Curves.easeOut);
                                                    setState(() {
                                                      isSendBtn = true;
                                                    });
                                                  }
                                                }
                                              : null,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            //emoji................................................
                            Offstage(
                              offstage: !isEmojiShowing,
                              child: SizedBox(
                                height: 250,
                                child: EmojiPicker(
                                    onEmojiSelected:
                                        (Category category, Emoji emoji) {
                                      _onEmojiSelected(emoji);
                                    },
                                    onBackspacePressed: _onBackspacePressed,
                                    config: Config(
                                        columns: 7,
                                        emojiSizeMax:
                                            24 * (Platform.isIOS ? 1.30 : 1.0),
                                        verticalSpacing: 0,
                                        horizontalSpacing: 0,
                                        initCategory: Category.RECENT,
                                        bgColor: const Color(0xFFF2F2F2),
                                        indicatorColor: Colors.blue,
                                        iconColor: Colors.grey,
                                        iconColorSelected: Colors.blue,
                                        progressIndicatorColor: Colors.blue,
                                        backspaceColor: Colors.blue,
                                        showRecentsTab: true,
                                        recentsLimit: 28,
                                        noRecentsText: 'No Recents',
                                        noRecentsStyle: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black26),
                                        tabIndicatorAnimDuration:
                                            kTabScrollDuration,
                                        categoryIcons: const CategoryIcons(),
                                        buttonMode: ButtonMode.MATERIAL)),
                              ),
                            ),
                          ],
                        ),
                      ),
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
              )),
        ]),
      );
    });
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
                  iconcreation(
                    Icons.insert_drive_file,
                    Colors.indigo,
                    "Document",
                    () {},
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.camera_alt,
                    Colors.pink,
                    "Camera",
                    () {
                      if (mounted)
                        setState(() {
                          popTime = 3;
                        });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => CameraScreen(
                                    targetId: "",
                                    event: "comment",
                                    onImageSend: onImageSend,
                                  )));
                    },
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  iconcreation(
                    Icons.insert_photo,
                    Colors.purple,
                    "Gallary",
                    () async {
                      if (mounted)
                        setState(() {
                          popTime = 2;
                        });
                      print(
                          "chuyen sang camera................................");
                      final XFile? file =
                          await _picker.pickImage(source: ImageSource.gallery);
                      file != null
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => CameraViewPage(
                                        targetId: "",
                                        path: file.path,
                                        event: "comment",
                                        feedId: widget.feed.feedId,
                                        onImageSend: onImageSend,
                                      )))
                          : print("chọn file");
                    },
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 20, bottom: 10),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  iconcreation(
                    Icons.headset,
                    Colors.orange,
                    "Audio",
                    () {},
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

  ///
  ///

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

////
Future PostApi(String jwt, data, String pathApi) async {
  http.Response response;
  print("post---------" + pathApi);
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

//
Future PutApi(String jwt, data, String pathApi) async {
  http.Response response;
  print("put---------" + pathApi);
  response = await http.put(Uri.parse(SERVER_IP + pathApi),
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
  print("delete---------" + pathApi);
  response = await http.delete(Uri.parse(SERVER_IP + pathApi),
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
