import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

import 'package:flutter/material.dart';
import 'refresh.dart';
import '../utils/requests.dart';

class historyCom extends StatefulWidget {
  @override
  _historyComState createState() => _historyComState();
}

class _historyComState extends State<historyCom> {
  @override
  Widget build(BuildContext context) {
    return LoadListView<dynamic>(
      pageSize: 4,
      refreshOnStart: true,
      emptyWidget: const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Text('此处空空如也'),
        ),
      ),
      onRefreshData: (pageNum, pageSize) async {
        return loadData(pageNum, pageSize);
      },
      onLoadData: (pageNum, pageSize) async {
        return loadData(pageNum, pageSize);
      },
      itemBuilder: (context, count, index, data) {
        return Container(
          alignment: Alignment.center,
          height: 150,
          child: Container(
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
            height: 140,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  width: 100,
                  child: ClipRect(
                    child: Image.network(
                        "http://192.168.123.120:8295" + data["imagePath"]!),
                  ),
                ),
                Container(
                  width: 250,
                  height: 120,
                  padding: EdgeInsets.only(top: 35),
                  child: Column(
                    children: [
                      Text(
                        "结果："+data["result"]!,
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        "识别时间："+data["time"]!,
                        style: TextStyle(fontSize: 14),
                      ),

                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<dynamic>> loadData(int pageNum, int pageSize) async {
    var list = await Request.loadData(pageNum, pageSize);
    if (list != null) {
      return list;
    } else {
      return [];
    }
  }
}
