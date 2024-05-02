import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class PicView extends StatefulWidget {
  File imageFile;

  PicView({required this.imageFile});

  @override
  _PicViewState createState() => _PicViewState(imageFile: imageFile);
}

class _PicViewState extends State<PicView> {
  File imageFile;

  _PicViewState({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("预览拍摄的图片")),
      body: Column(
        children: <Widget>[
          Expanded(child: Image.file(imageFile)),
          Container(
            width: double.infinity,
            height: 60,
            color: Colors.blue,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: IconButton(
                      icon: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {Navigator.pop(context, false);},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
