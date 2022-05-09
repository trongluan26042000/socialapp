class FeedBaseModel {
  late List pathImg;
  late List pathVideo;
  late String message;
  late String sourceUserId;
  late String createdAt;
  late List rule;
  late String sourceUserName;
  late String feedId;
  late List comment;
  late List like;
  late List tag;
  FeedBaseModel(
      {required this.pathImg,
      required this.pathVideo,
      this.message = "",
      this.sourceUserId = "",
      required this.comment,
      required this.tag,
      required this.rule,
      required this.like,
      this.createdAt = "",
      this.sourceUserName = "",
      this.feedId = ""});
}
