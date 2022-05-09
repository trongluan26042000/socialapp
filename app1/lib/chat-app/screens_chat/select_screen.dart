import 'package:app1/chat-app/customs/button_card.dart';
import 'package:app1/chat-app/customs/contact_card.dart';
import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:app1/chat-app/screens_chat/CreateGroup.dart';
import 'package:flutter/material.dart';

class SelectContact extends StatefulWidget {
  const SelectContact({Key? key}) : super(key: key);

  @override
  State<SelectContact> createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  List<ChatModel> contacts = [
    ChatModel(realName: "Dev Stack", status: "A full stack developer"),
    ChatModel(realName: "nam", status: "flutter"),
    ChatModel(realName: "my", status: " developer"),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Contact",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              Text("256 contacts", style: TextStyle(fontSize: 13))
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.search,
                  size: 26,
                )),
            PopupMenuButton<String>(onSelected: (value) {
              print(value);
            }, itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                    child: Text("Invite a friend "), value: "Invite a friend "),
                PopupMenuItem(child: Text("Contacts"), value: "Contacts"),
                PopupMenuItem(child: Text("Refresh"), value: "Refresh"),
                PopupMenuItem(child: Text("help"), value: "help"),
              ];
            })
          ],
        ),
        body: ListView.builder(
            itemCount: contacts.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => CreateGroup()));
                    },
                    child: ButtonCard(icon: Icons.group, name: "New group"));
              } else {
                if (index == 1) {
                  return ButtonCard(
                      icon: Icons.person_add, name: "New Contact");
                } else {
                  return ContactCard(contact: contacts[index - 2]);
                }
              }
            }));
  }
}
