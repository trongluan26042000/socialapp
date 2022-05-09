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

class CardFeedStyleNull extends StatefulWidget {
  final FeedBaseModel feed;
  CardFeedStyleNull({Key? key, required this.feed}) : super(key: key);

  @override
  _CardFeedStyleNullState createState() => _CardFeedStyleNullState();
}

class _CardFeedStyleNullState extends State<CardFeedStyleNull> {
  //-------------------------------lấy Api của Tag--------------------------

  //------------------------------------------------casx-------------

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);

    final commentProvider =
        Provider.of<CommentProvider>(context, listen: false);

    Size size = MediaQuery.of(context).size;

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
                          backgroundImage:
                              AssetImage('assets/images/nature5.jpg'),
                          backgroundColor: Colors.transparent,
                        ),
                      ),

                      //--------------------------------tag------------------------------------------
                      title: Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: RichText(
                            text: TextSpan(
                                text: " 407GG ",
                                style: AppStyles.h3.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                children: [])),
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
                      ? Container(
                          height: size.height * 3 / 10,
                          child: Image.asset(
                            "assets/images/" +
                                widget.feed
                                    .pathImg[widget.feed.pathImg.length - 1],
                          ))
                      : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                          onPressed: () async {},
                          icon: Image.asset("assets/icons/likedIcon.png",
                              height: 40),
                          label:
                              Text("", style: TextStyle(color: Colors.blue))),
                    ],
                  ),
                  Divider(),
                ],
              ),
            ),
          ]),
        ));
  }
}
