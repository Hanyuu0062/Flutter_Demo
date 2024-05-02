import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class Request<T> {
  static const String _head = "http://192.168.123.120:8295/";

  static Future<String> uploadPicture(File? imageFile) async {
    if (imageFile == null) {
      Fluttertoast.showToast(
          msg: "未选择图片",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return "";
    }
    String path = imageFile!.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    FormData formdata = FormData.fromMap(
      {
        "image": await MultipartFile.fromFile(path,
            filename: name, contentType: MediaType('image', 'jpeg'))
      },
    );

    BaseOptions option = BaseOptions(
        contentType: 'multipart/form-data', responseType: ResponseType.plain);

    Dio dio = Dio(option);

    try {
      var response = await dio
          .post<String>("${_head}image/classificationByFile", data: formdata);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "发送成功",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        var jsonData = response.data;
        Map<String, dynamic> jsonMap = jsonDecode(jsonData!);
        return jsonMap['data'];
      }
    } catch (e) {
      print("e:" + e.toString() + "   head=" + dio.options.headers.toString());
      return "";
    }
    return "";
  }

  static Future<String> upUrl(String url) async {
    FormData data = FormData.fromMap(
      {"url": url},
    );

    BaseOptions option = BaseOptions(responseType: ResponseType.plain);
    Dio dio = Dio(option);

    try {
      var response = await dio.post<String>("${_head}image/classificationByUrl",
          data: data);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "发送成功",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        var jsonData = response.data;
        Map<String, dynamic> jsonMap = jsonDecode(jsonData!);
        return jsonMap['data'];
      }
    } catch (e) {
      print("e:" + e.toString() + "   head=" + dio.options.headers.toString());
      return "";
    }
    return "";
  }

  static Future<List<dynamic>?> loadData(int pageNum, int pageSize) async {
    FormData data = FormData.fromMap({"page": pageNum, "pageSize": pageSize});

    BaseOptions option = BaseOptions(responseType: ResponseType.plain);
    Dio dio = Dio(option);

    try {
      var response =
          await dio.get<String>("${_head}image/getHistory", data: data);
      if (response.statusCode == 200) {
        var jsonData = response.data;
        // jsonMap为code data那一层
        Map<String,dynamic> jsonMap = jsonDecode(jsonData!);
        Map<String, dynamic> data = jsonMap['data'];
        return data['records'];
      }
    } catch (e) {
      print("e:" + e.toString() + "   head=" + dio.options.headers.toString());
    }
    return null;
  }
}
