class ChatModel {
  late String realName;
  late String icon;
  late bool isGroup;
  late String time;
  late String currentMessage;
  late String status;
  late bool isSelect;
  late String id;
  late String avatar;

  ChatModel({
    this.id = "",
    this.realName = "",
    this.icon = "",
    this.isGroup = false,
    this.time = "",
    this.avatar = "",
    this.currentMessage = "",
    this.status = "",
    this.isSelect = false,
  });
}
