// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:isolated_flutter/image_rotate.dart';

class Person {
  int? id;
  String? name;
  Person({
    this.id,
    this.name,
  });
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();

    List<Person> list = [
      Person(id: 1, name: "A"),
      Person(id: 12, name: "B"),
      Person(id: 2, name: "C"),
      Person(id: 3, name: "AAC"),
      Person(id: 6, name: "G"),
      Person(id: 8, name: "L"),
    ];

    final item = list.firstWhere((element) => element.id == 2);

    item.name = "Test data";
    item.id = 2333;

    // for (var i = 0; i < listClone.length; i++) {
    //   if (listClone[i].id == 2) {
    //     listClone[i].id = 1996;
    //     listClone[i].name = "LamDT";
    //     break;
    //   }
    // }
    // list = listClone;

    for (var element in list) {
      print(" ${element.id} - ${element.name}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: true,
        title: Text(
          "Home",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ImageRotate(),
            const SizedBox(
              height: 16,
            ),
            DemoWidget(),
            const SizedBox(
              height: 24,
            ),
            InkWell(
              onTap: () async {
                // int sum = 0;
                // for (int i = 0; i < 100000000000; i++) {
                //   sum += i;
                //   print(sum);
                // }

                await createIsolated();
              },
              child: Container(
                width: 120,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue),
                child: Text(
                  "On Press",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.white, fontSize: 14),
                ),
              ),
            )
          ]),
    );
  }

  ///worker isolated
  ///Top function or static function
  static void taskRunner(List<dynamic> param) {
    int sum = 0;

    var receivePort = ReceivePort();

    final sendPortFromMain = param[0] as SendPort;

    int n = param[1];

    sendPortFromMain.send(receivePort.sendPort);

    for (int i = 0; i < n; i++) {
      sum += i;
      // receivePort.sendPort.send(sum);
    }
    sendPortFromMain.send(sum);
    //listen data from main send to
    receivePort.listen((message) {
      print("[MessageIsolated] - $message");
    });
  }

  ///main isolated
  ///Main isolated giao tiếp với Worker isolated qua ReceivedPort và SendPort
  Future createIsolated() async {
    var receivePort = ReceivePort();

    final isolate =
        await Isolate.spawn(taskRunner, [receivePort.sendPort, 1000000]);

    // Future.delayed(
    //   const Duration(
    //     milliseconds: 100,
    //   ),
    //   () async {
    //     final result = await receivePort.first;
    //     print("result: ${result}");
    //   },
    // );

    //lang nghe msg gui tu isolated thread
    receivePort.listen((msg) {
      if (msg is SendPort) {
        msg.send("Đây là main thread");
      }
      print("msg: $msg");
    });
  }
}

class DemoWidget extends StatefulWidget {
  const DemoWidget({super.key});

  @override
  State<DemoWidget> createState() => _DemoWidgetState();
}

class _DemoWidgetState extends State<DemoWidget> {
  var count = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "count: $count",
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(
          height: 16,
        ),
        InkWell(
          onTap: () {
            setState(() {
              count += 1;
            });
          },
          child: Container(
            width: 150,
            height: 45,
            color: Colors.orange,
            child: Text(
              "Count now!",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium!
                  .copyWith(fontSize: 14),
            ),
          ),
        )
      ],
    );
  }
}
