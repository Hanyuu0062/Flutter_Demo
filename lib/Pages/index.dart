import 'package:flutter/material.dart';
import 'dart:io';

import 'camera.dart';
import '../components/homeCom.dart';
import '../components/historyCom.dart';

import '../utils/fileCommunicate.dart';

class Index extends StatefulWidget {
  Index({super.key, required this.title});

  final String title;

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  int _curIndex = 0;

  /*
  父组件和子组件通信 , 在子组件中定义ValueNotifierData , 同时添加监听事件
  */
  ValueNotifierData imgData = ValueNotifierData(File("1"));

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeCom(imgData: imgData),
      historyCom(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: pages[_curIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(), // 底部导航栏打一个圆形的洞
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                setState(() {
                  _curIndex = 0;
                });
              },
            ),
            SizedBox(), //中间位置空出
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                setState(() {
                  _curIndex = 1;
                });
              },
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround, //均分底部导航栏横向空间
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCamera,
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> _handleCamera() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CameraApp();
        },
      ),
    );
    imgData.value = File(result.path);
  }
}
