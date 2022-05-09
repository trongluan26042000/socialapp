import 'package:app1/chat-app/customs/avatar_card.dart';
import 'package:app1/chat-app/customs/button_card.dart';
import 'package:app1/chat-app/customs/contact_card.dart';
import 'package:app1/chat-app/model/chat_modal.dart';
import 'package:flutter/material.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  List<ChatModel> contacts = [
    ChatModel(
        realName: "Dev Stack",
        status: "A full stack developer",
        isSelect: false),
    ChatModel(realName: "nam", status: "flutter", isSelect: false),
    ChatModel(realName: "my", status: " developer", isSelect: true),
  ];
  List<ChatModel> groups = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("New group",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              Text("Add", style: TextStyle(fontSize: 13))
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
        body: Stack(children: [
          ListView.builder(
              itemCount: contacts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(height: groups.length > 0 ? 90 : 10);
                }
                return InkWell(
                    onTap: () {
                      if (contacts[index - 1].isSelect == false) {
                        setState(() {
                          contacts[index - 1].isSelect = true;
                          groups.add(contacts[index - 1]);
                        });
                      } else {
                        setState(() {
                          contacts[index - 1].isSelect = false;
                          groups.remove(contacts[index - 1]);
                        });
                      }
                    },
                    child: ContactCard(contact: contacts[index - 1]));
              }),
          //head list
          groups.length > 0
              ? Column(
                  children: [
                    Container(
                        height: 75,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: contacts.length,
                            itemBuilder: (context, index) {
                              if (contacts[index].isSelect == true)
                                return InkWell(
                                    onTap: () {
                                      setState(() {
                                        contacts[index].isSelect = false;
                                        groups.remove(contacts[index]);
                                      });
                                    },
                                    child:
                                        AvatarCard(contact: contacts[index]));
                              else
                                return Container();
                            })),
                    Divider(
                      thickness: 1,
                    )
                  ],
                )
              : Container(
                  height: 0,
                ),
        ]));
  }
}
