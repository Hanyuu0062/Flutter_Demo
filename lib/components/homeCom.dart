import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

import '../utils/fileCommunicate.dart';
import '../utils/requests.dart';

class HomeCom extends StatefulWidget {
  HomeCom({required this.imgData});

  final ValueNotifierData imgData;

  @override
  _HomeComState createState() => _HomeComState();
}

class _HomeComState extends State<HomeCom> {
  File? _imageFile;

  String? _picUrl;

  Image? _image;

  bool _isUrl = false;

  final TextEditingController _urlController = TextEditingController();

  String? _resStr = "你好呀！";

  bool _syncIdentify = true;

  final picker = ImagePicker();

  @override
  initState() {
    super.initState();
    widget.imgData.addListener(_handleValueChanged);
  }

  @override
  dispose() {
    widget.imgData.removeListener(_handleValueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 330,
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 9, left: 9, top: 5),
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xffeef0f7),
                    borderRadius: BorderRadius.circular(3.0), //3像素圆角
                    boxShadow: [
                      //阴影
                      BoxShadow(
                        color: Colors.black54,
                        offset: Offset(0, .0),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center, // 居中对齐
                        child: _image == null
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 112),
                                child: Column(
                                  children: [
                                    const Text("请选择要识别的图片"),
                                    IconButton(
                                      onPressed: _choiceDialog,
                                      icon: Icon(Icons.add),
                                    )
                                  ],
                                ),
                              )
                            : ClipRect(
                                child: _image,
                              ), // 居中的Widget
                      ),
                      Align(
                        alignment: Alignment.topRight, // 居中对齐
                        child: IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            if (_image != null) _choiceDialog();
                          },
                        ), // 居中的Widget
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.square_outlined),
                      label: const Text(
                        "识图一下",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _handleIdentify,
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.0), // 设置圆角大小
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
              width: double.infinity,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'lib/assets/t.png',
                      height: 100,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 60.0, left: 60.0, right: 20),
                    // 距离左上角的宽高各20
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // 白色背景色
                        border:
                            Border.all(color: Color(0xffafe0ff), width: 2.0),
                        // 红色边框
                        borderRadius:
                            BorderRadius.all(Radius.circular(22.0)), // 圆角
                      ),
                      width: double.infinity, // 你可以根据需要设置宽度
                      height: 150.0, // 你可以根据需要设置高度
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(
                          "$_resStr",
                          textScaleFactor: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  void _writeUrl() {
    //  TODO: 建一个对话框，输入URl 然后回显图片
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('请输入url'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: "请输入url",
                  ),
                  obscureText: false,
                ),
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    _picUrl = _urlController.text;
                    _isUrl = true;
                    Navigator.of(context).pop();
                    if (_picUrl != "") {
                      setState(() {
                        _image = Image.network(_picUrl!);
                      });
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _choiceDialog() {
    // 显示对话框，让用户选择上传类型
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择上传类型'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: const Text("图片"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(); // 用户选择图片上传
                  },
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                GestureDetector(
                  child: const Text("url"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _writeUrl(); // 用户选择图片上传
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    // 从相册选图
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _isUrl = false;
      setState(() {
        _imageFile = File(pickedFile.path);
        _image = Image.file(_imageFile!);
      });
    }
  }

  void _handleValueChanged() {
    // 和父节点通讯 来获取拍摄的图片
    setState(() {
      _imageFile = widget.imgData.value;
      _image = Image.file(_imageFile!);
    });
  }

  void _handleIdentify() async {
    // 向后端传图并识别

    //拒绝连点
    if (!_syncIdentify) {
      return;
    }

    //是否选图
    if ((_picUrl == "" || _picUrl == null) && _imageFile == null) {
      setState(() {
        _resStr = "咱就是说能先选个图吗";
      });
      return;
    }

    //反馈
    setState(() {
      _syncIdentify = !_syncIdentify;
      _resStr = "小三月正在努力识别中，请稍等";
    });
    if (_isUrl) {
      var tmp = await Request.upUrl(_picUrl!);
      if (tmp == "") tmp = "服务错误";
      setState(() {
        _resStr = tmp;
        _syncIdentify = true;
      });
    } else {
      var tmp = await Request.uploadPicture(_imageFile);
      if (tmp == "") tmp = "服务错误";
      setState(() {
        _resStr = tmp;
        _syncIdentify = true;
      });
    }
  }
}
