import 'package:app1/user/screen/FriendProfile.dart';
import 'package:app1/user/screen/Profile.dart';

import 'package:app1/main.dart';
import 'package:app1/provider/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui.dart';

class AvatarFriendBtn extends StatelessWidget {
  final String? id;
  final String? jwt;
  final String? frName;
  final String? frImage;
  const AvatarFriendBtn(
      {Key? key, this.frName = null, this.frImage = null, this.id, this.jwt})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    Size size = MediaQuery.of(context).size;
    String pathAvatar;
    if (frImage == null) {
      pathAvatar = "avatarNull.jpg";
    } else {
      pathAvatar = frImage!;
    }
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => id == userProvider.userP.id
                    ? Profile()
                    : FriendProfile(
                        frId: id!,
                      )));
      },
      child: Column(
        children: [
          Container(
            color: Colors.black12,
            width: (size.width - 70) / 3,
            height: (size.width - 70) / 3,
            child: CachedNetworkImage(
              imageUrl: SERVER_IP + "/upload/" + pathAvatar,
              fit: BoxFit.fitWidth,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          frName != null
              ? Text(
                  frName ?? "",
                  style: AppStyles.h4,
                  overflow: TextOverflow.ellipsis,
                )
              : Container()
        ],
      ),
    );
  }
}
