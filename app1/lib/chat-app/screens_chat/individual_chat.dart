import 'dart:convert';
import 'dart:io';
import 'package:adaptive_dialog/adaptive_dialog.dart';

import 'package:app1/chat-app/customs/OwnFile_card.dart';
import 'package:app1/chat-app/customs/OwnMessageCard.dart';
import 'package:app1/chat-app/customs/ReplyFile_card.dart';
import 'package:app1/chat-app/customs/ReplyMessageCard.dart';
import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:app1/chat-app/model/message_model.dart';
import 'package:app1/chat-app/screens_chat/CameraScreen.dart';
import 'package:app1/chat-app/screens_chat/CameraView.dart';
import 'package:app1/main.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/message_provider.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:app1/widgets/dismit_keybord.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class IndividualChat extends StatefulWidget {
  final ChatModel? chatModel;
  const IndividualChat({Key? key, this.chatModel, this.sourceChat})
      : super(key: key);
  final ChatModel? sourceChat;

  @override
  _IndividualChatState createState() => _IndividualChatState();
}

class _IndividualChatState extends State<IndividualChat> {
  final TextEditingController _controller = TextEditingController();
  bool isEmojiShowing = false;
  FocusNode focusNode = FocusNode();
  late Socket socket;
  final ImagePicker _picker = ImagePicker();
  bool isSendBtn = false;
  List<MessageModel> messages = [];
  ScrollController _scrollController = ScrollController();
  bool _IsLoading = false;
  int popTime = 0;
  //.......................................................
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
    connect();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // getMessageInit(userProvider.jwtP);
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    });
    _scrollController = ScrollController()
      ..addListener(() async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        List<MessageModel> newListMsg = [];
        if (_scrollController.offset == 0) {
          _IsLoading = true;
          int numberSource = 0;
          int numberTarget = 0;
          var maxTime;
          List<MessageModel> newListMsg = [];
          // print("bằng");
          // var result = await getApi(userProvider.jwtP, )
          for (int i = 0; i < messages.length; i++) {
            if (messages[i].sourceId == userProvider.userP.id) {
              numberSource++;
            } else {
              numberTarget++;
            }
          }
          print(numberSource);
          print(numberTarget);
          print(messages.length);

          var result = await Future.wait([
            getApi(
                userProvider.jwtP,
                "/message/msgLimit?limit=10&offsetUser=" +
                    numberSource.toString() +
                    "&offsetTarget=" +
                    numberTarget.toString() +
                    "&targetId=" +
                    widget.chatModel!.id),
          ]);

          if (result[0] != "not jwt" && result[0] != "error") {
            List msg =
                result[0][userProvider.userP.id + "/" + widget.chatModel!.id];
            for (int i = 0; i < msg.length; i++) {
              newListMsg.add(MessageModel(
                path: msg[i]["path"],
                time: msg[i]["time"],
                sourceId: msg[i]["sourceId"],
                targetId: msg[i]["targetId"],
                message: msg[i]["message"],
              ));
            }
            messages.addAll(newListMsg);
            messages.sort((a, b) => a.time.compareTo(b.time));
            if (mounted) {
              _IsLoading:
              false;
              setState(() {});
            }
          }
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
    });
  }

  //ham get api........................
  Future fetchData(String id1, String id2, String jwt) async {
    http.Response response;

    List<MessageModel> data1 = [];
    //tim tin nhan cua nguoi gui cho ban
    String query = '?limit=50&offset=0&sourceId=' + id1 + "&targetId=" + id2;
    String path = SERVER_IP + '/message/individual' + query;
    print(query);
    print(path);
    response = await http.get(
      Uri.parse(path),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'cookie': "jwt=" + jwt,
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else
      return [];
  }

  //lay tin nhan ban dau................

  //connect socket_io_client
  void connect() {
    print("begin connect....................");
    socket = io(SERVER_IP, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();

    socket.emit("signin", widget.sourceChat!.id);
  }

  //gui tin nhan......................................
  void sendMessage(
      String message, String sourceId, String targetId, String path) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    String time = DateTime.now().toString();
    if (userProvider.userP.hadMessageList
            .indexOf(widget.chatModel!.id.toString()) <
        0) {
      print("---đây là lần đầu nhắn tin ---");
      print(userProvider.userP.hadMessageList);
      var result = await Future.wait([
        PostApi(userProvider.jwtP, {"frId": widget.chatModel!.id.toString()},
            "/user/createHadMsg"),
        PostApi(
            userProvider.jwtP,
            {
              "message": message,
              "sourceId": sourceId,
              "targetId": targetId,
              "time": time,
              "path": path,
            },
            "/message")
      ]);
      print("kết quả new user chat là");
      print(result);
      if (result[0] == "done" && result[1] == "done") {
        userProvider.userP.hadMessageList.add(widget.chatModel!.id.toString());
        MessageModel messageModel = MessageModel(
            message: message,
            path: path,
            targetId: targetId,
            sourceId: sourceId,
            time: time);

        List<MessageModel> listMsg = [];
        socket.emit("message", {
          "message": message,
          "sourceId": sourceId,
          "targetId": targetId,
          "time": time,
          "path": path,
        });

        listMsg.add(messageModel);
        Map<String, List<MessageModel>> newMsg = messageProvider.listMessageP;
        newMsg[sourceId + "/" + targetId] = listMsg;
        userProvider.listHadChatP[targetId] = UserModel(
            avatarImg: [widget.chatModel!.avatar],
            hadMessageList: [],
            friendConfirm: [],
            feedImg: [],
            feedVideo: [],
            friendRequest: [],
            friend: [],
            coverImg: [],
            realName: widget.chatModel!.realName,
            id: widget.chatModel!.id);
        print("list cả người mới");
        print(sourceId);
        print(targetId);
        print(newMsg[targetId + "/" + sourceId]);
        print(userProvider.userP.hadMessageList);
        messageProvider.userMessage(newMsg);
      }
    } else {
      socket.emit("message", {
        "message": message,
        "sourceId": sourceId,
        "targetId": targetId,
        "time": DateTime.now().toString(),
        "path": path,
      });
      var msg = await Future.wait([
        PostApi(
            userProvider.jwtP,
            {
              "message": message,
              "sourceId": sourceId,
              "targetId": targetId,
              "time": time,
              "path": path,
            },
            "/message"),
        PostApi(
            userProvider.jwtP,
            {
              "idUser": sourceId,
              "idFr": targetId,
            },
            "/user/addOneHadMsgList"),
      ]);
      print("post tin nhắn hú");
      print(msg);

      setMessage(message, path, widget.chatModel!.id.toString(),
          widget.sourceChat!.id.toString(), time);
    }

    // if (mounted) setState(() {});
  }

  //
  void setMessage(String message, String path, String targetId, String sourceId,
      String time) {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    MessageModel messageModel = MessageModel(
        message: message,
        path: path,
        targetId: targetId,
        sourceId: sourceId,
        time: time);

    List<MessageModel> listMsg = [];

    if (messageProvider.listMessageP[sourceId + "/" + targetId] != null) {
      listMsg = messageProvider.listMessageP[sourceId + "/" + targetId]!;
      listMsg.add(messageModel);
    } else {
      listMsg = [messageModel];
    }
    Map<String, List<MessageModel>> newMsg = messageProvider.listMessageP;
    newMsg[targetId + "/" + sourceId] = listMsg;
    messageProvider.userMessage(newMsg);
  }

  //gửi hình ảnh................................
  void onImageSend(String path, String jwt, String sourceId, String targetId,
      String time) async {
    print("image.............${path}");

    var request = http.MultipartRequest(
      "POST",
      Uri.parse(SERVER_IP + "/file/img/upload"),
    );
    request.fields["eventChangeImgUser"] = "message";
    request.fields["sourceId"] = sourceId;
    request.fields["targetId"] = targetId;
    request.fields["time"] = time;

    request.headers.addAll(
        {"Content-type": "multipart/form-data", "cookie": "jwt=" + jwt});
    request.files.add(await http.MultipartFile.fromPath("img", path));
    request.fields["eventChangeImgUser"] = "message";

    http.StreamedResponse response = await request.send();
    var httpResponse = await http.Response.fromStream(response);
    if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
      var data = json.decode(httpResponse.body).toString();
      var pathSV = data;
      if (data != "not jwt" && data != "error") {
        setMessage("", pathSV, widget.chatModel!.id.toString(),
            widget.sourceChat!.id.toString(), time);

        socket.emit("message", {
          "message": "",
          "sourceId": widget.sourceChat!.id,
          "targetId": widget.chatModel!.id,
          "path": pathSV,
          "time": DateTime.now().toString(),
        });

        for (var i = 0; i < popTime; i++) {
          if (mounted) Navigator.pop(context);
        }
        if (mounted)
          setState(() {
            popTime = 0;
          });
      } else {
        print(data);
      }
    } else {
      print("---có lỗi khi gửi ảnh---");
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
    String choose = "";
    if (choose == "deleteAll") {
      print("deleteAll");
    }
    return Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
      print("---render individual--------");

      if (messageProvider.listMessageP[
              widget.sourceChat!.id + "/" + widget.chatModel!.id] !=
          null) {
        messages = messageProvider
            .listMessageP[widget.sourceChat!.id + "/" + widget.chatModel!.id]!;
      }
      print("message tổng là");
      print(messages);
      return DismissKeyboard(
        child: Stack(children: [
          Image.asset("assets/images/background.png",
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width),
          Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: AppBar(
                  leadingWidth: 60,
                  titleSpacing: 0,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 22, right: 12),
                    child: InkWell(
                        onTap: () async {
                          focusNode.unfocus();
                          if (!focusNode.hasFocus) {
                            Navigator.of(context).pop(true);
                          }

                          //
                        },
                        child: Icon(Icons.arrow_back, size: 24)),
                  ),
                  title: InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0),
                          child: CircleAvatar(
                              child: Image.asset(
                                  widget.chatModel!.isGroup
                                      ? "assets/icons/groups.png"
                                      : "assets/icons/man.png",
                                  width: 37,
                                  height: 37)),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.chatModel!.realName,
                                style: TextStyle(
                                    fontSize: 18.5,
                                    fontWeight: FontWeight.bold)),
                            Text("last seen today 18:05",
                                style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.videocam),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () {},
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == "DeleteAll") {
                          var result = await showOkCancelAlertDialog(
                              context: context,
                              onWillPop: () async {
                                return true;
                              },
                              title: "Bạn có chắc chắn muốn xóa?");
                          if (result == OkCancelResult.ok) {
                            print("đã đồng ý");

                            var res = await DeleteApi(userProvider.jwtP, {},
                                "/message/" + widget.chatModel!.id);
                            print("kết quả khi delete ");
                            if (res != "error" && res != "not jwt") {
                              messageProvider.listMessageP[
                                  userProvider.userP.id +
                                      "/" +
                                      widget.chatModel!.id] = [];
                              messageProvider.listMessageP.remove(
                                  userProvider.userP.id +
                                      "/" +
                                      widget.chatModel!.id);

                              userProvider.userP.hadMessageList
                                  .remove(widget.chatModel!.id);
                              userProvider.listHadChatP.remove(
                                  userProvider.userP.id +
                                      "/" +
                                      widget.chatModel!.id);

                              messageProvider
                                  .userMessage(messageProvider.listMessageP);
                              if (mounted) {
                                setState(() {
                                  messages = [];
                                });
                              }
                            }
                          } else {
                            print("cancel");
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(child: Text("Search"), value: "Search"),
                          PopupMenuItem(
                              child: Text("Xóa tất cả tin nhắn"),
                              onTap: () async {
                                print("ấn thử");
                              },
                              value: "DeleteAll"),
                          PopupMenuItem(
                              child: Text("Not notification"),
                              value: "Not notification"),
                        ];
                      },
                    ),
                  ],
                ),
              ),
              body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: WillPopScope(
                  child: Column(
                    children: [
                      //tin nhắn..............................................
                      Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              controller: _scrollController,
                              itemCount: messages.length + 1,
                              itemBuilder: (context, index) {
                                if (index == messages.length) {
                                  return Container(
                                    height: 70,
                                  );
                                }
                                if (messages[index].sourceId.toString() ==
                                    widget.sourceChat!.id.toString()) {
                                  if (messages[index].path.length > 0) {
                                    return OwnFileCard(
                                      path: messages[index].path,
                                      message: messages[index].message,
                                    );
                                  } else {
                                    return OwnMessageCard(msg: messages[index]);
                                  }
                                } else {
                                  if (messages[index].path.length > 0) {
                                    return ReplyFileCard(
                                      path: messages[index].path,
                                      message: messages[index].message,
                                    );
                                  } else {
                                    return ReplyMessageCard(
                                        msg: messages[index]);
                                  }
                                }
                              })),
                      //input text............................................
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
                                                                          targetId: widget
                                                                              .chatModel!
                                                                              .id,
                                                                          event:
                                                                              "message",
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
                                        child: IconButton(
                                          icon: !isSendBtn
                                              ? Icon(Icons.mic)
                                              : Icon(Icons.send),
                                          onPressed: () {
                                            if (isSendBtn) {
                                              _scrollController.animateTo(
                                                  _scrollController
                                                      .position.maxScrollExtent,
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeOut);
                                              sendMessage(
                                                  _controller.text,
                                                  widget.sourceChat!.id,
                                                  widget.chatModel!.id,
                                                  "");
                                              _controller.clear();
                                              if (mounted)
                                                setState(() {
                                                  isSendBtn = false;
                                                });
                                            }
                                          },
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
                                    event: "message",
                                    targetId: widget.chatModel!.id,
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
                                        path: file.path,
                                        targetId: widget.chatModel!.id,
                                        event: "message",
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

  @override
  void dispose() {
    print("dispose      chạy");
    super.dispose();
    // socket.disconnect();
    // _scrollController.dispose();
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

////////////////////////////////////////////////////////////////
// getMessageInit(String jwt) async {
//     String sourceId = widget.sourceChat!.id.toString();
//     String targetId = widget.chatModel!.id.toString();
//     int i;

//     List data = await Future.wait([
//       fetchData(sourceId, targetId, jwt),
//       fetchData(targetId, sourceId, jwt)
//     ]);
//     print("gia tri cua a");
//     print(data[0]);
//     if (data[0] == "not jwt" ||
//         data[1] == "not jwt" ||
//         data[0] == "error" ||
//         data[1] == "error") {
//       print("loi");
//     } else {
//       for (i = 0; i < data[0].length; i++) {
//         MessageModel a = MessageModel(
//           type: "",
//           message: data[0][i]["message"],
//           path: data[0][i]["path"],
//           sourceId: data[0][i]["sourceId"].toString(),
//           targetId: data[0][i]["targetId"].toString(),
//           time: data[0][i]["time"],
//         );

//         messages.add(a);
//       }
//       for (i = 0; i < data[1].length; i++) {
//         MessageModel a = MessageModel(
//           type: "",
//           message: data[1][i]["message"],
//           path: data[1][i]["path"],
//           sourceId: data[1][i]["sourceId"].toString(),
//           targetId: data[1][i]["targetId"].toString(),
//           time: data[1][i]["time"],
//         );

//         messages.add(a);
//       }
//
// ;
//       print("get init message done .....................");
//       if (mounted) setState(() {});
//     }
//   }
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
