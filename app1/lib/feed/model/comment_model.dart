class CommentBaseModel {
  late String pathImg;
  late String messages;
  late String sourceUserId;
  late String createdAt;

  CommentBaseModel({
    required this.pathImg,
    this.sourceUserId = "",
    this.messages = "",
    this.createdAt = "",
  });
}

class CommentFullModel {
  late CommentBaseModel comment;
  late String realName;
  late String avatarImg;
  CommentFullModel(
      {this.avatarImg = "avatarNull",
      required this.comment,
      this.realName = ""});
}
