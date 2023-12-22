import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PermissionExample(),
    );
  }
}

class PermissionExample extends StatefulWidget {
  @override
  _PermissionExampleState createState() => _PermissionExampleState();
}

class _PermissionExampleState extends State<PermissionExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permission Handling Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => requestCameraPermission(),
          child: Text('Request Camera Permission'),
        ),
      ),
    );
  }

  Future<void> requestCameraPermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final androidVersion = androidInfo.version.release;
      print('Android version::: $androidVersion');
      if (int.parse(androidVersion!) > 10) {
        print("Android version 11 and up and for iOS");
        var statusmanageExternalStorage =
            await Permission.manageExternalStorage.request();
        if (statusmanageExternalStorage.isGranted) {
          print("--status.isGranted");
          myStorageAppCode();
        } else if (statusmanageExternalStorage.isDenied) {
          print("--status.isDenied");
          // myStorageAppCode();
        } else if (statusmanageExternalStorage.isPermanentlyDenied) {
          print("--status.isPermanentlyDenied");
          openAppSettings();
        } else {
          print(
              "--Else statusmanageExternalStorage ${statusmanageExternalStorage}");
        }
      } else {
        print("Android version 10 and below");
        var status = await Permission.storage.request();
        if (status.isGranted) {
          print("--status.isGranted");
          myStorageAppCode();
        } else if (status.isDenied) {
          print("--status.isDenied");
          // myStorageAppCode();
        } else if (status.isPermanentlyDenied) {
          print("--status.isPermanentlyDenied");
          openAppSettings();
        } else {
          print("--status in version 10 ${status}");
        }
      }
    } else {
      print("for iOS");
      // var state = await Permission.manageExternalStorage.status;
      var state2 = await Permission.storage.status;
      if (!state2.isGranted) {
        await Permission.storage.request();
      }
      // if (!state.isGranted) {
      //   await Permission.manageExternalStorage.request();
      // }
      if (state2.isGranted ) {
        print("for iOS state2.isGranted");
        myStorageAppCode();
      }else {
        print("Else iOS state2.isGranted");
      }
      // if (state.isGranted) {
      //   print("for iOS state.isGranted");
      // }
      // var status = await Permission.storage.request();
      // var statusmanageExternalStorage =
      //     await Permission.manageExternalStorage.request();
      // if (status.isGranted && statusmanageExternalStorage.isGranted) {
      //   print("--status.isGranted");
      //   myStorageAppCode();
      // } else if (status.isDenied && statusmanageExternalStorage.isDenied) {
      //   print("--status.isDenied");
      //   // myStorageAppCode();
      // } else if (status.isPermanentlyDenied &&
      //     statusmanageExternalStorage.isPermanentlyDenied) {
      //   print("--status.isPermanentlyDenied");
      //   openAppSettings();
      // } else {
      //   print(
      //       "--status in iOS ${status} statusmanageExternalStorage ${statusmanageExternalStorage}");
      // }
    }
  }

  myStorageAppCode() async {
    Directory? directory;
    if (Platform.isAndroid) {
      log("coming for android download");
      // if (await requestPermission(Permission.storage)) {
        // if (await _requestPermission(Permission.storage)) {
        directory = await getExternalStorageDirectory();
        String newPath = "";
        List<String> paths = directory!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/$folder";
            debugPrint("android folder not available $newPath");
          } else {
            break;
          }
        }
        newPath = "$newPath/Flutter SDK Demo";
        debugPrint("newPath $newPath");
        directory = Directory(newPath);
        debugPrint("directory $directory");
        if (!await directory.exists()) {
          try {
            await directory.create(recursive: true);
          } on Exception catch (e) {
            log("eeeee: ${e}");
            // TODO
          }
          debugPrint("directory created");
        } else {
          debugPrint("else not created");
        }
        if (await directory.exists()) {
          log("coming in directory exists");
          File saveFile = File("${directory.path}/SDKDemo.zip");
          var req = await http.Client().get(
              Uri.parse("https://golang.org/dl/go1.17.3.windows-amd64.zip"));
          // var file = File('$_dir/$fileName');
          log("saveFilePath ${saveFile.path}");
          // debugPrint("saveFilePath ${saveFile.path} req ${req.bodyBytes}");
          await saveFile.writeAsBytes(req.bodyBytes);
          return true;
        }
        return false;
      // } else {
      //   return false;
      // }
    } else {
      log("platform is ${Platform.isIOS}");
      // if (await requestPermission(Permission.storage)) {
        debugPrint("permission.storage");
        directory = await getApplicationDocumentsDirectory();
        if (!await directory.exists()) {
          debugPrint("haha");
          await directory.create(recursive: true);
          debugPrint("nana");
        } else {
          debugPrint("directory exist j nthi krti");
        }
        if (await directory.exists()) {
          debugPrint("directory path ${directory.path}");
          // File saveFile = File("${directory.path}/ZipTesting.zip");

          // setState(() {
          //   progressString = "Downloading...";
          // });
          File saveFile = File("${directory.path}/ZipTesting.zip");
          log("saveFile ${saveFile}");
          var req = await http.Client().get(
              Uri.parse("https://golang.org/dl/go1.17.3.windows-amd64.zip"));
          await saveFile.writeAsBytes(req.bodyBytes);
          // setState(() {
          //   progressString = "Download Complete";
          // });
          return true;

          // debugPrint("url ${url.toString()}");
          // await dio.download(url.toString(), saveFile.path,
          //     onReceiveProgress: (value1, value2) {
          //       // setState(() {
          //       progress = value1 / value2;
          //       EasyLoading.showProgress(
          //           progress, status: 'downloading...');
          //       notifyListeners();
          //       // });
          //     });
          // return true;
        } else {
          debugPrint("else iOS false");
          return false;
        }
      // } else {
      //   return false;
      // }
    }
  }
}
