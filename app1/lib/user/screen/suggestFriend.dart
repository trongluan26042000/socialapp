import 'package:app1/main.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:app1/ui.dart';
import 'package:app1/user/screen/FriendProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SuggestFriendScreen extends StatefulWidget {
  const SuggestFriendScreen({Key? key}) : super(key: key);

  @override
  _SuggestFriendScreenState createState() => _SuggestFriendScreenState();
}

class _SuggestFriendScreenState extends State<SuggestFriendScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List allIdFrOfFr = [];
    for (int i = 0; i < userProvider.userP.friend.length; i++) {
      userProvider.listFrOfFrP.remove(userProvider.userP.friend[i]);
    }
    userProvider.listFrOfFrP.remove(userProvider.userP.id);
    allIdFrOfFr.addAll(userProvider.listFrOfFrP.keys);

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: ListView.builder(
            itemCount: userProvider.listFrOfFrP.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () {
                      print(userProvider.listConfirmFrP);
                    },
                    child: Text(
                      " Gới ý kết bạn ",
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
                                frId: userProvider
                                    .listFrOfFrP[
                                        userProvider.listFrOfFrP[index - 1]]!
                                    .id)));
                  },
                  child: ListTile(
                      tileColor: index % 2 == 0
                          ? Colors.amberAccent[100]
                          : Colors.lightBlueAccent[100],
                      subtitle: Text(userProvider
                          .listFrOfFrP[allIdFrOfFr[index - 1]]!.addressTinh),
                      title: Text(
                          userProvider
                              .listFrOfFrP[allIdFrOfFr[index - 1]]!.realName,
                          style: AppStyles.h4),
                      leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 30,
                          backgroundImage: AssetImage('assets/images/load.gif'),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(SERVER_IP +
                                "/upload/" +
                                userProvider
                                    .listFrOfFrP[allIdFrOfFr[index - 1]]!
                                    .avatarImg[userProvider
                                        .listFrOfFrP[allIdFrOfFr[index - 1]]!
                                        .avatarImg
                                        .length -
                                    1]),
                            backgroundColor: Colors.transparent,
                          ))),
                ),
              );
            }),
      ),
    );
  }
}
