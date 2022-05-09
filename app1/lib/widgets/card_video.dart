
import 'package:app1/feed/model/feed_model.dart';
import 'package:app1/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
class CardFeedVideoState extends StatefulWidget {
  CardFeedVideoState({Key? key, required this.controller})
      : super(key: key);
  //final String path;
  final VideoPlayerController controller;
  @override
  _CardFeedVideoState createState() => _CardFeedVideoState();
}

class _CardFeedVideoState extends State<CardFeedVideoState> {
  late VideoPlayerController _controller;
  bool doubleTap = false;
  //final isMuted = controller.;
  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.play();
    setState(() {
    });
  }

  @override
  void dispose(){
    _controller.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (_controller!=null && _controller.value.isInitialized)
        ? Container(
      alignment: Alignment.center,
      child: buildVideo(),
    )
        : Center(child: CircularProgressIndicator());
  }
  Widget buildVideo() => Stack(
    fit: StackFit.expand,
    children: [
      buildVideoPlayer(),
      buildIndicator()
    ],
  );
  Widget buildVideoPlayer() => AspectRatio(
    aspectRatio: _controller.value.aspectRatio,
    child: VideoPlayer(_controller),
  );
  Widget buildIndicator() => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _controller.value.isPlaying
          ?{_controller.pause(),setState(() {})}
          :{_controller.play(),setState(() {})},
      onDoubleTap: () => {
        doubleTap =!doubleTap,
        setState(() {})
      },
      child: Stack(
          children: [
          (doubleTap || (_controller.value.isPlaying==false))
          ?(
          _controller.value.isPlaying
              ?Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Icon(Icons.pause_circle_outline,size: 50,)
          )
              :Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Icon(Icons.play_circle_outline,size: 50,)
          )
      )
          :Container(),

      (doubleTap)
          ?(
          // tua ngược
          Positioned(
              bottom: 10,
              right: 150,
              left: 0,
              child: Icon(Icons.fast_rewind_outlined,size: 50,)
          )
       )
          : Container(),

      (doubleTap)
          ? (
          //tua
          Positioned(
              bottom: 10,
              right: 0,
              left: 150,
              child: Icon(Icons.fast_forward_outlined,size: 50,)
          )
          )
          :Container(),


      (doubleTap)
          ? (
          // bật tắt âm thanh
          Positioned(
              right: 10,
              bottom: 10,
              child: FloatingActionButton(
                child: _controller.value.volume == 0
              ? (Icon(Icons.volume_off,size: 25,))
              :(Icon(Icons.volume_up,size: 25,)),
              onPressed: () {
                _controller.value.volume == 0
                ? {
                    _controller.setVolume(100),
                  }
                : {
                   _controller.setVolume(0),
                };
              setState(() {});
              },
          ),
  )
  )
      :Container(),

  Positioned(
  bottom: 2,
  left: 0,
  right: 0,
  child: VideoProgressIndicator(
  _controller,
  allowScrubbing: true,
  ),
  ),
  ],
  ),
  );
  Widget buildPlay() =>_controller.value.isPlaying
      ?Container()
      :Container(
      alignment: Alignment.center,
      color: Colors.black54,
      child: Icon(Icons.play_circle_outline,size: 50,)
  );
}