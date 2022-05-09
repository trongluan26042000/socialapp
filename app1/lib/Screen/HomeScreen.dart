import 'dart:convert';
import 'dart:math';

import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/feed/screen/post_feed.dart';
import 'package:app1/feed/widget/Card_feed_null.dart';
import 'package:app1/main.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/feed_provider.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../ui.dart';
import '../feed/widget/card_feed.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FeedBaseModel> listFeeds = [];
  Map<String, UserModel> listUsers = {};
  ScrollController _scrollController = new ScrollController();
  List<FeedBaseModel> listFeedAll = [];
  List<FeedBaseModel> listFeedVision = [];
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final _random = new Random();
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset == 0) {
          print("bằng");
        }
        print("offset = ${_scrollController.offset}");
        if (_scrollController.offset ==
            _scrollController.position.maxScrollExtent) {
          print("max rồi");
          print(listFeedVision.length);
          print(listFeedAll.length);
          // if (listFeedAll.length > 5) {
          //   for (int i = 0; i < 5; i++) {
          //     FeedBaseModel f =
          //         listFeedAll[_random.nextInt(listFeedAll.length)];
          //     listFeedAll.remove(f);
          //     listFeedVision.add(f);
          //   }
          // } else {
          //   listFeedVision.addAll(listFeedAll);
          // // }
          setState(() {});
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);

    Size size = MediaQuery.of(context).size;

    listUsers = userProvider.listFriendsP;
    listUsers[userProvider.userP.id] = userProvider.userP;
    return Scaffold(
      body: Consumer<FeedProvider>(builder: (context, feedProvider, child) {
        listFeedAll = [];
        if (feedProvider.listFeedsFrP.length > 0) {
          listFeedAll.addAll(feedProvider.listFeedsFrP);
        }
        if (feedProvider.listFeedsP.length > 0 &&
            feedProvider.listFeedsP.length < 3) {
          listFeedAll.addAll(feedProvider.listFeedsP);
        }

        if (feedProvider.listFeedsP.length >= 3) {
          listFeedAll.add(feedProvider.listFeedsP[0]);

          listFeedAll.add(feedProvider.listFeedsP[1]);

          listFeedAll.add(feedProvider.listFeedsP[2]);
        }

        listFeedAll.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        if (listFeedVision.length > 0) {
          for (int i = 0; i < listFeedVision.length; i++) {
            listFeedAll.remove(listFeedVision[i]);
            listFeedAll.remove(listFeedVision[i]);
            print("giảm k");
            print(listFeedAll.length);
          }
        }
        print(listFeedVision.length);
        print(listFeedAll.length);
        if (listFeedAll.length > 6) {
          for (int i = 0; i < 5; i++) {
            print("length");
            print(listFeedAll.length);
            int num = 0;
            while (num == -1) {
              num = _random.nextInt(listFeedAll.length - 1);
            }
            FeedBaseModel f = listFeedAll[num];
            listFeedAll.remove(f);

            listFeedVision.add(f);
          }
        } else {
          listFeedVision.addAll(listFeedAll);
        }
        feedProvider.listFeedsVisionFrP = listFeedVision;
        return Container(
          padding: const EdgeInsets.all(8.0),
          height: size.height,
          child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: listFeedVision.length + 4,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(" 407 Gamming",
                            style: AppStyles.h2.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange)),
                        Container(
                            width: 30,
                            height: 30,
                            child: RoundedLoadingButton(
                                child: Image.asset(
                                    "assets/icons/newAgainIcon.png"),
                                controller: _btnController,
                                onPressed: () async {
                                  List<FeedBaseModel> listFeedsInit =
                                      await getFeedInit(
                                          userProvider.userP.id,
                                          userProvider.jwtP,
                                          userProvider.userP.friend);
                                  _btnController.success();
                                  feedProvider.userFrFeed(listFeedsInit);

                                  setState(() {});
                                  print(" listFeedsInit");
                                  print(listFeedsInit);
                                }))
                      ],
                    ),
                  );
                }
                if (index == 1) {
                  return Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, right: 8.0),
                                child: CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 32,
                                  backgroundImage:
                                      AssetImage('assets/images/load.gif'),
                                  child: CircleAvatar(
                                    radius: 32,
                                    backgroundImage: NetworkImage(SERVER_IP +
                                        "/upload/" +
                                        userProvider.userP.avatarImg[
                                            userProvider
                                                    .userP.avatarImg.length -
                                                1]),
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: size.width - 150,
                                  child: InkWell(
                                      child: Text("Bạn đang nghĩ gì..."),
                                      onTap: () {
                                        print(listFeedAll.length);

                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (builder) =>
                                                        PostFeedScreen()))
                                            .then((value) => setState(() {}));
                                      })),
                            ],
                          ),
                        ),
                        Divider()
                      ],
                    ),
                  );
                }
                if (index == listFeedVision.length + 2) {
                  return CardFeedStyleNull(
                      feed: FeedBaseModel(
                          pathImg: ["welcome.jpg"],
                          pathVideo: [],
                          message:
                              "📢🌻🌻Chào mừng bạn đã đến với GGApp💓. Hãy kêt bạn , chia sẻ cảm xúc của mình✊!",
                          comment: [],
                          createdAt: DateTime.now().toString(),
                          tag: [],
                          rule: ["every"],
                          like: []));
                }
                if (index == listFeedVision.length + 3) {
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
                if (listFeedVision.length != 0) {
                  return index % 2 == 0
                      ? Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: CardFeedStyle(
                              feed: listFeedVision[index - 2],
                              ownFeedUser: listUsers[listFeedVision[index - 2]
                                          .sourceUserId] !=
                                      null
                                  ? listUsers[
                                      listFeedVision[index - 2].sourceUserId]!
                                  : userProvider.userP),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: CardFeedStyle(
                            feed: listFeedVision[index - 2],
                            ownFeedUser: listUsers[listFeedVision[index - 2]
                                        .sourceUserId] !=
                                    null
                                ? listUsers[
                                    listFeedVision[index - 2].sourceUserId]!
                                : userProvider.userP,
                          ),
                        );
                } else {
                  return Container(
                      height: 300,
                      color: Colors.amber,
                      child: Text("Chưa có bài viết nào"));
                }
              }),
        );
      }),
    );
  }
}

Future fetchApiFeedInit(
    String sourceId, String jwt, String limit, String offset) async {
  try {
    http.Response response;
    List<FeedBaseModel> data1 = [];
    //tim tin nhan cua nguoi gui cho ban
    String query =
        '?limit=' + limit + '&offset=' + offset + '&sourceId=' + sourceId;
    String path = SERVER_IP + '/feed/limitFeedOwn' + query;
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
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}

//lay tin nhan ban dau................
Future getFeedInit(sourceId, jwt, List listFr) async {
  List<FeedBaseModel> listFeedsInit = [];
  List<Future> fetchAllFeedFr = [];
  for (var i = 0; i < listFr.length; i++) {
    fetchAllFeedFr.add(
      fetchApiFeedInit(listFr[i], jwt, 3.toString(), 0.toString()),
    );
  }
  List data = await Future.wait([
    // fetchApiFeedInit(sourceId, jwt, 50.toString(), 0.toString()),
    ...fetchAllFeedFr
    //  fetchData(targetId, sourceId)
  ]);
  if (data[0] == "not jwt" || data[0] == "error") {
    return listFeedsInit;
  } else {
    print("data 0");
    print(data[0]);
    for (int k = 0; k < listFr.length; k++) {
      if (data[k].length > 0) {
        for (int i = 0; i < data[k].length; i++) {
          if (data[k] != []) {
            FeedBaseModel a = FeedBaseModel(
              pathImg: data[k][i]["pathImg"],
              rule: data[k][i]["rule"],
              pathVideo: data[k][i]["pathVideo"],
              comment: data[k][i]["comment"],
              feedId: data[k][i]["_id"].toString(),
              message: data[k][i]["messages"],
              tag: data[k][i]["tag"],
              like: data[k][i]["like"],
              sourceUserId: data[k][i]["sourceUserId"].toString(),
              createdAt: data[k][i]["createdAt"],
              sourceUserName: data[k][i]["sourceUserName"].toString(),
            );
            listFeedsInit.add(a);
          }
        }
      }
    }

    listFeedsInit.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return listFeedsInit;
  }
}
