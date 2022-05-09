import 'package:app1/chat-app/customs/StatusPage/headOwnStatus.dart';
import 'package:app1/chat-app/customs/StatusPage/otherStatus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 48,
            child: FloatingActionButton(
              backgroundColor: Colors.blueGrey[100],
              onPressed: () {},
              child: Icon(
                Icons.edit,
                color: Colors.blueGrey[900],
              ),
            ),
          ),
          SizedBox(
            height: 13,
          ),
          FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.greenAccent[700],
              elevation: 5,
              child: Icon(Icons.camera_alt))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeadOwnStatus(),
            lable("re update"),
            OtherStatus(
              name: "nam",
              time: "8:00",
              isSeen: false,
              statusNum: 2,
            ),
            OtherStatus(
              name: "nam-1",
              time: "8:01",
              isSeen: true,
              statusNum: 1,
            ),
            OtherStatus(
              name: "nam-2",
              time: "8:00",
              isSeen: false,
              statusNum: 3,
            ),
            lable("view update ")
          ],
        ),
      ),
    );
  }

  Widget lable(String lable) {
    return Container(
        height: 33,
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[300],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 7),
          child: Text(
            lable,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ));
  }
}
