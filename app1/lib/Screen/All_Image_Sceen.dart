import 'package:app1/main.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class All_Avatar_Screen extends StatelessWidget {
  const All_Avatar_Screen(
      {Key? key, required this.type, required this.user, String title: 'Ảnh'})
      : super(key: key);
  final String type;
  final UserModel user;
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List listImg = [];
    if (type == "feed") {
      listImg = user.feedImg;
    }
    if (type == "avatar") {
      listImg = user.avatarImg;
    }
    if (type == "cover") {
      listImg = user.coverImg;
    }
    //  List feedVideo = userProvider.userP.feedVideo;

    return Scaffold(
        appBar: AppBar(
          title: Text("Tất cả ảnh"),
        ),
        backgroundColor: Colors.white,
        body: GridView.builder(
            itemCount: listImg.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemBuilder: (context, index) {
              if (listImg[index] != null) {
                return Container(
                    color: Colors.black12,
                    child: Image.network(
                      SERVER_IP + "/upload/" + listImg[index],
                      fit: BoxFit.contain,
                    ));
              } else {
                return Container();
              }
            }));
  }
}
