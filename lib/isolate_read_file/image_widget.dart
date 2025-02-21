import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'pick_image_mixin.dart';
import 'utils.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({
    super.key,
  });

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> with PickImageMixin {
  double _progress = 0.0;

  bool _isReading = false; // Trạng thái đọc file

  Isolate? _isolate;

  ReceivePort? receivePort;

  File? _imageFile;

  late PermissionStatus permissionStatus;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      GetIt.instance.registerLazySingleton<PickImageMixin>(() => this);

      _imageFile = await getImageFileFromAssets('assets/no_image.png');

      permissionStatus = await Utils.I.requestPermissionStorage();

      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildImage();
  }

  /// Xây dựng giao diện ảnh
  Widget _buildImage() {
    if (_imageFile == null) {
      return CircularPercentIndicator(
        radius: 50.0,
        lineWidth: 5.0,
        percent: _progress / 100,
        center: Text(
          "$_progress%",
          style: const TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
        ),
        progressColor: Colors.red,
      );
    }
    return Image.file(_imageFile!, fit: BoxFit.cover);
  }

  /// đọc file từ folder
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load(path);

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  /// Bắt đầu đọc file
  Future<void> _startReadingFile({required String pathFile}) async {
    if (_isReading == true) return;

    _isReading = true;

    _progress = 0.0;

    _imageFile = null;

    receivePort = ReceivePort();

    _isolate = await Isolate.spawn(_readFile, [receivePort!.sendPort, pathFile]);

    receivePort!.listen(
      (message) {
        if (message != null) {
          if (message is double) {
            setState(() {
              _progress = message;
              _imageFile = null;
            });
          }
          if (message is String) {
            setState(() {
              _imageFile = File(pathFile);
            });
          }
        } else {
          _isReading = false;

          _stopIsolate();
        }
      },
    );
  }

  ///Đọc ảnh bằng Isolated
  static void _readFile(List<dynamic> args) async {
    final SendPort sendPort = args[0];

    final String filePath = args[1];

    File file = File(filePath);

    if (!file.existsSync()) {
      sendPort.send(-1.0);
      return;
    }

    //tổng kích thước của file ảnh
    int fileSize = file.lengthSync();

    int bytesRead = 0;

    Stream<List<int>> inputStream = file.openRead().handleError((e) => print('Error reading file: $e'));

    await for (final event in inputStream) {
      bytesRead += event.length;

      double progress = double.parse(((bytesRead / fileSize) * 100).toStringAsFixed(2));

      sleep(const Duration(milliseconds: 70)); // Thêm delay cho dễ nhìn không load % nhanh quá

      sendPort.send(progress); // Gửi phần trăm về UI

      if (progress > 99) {
        sendPort.send(filePath);
      }
    }
    sendPort.send(null);
  }

  /// Giải phóng tài nguyên
  void _stopIsolate() {
    _isolate?.kill();

    _isReading = false;

    _progress = 0;
  }

  @override
  void pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _startReadingFile(pathFile: pickedFile.path);
    }
  }
}
