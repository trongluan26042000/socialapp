import 'dart:io';

import 'package:app1/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OwnFileCard extends StatelessWidget {
  const OwnFileCard({Key? key, this.path, this.message}) : super(key: key);
  final String? path;
  final String? message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Container(
          height: MediaQuery.of(context).size.height / 2.5,
          width: MediaQuery.of(context).size.width / 1.8,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.green[300]),
          child: Card(
            margin: EdgeInsets.all(3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: path! != null
                ? Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 2.5,
                        width: MediaQuery.of(context).size.width / 1.8,
                        child: CachedNetworkImage(
                          imageUrl: SERVER_IP + '/upload/' + path!,
                          fit: BoxFit.fitHeight,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      message != ""
                          ? Positioned(
                              bottom: 0,
                              child: Text(
                                message.toString(),
                                style: TextStyle(color: Colors.amber),
                              ))
                          : Container()
                    ],
                  )
                : Container(),
          ),
        ),
      ),
    );
  }
}
