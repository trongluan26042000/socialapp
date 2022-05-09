class MessageModel {
  late String type;
  late String message;
  late String time;
  late String path;
  late String sourceId;
  late String targetId;
  MessageModel({
    this.type = "",
    this.message = "",
    this.time = "",
    required this.path,
    this.sourceId = "",
    this.targetId = "",
  });
}
