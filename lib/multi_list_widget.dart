// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:isolated_flutter/model/photo_model.dart';
import 'package:isolated_flutter/widget/list_photo.dart';
import 'package:isolated_flutter/widget/multi_image/list_image_first.dart';
import 'package:isolated_flutter/widget/multi_image/list_image_second.dart';

class MultipleImagesWidget extends StatefulWidget {
  const MultipleImagesWidget({super.key});

  @override
  State<MultipleImagesWidget> createState() => _MultipleImagesWidgetState();
}

class _MultipleImagesWidgetState extends State<MultipleImagesWidget> {
  final client = Client();

  List<Photo> listPhoto = [];

  List<Photo> listPhoto2 = [];

  int count = 0;

  @override
  void initState() {
    // _getListPhoto(delay: 5000);
    // _getListPhoto2(delay: 3000);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 8),
        child: Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            Container(width: MediaQuery.of(context).size.width, height: 250, child: ListImageFirst()),
            Divider(
              color: Colors.grey,
            ),
            Container(width: MediaQuery.of(context).size.width, height: 250, child: ListImageSecond()),
          ],
        ),
      ),
    );
  }
}
