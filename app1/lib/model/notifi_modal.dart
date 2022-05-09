class NotifiModel {
  late bool isSeen;
  late String type;
  late String sourceIdUser;
  late List targetIdUser;
  late String sourceUserPathImg;
  late String sourceRealnameUser;
  late String content;
  late String createdAt;
  NotifiModel(
      {this.type = "",
      this.sourceIdUser = "",
      this.sourceRealnameUser = "",
      this.sourceUserPathImg = "avatarNull.jpg",
      required this.targetIdUser,
      this.createdAt = "",
      this.isSeen = false,
      this.content = ""});
}
