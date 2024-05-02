import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

import 'picView.dart';

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  bool _syncCapture = true;

  @override
  void initState() {
    super.initState();

    availableCameras().then((value) {
      setState(() {
        _cameras = value;
        // 默认使用后置摄像头
        _controller = CameraController(_cameras[0], ResolutionPreset.medium);
        _controller.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // 拍照的底层
  Future<XFile?> takePicture() async {
    if (!_controller.value.isInitialized) {
      return null;
    }

    if (_controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await _controller.takePicture();
      return file;
    } on CameraException catch (e) {
      return null;
    }
  }

  // 拍照
  Future<void> _capturePicture() async {
    if (!_syncCapture) return;
    _syncCapture = false;
    takePicture().then((XFile? file) async {
      if (mounted) {
        bool confirm = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PicView(imageFile: File(file!.path));
            },
          ),
        );
        if (confirm) {
          Navigator.pop(context, file);
        } else {
          _syncCapture = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('拍摄'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
          ),
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.white,
            child: Center(
              child: FloatingActionButton(
                onPressed: _capturePicture,
                child: const Icon(
                  Icons.circle_outlined,
                  size: 50,
                ),
              ), // 居中的Widget
            ),
          ),
        ],
      ),
    );
  }
}
