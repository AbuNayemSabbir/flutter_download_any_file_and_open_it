import 'dart:io';

import 'package:dio/dio.dart';
import 'package:download_and_open/check_permission.dart';
import 'package:download_and_open/directory_path.dart';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as Path;

class DownloadFile extends StatefulWidget {
  DownloadFile({super.key});

  @override
  State<DownloadFile> createState() => _DownloadFileState();
}

class _DownloadFileState extends State<DownloadFile> {
  bool isPermission = false;
  var checkAllPermissions = CheckPermission();

  checkPermission() async {
    var permission = await checkAllPermissions.isStoragePermission();
    if (permission) {
      setState(() {
        isPermission = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  var dataList = [
    {
      "id": "1",
      "title": "file Video 1",
      "url": "https://download.samplelib.com/mp4/sample-10s.mp4"
    },
    {
      "id": "2",
      "title": "file PDF 2",
      "url":
          "https://www.iso.org/files/live/sites/isoorg/files/store/en/PUB100080.pdf"
    },
    {
      "id": "3",
      "title": "file PDF 3",
      "url": "https://www.tutorialspoint.com/javascript/javascript_tutorial.pdf"
    },
    {
      "id": "4",
      "title": "file APK 4",
      "url": "https://razibsoft.com/api/touch_less_public.apk"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Download any file & open"),
        ),
        body: isPermission
            ? Center(
                child: ListView.builder(
                    itemCount: dataList.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = dataList[index];
                      return DownloadList(
                        fileUrl: data['url']!,
                        title: data['title']!,
                      );
                    }),
              )
            : Center(
                child: TextButton(
                    onPressed: () {
                      checkPermission();
                    },
                    child: const Text("Permission issue")),
              ));
  }
}

class DownloadList extends StatefulWidget {
  DownloadList({super.key, required this.fileUrl, required this.title});

  final String fileUrl;
  final String title;

  @override
  State<DownloadList> createState() => _DownloadListState();
}

class _DownloadListState extends State<DownloadList> {
  bool downloading = false;
  bool fileExists = false;
  double progress = 0;
  String fileName = "";
  late String filePath;
  late CancelToken cancelToken;
  var getPathFile = DirectoryPath();

  startDownload() async {
    cancelToken = CancelToken();
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/$fileName';
    setState(() {
      downloading = true;
      progress = 0;
    });

    try {
      await Dio().download(widget.fileUrl, filePath,
          onReceiveProgress: (count, total) {
        setState(() {
          progress = (count / total);
        });
      }, cancelToken: cancelToken);
      setState(() {
        downloading = false;
        fileExists = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        downloading = false;
      });
    }
  }

  cancelDownload() {
    cancelToken.cancel();
    setState(() {
      downloading = false;
    });
  }

  checkFileExit() async {
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/$fileName';
    bool fileExistCheck = await File(filePath).exists();
    setState(() {
      fileExists = fileExistCheck;
    });
  }

  openfile() {
    OpenFile.open(filePath);
    print("fff $filePath");
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      fileName = Path.basename(widget.fileUrl);
    });
    checkFileExit();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: Colors.grey.shade100,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () {
                fileExists && !downloading ? openfile() : cancelDownload();
              },
              icon: fileExists && !downloading
                  ? const Icon(
                Icons.window,
                color: Colors.green,
              )
                  : const Icon(Icons.close),
            ),
            SizedBox(width: 16),
            Container(
              width: 100,
              child: fileExists
                  ? const Icon(
                Icons.save,
                color: Colors.green,
              )
                  : downloading
                  ? Column(
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: Colors.grey,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              )
                  : IconButton(
                onPressed: () {
                  startDownload();
                },
                icon: const Icon(Icons.download),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
