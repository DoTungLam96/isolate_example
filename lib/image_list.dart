import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:isolated_flutter/model/film_model.dart';
import 'package:isolated_flutter/model/photo_model.dart';
import 'package:isolated_flutter/widget/list_photo.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'isolate_read_file/image_screen.dart';

const JSON_1MB_PATH = "assets/jsons/json_1_mb.json";
const JSON_5MB_PATH = "assets/jsons/json_5_mb.json";

class ImageListWidget extends StatefulWidget {
  const ImageListWidget({super.key});

  @override
  State<ImageListWidget> createState() => _ImageListWidgetState();
}

class _ImageListWidgetState extends State<ImageListWidget> {
  final client = Client();

  List<Photo> listPhoto = [];

  List<FilmModel> filmModels = [];

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "List of photos",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Total: $count",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      count += 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.orange,
                    alignment: Alignment.center,
                    child: Text(
                      "Count",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final data = await fetchPhotos(client);
                    print("Async press");
                    setState(() {
                      listPhoto = data;
                    });
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: Text(
                        "Async",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                      )),
                ),
                InkWell(
                  onTap: () async {
                    final data = await fetchPhotosWithCompute(client);
                    print("Compute press");
                    setState(() {
                      listPhoto = data;
                    });
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.blueGrey,
                      alignment: Alignment.center,
                      child: Text(
                        "Compute",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                      )),
                ),
                InkWell(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ImageScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.brown,
                    alignment: Alignment.center,
                    child: Text(
                      "Isolate",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            if (listPhoto.isEmpty && filmModels.isNotEmpty) ...[
              const SizedBox(
                height: 32,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.centerLeft,
                child: Text(
                  filmModels.isEmpty ? "Photo(${listPhoto.length}) " : "Data(${filmModels.length}) ",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.black, fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filmModels.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(filmModels[index].name ?? ""));
                  },
                ),
              ),
            ],
            if (listPhoto.isNotEmpty && filmModels.isEmpty) ...[
              const SizedBox(
                height: 32,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Photos: ",
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
            ]
          ],
        ),
      ),
    );
  }

  //spawn read large file
  Future<List<FilmModel>> parseJsonInBackground(String jsonString) async {
    final ReceivePort receivePort = ReceivePort();

    await Isolate.spawn(_parseJsonWithIsolate, [receivePort.sendPort, jsonString]);

    return await receivePort.first;
  }

  List<FilmModel> _parseJsonWithoutIsolate(String jsonString) {
    List<FilmModel> lstFilmModel = [];
    for (int i = 0; i < 10000000; i++) {
      final List<dynamic> lstJsonModel = json.decode(jsonString);

      final data = lstJsonModel.map((e) {
        return FilmModel.fromJson(e);
      }).toList();

      lstFilmModel = [];

      lstJsonModel.add(data);
    }

    return lstFilmModel;
  }

  static _parseJsonWithIsolate(List<dynamic> args) {
    for (int i = 0; i < 10000000; i++) {
      if (args.length > 1) {
        SendPort sendPort = args[0];
        String jsonString = args[1];

        final List<dynamic> lstJsonModel = json.decode(jsonString);

        if (lstJsonModel.length > 1) {
          final lstFilmModel = lstJsonModel.map((e) {
            return FilmModel.fromJson(e);
          }).toList();
          sendPort.send(lstFilmModel);
        }
      }
    }
  }

  //Cách gọi thường thấy trên main thread
  Future<List<Photo>> fetchPhotos(Client client) async {
    final response =
        await client.get(Uri.parse('https://jsonplaceholder.typicode.com/photos')).timeout(const Duration(seconds: 5));

    return parsePhotos(response.body);
  }

  //cách gọi compute sử dụng isolate compute
  Future<List<Photo>> fetchPhotosWithCompute(Client client) async {
    final response =
        await client.get(Uri.parse('https://jsonplaceholder.typicode.com/photos')).timeout(const Duration(seconds: 5));

    return compute(parsePhotoCompute, response.body);
  }

  // A function that converts a response body into a List<Photo>.
  List<Photo> parsePhotos(String responseBody) {
    for (var i = 0; i < 1000000; i++) {
      print("Using async: $i");
    }
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
  }
}

//Hàm sử dụng trong compute phải là top-funtion
List<Photo> parsePhotoCompute(String responseBody) {
  // for (var i = 0; i < 1000000; i++) {
  //   print("Compute: $i");
  // }
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}
