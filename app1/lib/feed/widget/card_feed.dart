import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:app1/chat-app/customs/avatar_card.dart';
import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/feed/screen/comment.dart';
import 'package:app1/feed/screen/mainFeedScreen.dart';
import 'package:app1/main.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/comment_provider.dart';
import 'package:app1/provider/feed_provider.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:app1/ui.dart';
import 'package:app1/widgets/card_video.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:video_player/video_player.dart';

import 'package:http/http.dart' as http;

class CardFeedStyle extends StatefulWidget {
  final FeedBaseModel feed;
  CardFeedStyle({Key? key, required this.feed, required this.ownFeedUser})
      : super(key: key);

  final UserModel ownFeedUser;
  @override
  _CardFeedStyleState createState() => _CardFeedStyleState();
}

class _CardFeedStyleState extends State<CardFeedStyle> {
  final int totalLike = 0;
  final int totalComment = 0;
  FeedBaseModel feedApi = new FeedBaseModel(
      like: [], rule: [], comment: [], pathImg: [], tag: [], pathVideo: []);
  late bool isLike = false;
  late VideoPlayerController _videoPlayerController;
  List listRealNameTag = [];
  bool isDeleteIcon = false;
  @override
  void initState() {
    super.initState();
    //-------------------------------lấy Api của Tag--------------------------
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (widget.feed.tag.length > 0) {
          var getListUsertagApi = await PostApi(userProvider.jwtP,
              {"listUser": widget.feed.tag}, "/user/listUser");
          if (getListUsertagApi != "not jwt" && getListUsertagApi != "error") {
            if (getListUsertagApi.length > 0) {
              listRealNameTag = getRealNameApi(getListUsertagApi);
              if (mounted) {
                setState(() {});
              }
            }
          }
        }
      }
    });
    //------------------------------------------------casx-------------
    feedApi = widget.feed;
    if (widget.feed.pathImg.length > 0) {
      for (int i = 0; i < widget.feed.pathImg.length; i++) {
        if (widget.feed.pathImg[i].toString().substring(
                    widget.feed.pathImg[i].toString().length - 3,
                    widget.feed.pathImg[i].toString().length) !=
                'png' ||
            widget.feed.pathImg[i].toString().substring(
                    widget.feed.pathImg[i].toString().length - 3,
                    widget.feed.pathImg[i].toString().length) !=
                'jpg' ||
            widget.feed.pathImg[i].toString().substring(
                    widget.feed.pathImg[i].toString().length - 3,
                    widget.feed.pathImg[i].toString().length) !=
                'gif') {
          _videoPlayerController = VideoPlayerController.network(
              SERVER_IP + "/upload/" + widget.feed.pathImg[0].toString())
            ..addListener(() {})
            ..setLooping(true)
            ..initialize().then((_) => _videoPlayerController.pause());
        }
      }
    }
    for (int i = 0; i < widget.feed.pathVideo.length; i++) {
      {
        _videoPlayerController = VideoPlayerController.network(
            SERVER_IP + "/upload/" + widget.feed.pathVideo[i].toString())
          ..addListener(() => {
                // if (mounted) {setState(() {})}
              })
          ..setLooping(true)
          ..initialize().then((_) => _videoPlayerController.pause());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);

    final commentProvider =
        Provider.of<CommentProvider>(context, listen: false);

    Size size = MediaQuery.of(context).size;
    for (int i = 0; i < feedApi.like.length; i++) {
      if (feedApi.like[i] == userProvider.userP.id) {
        print("------đã like-------");
        isLike = true;
      }
    }
    Widget FeedVideosContainer(videosList) {
      switch (videosList.length) {
        case 1:
          return Container(
            width: size.width - 40,
            height: size.height - 300,
            child: Container(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  VideoPlayer(_videoPlayerController),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Color.fromRGBO(255, 255, 255, 0.4),
                      child: IconButton(
                        onPressed: () async {
                          print("hí");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => CardFeedVideoState(
                                      controller: _videoPlayerController)));
                        },
                        icon: Icon(Icons.play_circle_fill_outlined),
                      ),
                    ),
                  ), //position hiển thi icon video
                ],
              ),
            ),
          );
          break;
      }
      return Container();
    }

    Widget FeedImagesContainer(imagesList) {
      switch (imagesList.length) {
        case 1:
          return Container(
            color: Colors.black12,
            width: size.width - 40,
            height: size.height - 300,
            child: (imagesList[0].toString().substring(
                            imagesList[0].toString().length - 3,
                            imagesList[0].toString().length) ==
                        "png" ||
                    imagesList[0].toString().substring(
                            imagesList[0].toString().length - 3,
                            imagesList[0].toString().length) ==
                        "jpg" ||
                    imagesList[0].toString().substring(
                            imagesList[0].toString().length - 3,
                            imagesList[0].toString().length) ==
                        "gif")
                ? CachedNetworkImage(
                    imageUrl: SERVER_IP + "/upload/" + imagesList[0],
                    fit: BoxFit.fitWidth,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )
                : Container(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        VideoPlayer(_videoPlayerController),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Color.fromRGBO(255, 255, 255, 0.4),
                            child: IconButton(
                              onPressed: () async {
                                print("hí");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            CardFeedVideoState(
                                                controller:
                                                    _videoPlayerController)));
                              },
                              icon: Icon(Icons.play_circle_fill_outlined),
                            ),
                          ),
                        ), //position hiển thi icon video
                      ],
                    ),
                  ),
          );
          break;
        case 2:
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  color: Colors.black,
                  width: (size.width - 36) / 2,
                  height: (size.width - 50) / 2 * 5 / 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: SERVER_IP + "/upload/" + imagesList[0],
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Color.fromRGBO(255, 255, 255, 0.4),
                          child: IconButton(
                            onPressed: () async {
                              print("hí");
                            },
                            icon: Icon(
                              Icons.photo_album_outlined,
                              size: 5,
                            ),
                          ),
                        ),
                      ), //position hiển thi icon video
                    ],
                  )),
              Container(
                  color: Colors.black,
                  height: (size.width - 50) / 2 * 5 / 3,
                  width: (size.width - 36) / 2,
                  child: CachedNetworkImage(
                    imageUrl: SERVER_IP + "/upload/" + imagesList[1],
                    fit: BoxFit.fitWidth,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )),
            ],
          );
          break;
        case 3:
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  color: Colors.black38,
                  width: (size.width - 36) / 2,
                  height: size.width,
                  child: CachedNetworkImage(
                    imageUrl: SERVER_IP + "/upload/" + imagesList[0],
                    fit: BoxFit.fitWidth,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )),
              Container(
                width: (size.width - 32) / 2,
                height: size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        color: Colors.black38,
                        height: (size.width - 6) / 2,
                        width: (size.width - 36) / 2,
                        child: CachedNetworkImage(
                          imageUrl: SERVER_IP + "/upload/" + imagesList[1],
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        )),
                    Container(
                        color: Colors.black38,
                        height: (size.width - 6) / 2,
                        width: (size.width - 36) / 2,
                        child: CachedNetworkImage(
                          imageUrl: SERVER_IP + "/upload/" + imagesList[2],
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        )),
                  ],
                ),
              )
            ],
          );
          break;
        case 4:
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  color: Colors.black38,
                  width: (size.width - 36) / 2,
                  height: size.width,
                  child: CachedNetworkImage(
                    imageUrl: SERVER_IP + "/upload/" + imagesList[0],
                    fit: BoxFit.fitWidth,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )),
              Container(
                width: (size.width - 36) / 2,
                height: size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        color: Colors.black38,
                        height: (size.width - 10) / 3,
                        width: (size.width - 36) / 2,
                        child: CachedNetworkImage(
                          imageUrl: SERVER_IP + "/upload/" + imagesList[1],
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        )),
                    Container(
                        color: Colors.black38,
                        height: (size.width - 10) / 3,
                        width: (size.width - 36) / 2,
                        child: CachedNetworkImage(
                          imageUrl: SERVER_IP + "/upload/" + imagesList[2],
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        )),
                    Container(
                        color: Colors.black38,
                        height: (size.width - 10) / 3,
                        width: (size.width - 36) / 2,
                        child: CachedNetworkImage(
                          imageUrl: SERVER_IP + "/upload/" + imagesList[3],
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        )),
                  ],
                ),
              )
            ],
          );
          break;
        default:
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  color: Colors.black38,
                  width: (size.width - 36) / 2,
                  height: size.width,
                  child: CachedNetworkImage(
                    imageUrl: SERVER_IP + "/upload/" + imagesList[0],
                    fit: BoxFit.fitWidth,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )),
              Container(
                width: (size.width - 36) / 2,
                height: size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        color: Colors.black38,
                        height: (size.width - 10) / 3,
                        width: (size.width - 36) / 2,
                        child: CachedNetworkImage(
                          imageUrl: SERVER_IP + "/upload/" + imagesList[1],
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        )),
                    Container(
                        color: Colors.black38,
                        height: (size.width - 10) / 3,
                        width: (size.width - 36) / 2,
                        child: CachedNetworkImage(
                          imageUrl: SERVER_IP + "/upload/" + imagesList[2],
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        )),
                    Stack(children: [
                      Container(
                          color: Colors.black38,
                          height: (size.width - 10) / 3,
                          width: (size.width - 36) / 2,
                          child: CachedNetworkImage(
                            imageUrl: SERVER_IP + "/upload/" + imagesList[3],
                            fit: BoxFit.fitWidth,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )),
                      Container(
                        color: Colors.black45,
                        height: (size.width - 10) / 3,
                        width: (size.width - 36) / 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                                child: Text(
                              " + " + (imagesList.length - 4).toString(),
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            )),
                          ],
                        ),
                      ),
                    ]),
                  ],
                ),
              )
            ],
          );
          break;
      }
      return Container();
    }

    return Container(
        margin: const EdgeInsets.only(bottom: 40),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          // border: Border.all(
          //   width: 1, //                   <--- border width here
          // ),
          borderRadius: BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26.withOpacity(0.5),
              blurRadius: 4,
              offset: Offset(3, 6), // changes position of shadow
            )
          ],
        ),
        child: InkWell(
          onTap: () {
            print("ấn vào card");
            if (widget.feed.pathImg.length > 0 ||
                widget.feed.message.length > 50 ||
                widget.feed.pathVideo.length > 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => MainFeedScreen(
                          feed: widget.feed, ownFeedUser: widget.ownFeedUser)));
            }
          },
          child: Stack(children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    color: Colors.blue[100],
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 23,
                        backgroundImage: AssetImage('assets/images/load.gif'),
                        child: CircleAvatar(
                          radius: 23,
                          backgroundImage: NetworkImage(SERVER_IP +
                              "/upload/" +
                              widget.ownFeedUser.avatarImg[
                                  widget.ownFeedUser.avatarImg.length - 1]),
                          backgroundColor: Colors.transparent,
                        ),
                      ),

                      //--------------------------------tag------------------------------------------
                      title: Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: RichText(
                            text: TextSpan(
                                text: widget.ownFeedUser.realName,
                                style: AppStyles.h3.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                children: [
                              listRealNameTag.length > 0
                                  ? TextSpan(
                                      text: " cùng với ",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    )
                                  : TextSpan(),
                              listRealNameTag.length > 0
                                  ? TextSpan(
                                      text: listRealNameTag[0],
                                      style: AppStyles.h6.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    )
                                  : TextSpan(),
                              listRealNameTag.length > 1
                                  ? TextSpan(
                                      text: ", " + listRealNameTag[1],
                                      style: AppStyles.h6.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    )
                                  : TextSpan(),
                              listRealNameTag.length > 2
                                  ? TextSpan(
                                      text: " và " +
                                          (listRealNameTag.length - 2)
                                              .toString() +
                                          " người khác",
                                      style: AppStyles.h6.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    )
                                  : TextSpan(),
                            ])),
                      ),
                      subtitle: Text(
                        widget.feed.createdAt.substring(0, 10),
                        style: AppStyles.h5,
                      ),
                    ),
                  ),
                  Divider(),
                  widget.feed.message != ""
                      ? Container(
                          constraints: BoxConstraints(minHeight: 100),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, bottom: 8),
                            child: SizedBox(
                              width: size.width,
                              child: AutoSizeText(
                                widget.feed.message,
                                maxLines: 5,
                                minFontSize: 18,
                                style: widget.feed.message.length > 30
                                    ? AppStyles.h3
                                    : AppStyles.h2,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Divider(),
                  widget.feed.pathImg.length > 0
                      ? Center(
                          child: FeedImagesContainer(widget.feed.pathImg),
                        )
                      : Container(),
                  widget.feed.pathVideo.length > 0
                      ? Center(
                          child: FeedVideosContainer(widget.feed.pathVideo),
                        )
                      : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      feedApi.like.length > 0
                          ? Row(
                              children: [
                                Text(
                                  "   " +
                                      feedApi.like.length.toString() +
                                      " like",
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            )
                          : Container(),
                      totalComment != 0
                          ? Text(totalComment.toString() + " comment")
                          : Container()
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                          onPressed: () async {
                            print(feedApi.like.length);
                            print("tên người đang dùng là : " +
                                userProvider.userP.userName);
                            print(widget.feed.feedId);
                            if (isLike == false) {
                              List result = await Future.wait([
                                //lấy feed mới để hiển thị số like.........
                                getFeedApi(
                                    widget.feed.feedId, userProvider.jwtP),
                                //like bài viết
                                postApi(
                                    userProvider.jwtP,
                                    {
                                      "feedId": widget.feed.feedId,
                                      "event": "like",
                                      "createdAt": DateTime.now().toString()
                                    },
                                    "/feed/likeFeed")
                              ]);
                              if (mounted) {
                                setState(() {
                                  isLike = !isLike;
                                  feedApi.like = result[0].like;
                                  feedApi.like.add(userProvider.userP.id);
                                });
                              }
                            } else {
                              List result = await Future.wait([
                                //lấy feed mới để hiển thị số like.........
                                getFeedApi(
                                    widget.feed.feedId, userProvider.jwtP),
                                //like bài viết
                                postApi(
                                    userProvider.jwtP,
                                    {
                                      "feedId": widget.feed.feedId,
                                      "event": "dislike",
                                      "createdAt": DateTime.now().toString()
                                    },
                                    "/feed/likeFeed")
                              ]);
                              if (mounted) {
                                setState(() {
                                  isLike = !isLike;
                                  feedApi.like = result[0].like;
                                  feedApi.like.remove(userProvider.userP.id);
                                });
                              }
                            }
                          },
                          icon: isLike
                              ? Image.asset("assets/icons/likedIcon.png",
                                  height: 40)
                              : Image.asset("assets/icons/notLikeIcon.png",
                                  height: 40),
                          label: Text("",
                              style: TextStyle(
                                  color: isLike ? Colors.blue : Colors.grey))),
                      TextButton.icon(
                          onPressed: () async {
                            commentProvider.userFeedId(widget.feed.feedId);
                            print(widget.ownFeedUser.id);
                            print("bình luận");
                            FeedBaseModel feed1 = widget.feed;
                            print(widget.feed);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) =>
                                        CommentScreen(feed: widget.feed)));
                          },
                          icon: Image.asset("assets/icons/messageIcon.png",
                              height: 40),
                          label: Text(""))
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              right: 24,
              child: Material(
                color: Colors.blue[100],
                child: Container(
                    alignment: Alignment.center,
                    width: 70,
                    height: 50,
                    child: InkWell(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            isDeleteIcon = true;
                          });
                        }
                      },
                      overlayColor: MaterialStateProperty.all(Colors.blue),
                      child: Container(
                          width: 40,
                          child: Text(
                            "...",
                            style: TextStyle(
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    )),
              ),
            ),
            (isDeleteIcon && widget.feed.sourceUserId == userProvider.userP.id)
                ? Positioned(
                    right: 10,
                    child: Material(
                      color: Colors.blue[100],
                      child: TextButton.icon(
                          onPressed: () async {
                            commentProvider.userFeedId(widget.feed.feedId);
                            print(widget.ownFeedUser.id);
                            print("xóa bài viết");
                            if (mounted) {
                              setState(() {
                                isDeleteIcon = false;
                              });
                            }
                            print(widget.feed);
                            var result = await showOkCancelAlertDialog(
                                context: context,
                                onWillPop: () async {
                                  return true;
                                },
                                title: "Bạn có chắc chắn muốn xóa?");
                            if (result == OkCancelResult.ok) {
                              var resultDeleteApi = await DeleteApi(
                                  userProvider.jwtP,
                                  {},
                                  "/feed/" + widget.feed.feedId);
                              if (resultDeleteApi == "done") {
                                List<FeedBaseModel> listFeedsPNew =
                                    feedProvider.listFeedsP;
                                listFeedsPNew.remove(widget.feed);
                                feedProvider.userFeed(listFeedsPNew);
                                // Singleton (factory)
                                final logger = SimpleLogger();
                                logger.info('Hello info!');
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.success,
                                  text: "Đã xóa bài viết!",
                                );
                              }
                            }
                          },
                          icon: Image.asset("assets/icons/deleteIcon.png",
                              height: 45),
                          label: Text("")),
                    ),
                  )
                : Container()
          ]),
        ));
  }

  //-------------------GetApi init----------------------------------------
  Future fetchApiFindFeed(String sourceFeedId, String jwt) async {
    print("----chạy hàm get api feed---------------");
    try {
      print("source feed id là ");
      print(sourceFeedId);

      http.Response response;
      String path = SERVER_IP + '/feed/' + sourceFeedId;
      print(path);
      response = await http.get(
        Uri.parse(path),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'cookie': "jwt=" + jwt,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("kết quả là feed ");
        print(json.decode(response.body));
        return json.decode(response.body);
      } else {
        return FeedBaseModel(
            like: [],
            rule: [],
            comment: [],
            pathImg: [],
            tag: [],
            pathVideo: []);
      }
    } catch (e) {
      return FeedBaseModel(
          like: [], rule: [], comment: [], tag: [], pathImg: [], pathVideo: []);
    }
  }

  //-----------------------like func------------
  getFeedApi(sourceId, jwt) async {
    FeedBaseModel feedApi = FeedBaseModel(
        like: [], tag: [], rule: [], comment: [], pathImg: [], pathVideo: []);
    var data = await fetchApiFindFeed(sourceId, jwt);
    if (data == "not jwt") {
      return feedApi;
    } else {
      if (data != "error") {
        print("data:feed là");
        print(data);
        print(data["like"]);
        FeedBaseModel a = FeedBaseModel(
          like: data["like"],
          comment: data["comment"],
          pathImg: data["pathImg"],
          pathVideo: data["pathVideo"],
          tag: data["tag"],
          rule: data["rule"],
          message: data["messages"],
          createdAt: data["createdAt"],
        );
        return a;
      } else {
        return feedApi;
      }
    }
  }

  //--------------------------like và dislike-----------------
  postApi(String jwt, data, String sourcePath) async {
    print("----chạy hàm get api feed---------------");
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

Future<dynamic> delete(String jwt, String pathApi) async {
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
    print("-----kêt quả post--------");
    print(json.decode(response.body).toString());
    return json.decode(response.body);
  } else {
    print("---------------post lỗi---------");
    return "error";
  }
}

getRealNameApi(result) {
  List newRN = [];
  for (int i = 0; i < result.length; i++) {
    newRN.add(result[i]["realName"]);
  }

  return newRN;
}
