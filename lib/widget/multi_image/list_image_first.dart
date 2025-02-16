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

class ListImageFirst extends StatefulWidget {
  const ListImageFirst({super.key});

  @override
  State<ListImageFirst> createState() => _ListImageFirstState();
}

class _ListImageFirstState extends State<ListImageFirst> {
  final client = Client();

  List<Photo> listPhoto = [];

  @override
  void initState() {
    _getListPhoto();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 8),
      child: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          _buildListPhotos()
        ],
      ),
    );
  }

  Widget _buildListPhotos() {
    if (listPhoto.isNotEmpty) {
      return Expanded(
        child: Column(
          children: [
            const SizedBox(
              height: 32,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: Text(
                "Photos 1: ",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.black, fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
                child: ListPhoto(
              listPhoto: listPhoto,
            )),
          ],
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  void _getListPhoto() async {
    final data = await fetchPhotos(client);
    print("Async press");

    Future.delayed(
      Duration(milliseconds: 3000),
      () {
        setState(() {
          listPhoto = data;
        });
      },
    );
  }

  //Cách gọi thường thấy trên main thread
  Future<List<Photo>> fetchPhotos(Client client) async {
    final response =
        await client.get(Uri.parse('https://jsonplaceholder.typicode.com/photos')).timeout(const Duration(seconds: 5));

    return parsePhotos(response.body);
  }

  List<Photo> parsePhotos(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
  }
}
