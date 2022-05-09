List<String> friendNull = [''];

class UserModel {
  late String userName;
  late String email;
  late String createdAt;
  late String seenTimeNotifi;
  late List friend;
  late List hadMessageList;
  late String realName;
  late String id;
  late String addressTinh;
  late String addressDetails;
  late String birthDate;
  late List avatarImg;
  late List coverImg;
  late String sex;
  late List friendRequest;
  late List friendConfirm;
  late List feedImg;
  late List feedVideo;

  UserModel(
      {this.userName = "",
      this.email = "",
      this.realName = "",
      this.createdAt = "",
      this.seenTimeNotifi = "",
      required this.friend,
      required this.feedImg,
      required this.feedVideo,
      this.id = "",
      this.sex = "",
      this.addressTinh = "",
      this.addressDetails = "",
      this.birthDate = "",
      required this.hadMessageList,
      required this.coverImg,
      required this.friendConfirm,
      required this.friendRequest,
      required this.avatarImg});
}

class UserCreateModel {
  late String userName;
  late String email;
  late String password;
  late List friend;
  late String token;
  late List hadMessageList;
  late String realName;
  late String createdAt;

  late String sex;
  late String addressTinh;
  late String addressDetails;
  late String birthDate;
  late List avatarImg;
  late List coverImg;
  late List friendRequest;
  late List friendConfirm;
  UserCreateModel(
      {this.userName = "",
      this.email = "",
      this.realName = "",
      this.sex = "",
      this.birthDate = "",
      this.addressTinh = "",
      this.createdAt = "",
      this.addressDetails = "",
      this.password = "",
      required this.friend,
      this.token = "",
      required this.hadMessageList,
      required this.coverImg,
      required this.friendConfirm,
      required this.friendRequest,
      required this.avatarImg});
}
