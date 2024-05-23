import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

File? imageFile;

class WidgetToImageConverter extends StatefulWidget {
  final SongModel song;
  const WidgetToImageConverter({
    super.key,
    required this.song,
  });

  @override
  _WidgetToImageConverterState createState() => _WidgetToImageConverterState();
}

class _WidgetToImageConverterState extends State<WidgetToImageConverter> {
  @override
  void initState() {
    super.initState();
  }

  final GlobalKey _widgetKey = GlobalKey();
  Uint8List? bytedata;
  bool captured = false;

  Future<void> _captureWidget() async {
    await Future.delayed(const Duration(seconds: 3));
    Fluttertoast.showToast(msg: "Capturing Image");
    RenderRepaintBoundary boundary =
        _widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 10.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8List = byteData!.buffer.asUint8List();

    setState(() {
      bytedata = uint8List;
    });
    _saveImageToFile(uint8List);
  }

  Future<void> _saveImageToFile(Uint8List uint8List) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/Artwork.png';
    File file = File(filePath);
    await file.writeAsBytes(uint8List);

    print('Image saved to: $filePath');
    setState(() {
      imageFile = file;
    });
    Fluttertoast.showToast(msg: "Image File Captured");
  }

  @override
  Widget build(BuildContext context) {
    if (!captured) {
      captured = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _captureWidget();
      });
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: ListTile(
              leading: RepaintBoundary(
                key: _widgetKey,
                child: QueryArtworkWidget(
                  id: widget.song.id,
                  type: ArtworkType.AUDIO,
                  artworkQuality: FilterQuality.high,
                  artworkHeight: 50,
                  artworkWidth: 50,
                  artworkFit: BoxFit.fitHeight,
                  artworkBorder: BorderRadius.circular(0),
                  nullArtworkWidget:
                      Image.asset("Assets/Images/blankArtwork.jpg"),
                ),
              ),
              textColor: Colors.white,
              title: Text(
                widget.song.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: Text(
                widget.song.artist!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          if (bytedata != null)
            Image.memory(
              bytedata!,
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width * 0.9,
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    bytedata = null;
    super.dispose();
  }
}

class UploadSong extends StatefulWidget {
  const UploadSong({super.key});

  @override
  State<UploadSong> createState() => _UploadSongState();
}

class _UploadSongState extends State<UploadSong> {
  String? downloadUrl;
  File? pickedFile;
  String imageurl = '';
  int likecount = 0;

  SongModel? song;
  UploadTask? uploadTask;
  FilePickerResult? result;
  OnAudioQuery audioQuery = OnAudioQuery();
  double uploadProgress1 = 0, uploadProgress2 = 0;
  List<File>? listFiles;
  int totalSongs = 0, current = 0;

  bool circularLoader = false;
  bool checkBoxValue = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      listFiles = null;
      uploadProgress1 = 0;
      uploadProgress2 = 0;
      song = null;
      imageFile = null;
      circularLoader = false;
      checkBoxValue = false;
      totalSongs = 0;
      current = 0;
    });
  }

  void pick() async {
    if (checkBoxValue) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );
      if (result == null) {
        return;
      } else {
        File convertedFile = File(result.files.first.path!);
        String currentfileName =
            convertedFile.path.split(Platform.pathSeparator).last;
        List<SongModel> songs = await audioQuery.querySongs(
          uriType: UriType.EXTERNAL,
        );
        List<File> list = [convertedFile];
        for (int j = 0; j < songs.length; j++) {
          if (songs[j].displayName == currentfileName) {
            setState(() {
              song = songs[j];
              listFiles = list;
            });
            break;
          }
        }
      }
    } else {
      try {
        String? directoryPath = await FilePicker.platform.getDirectoryPath();
        if (directoryPath != null && directoryPath.isNotEmpty) {
          Directory directory = Directory(directoryPath);
          try {
            List<FileSystemEntity> files = directory.listSync();

            List<File> list = files.whereType<File>().toList();

            for (var file in list) {
              print('File: ${file.path}');
            }

            setState(() {
              totalSongs != 0 ? listFiles = [] : null;
              listFiles = list;
            });
          } catch (e, stackTrace) {
            print(
                '***************************** Error loading files: $stackTrace');
          }
          Fluttertoast.showToast(
              msg: "Directory picked : ${directoryPath.split("/").last}");
        } else {
          showErrors("No Directory Selected");
        }
      } on Exception catch (e, stackTrace) {
        debugPrintStack(stackTrace: stackTrace);
        Fluttertoast.showToast(msg: "No Directory picked");
      }
    }
  }

  Future<bool> songExist(String name) async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("SongMetaData")
        .where("displayName", isEqualTo: name)
        .get();
    if (snap.size > 0) {
      return true;
    } else {
      return false;
    }
  }

  void uploadSingle() async {
    setState(() {
      current = 1;
      totalSongs = 1;
    });
    String currentfileName =
        listFiles!.last.path.split(Platform.pathSeparator).last;
    if (await songExist(currentfileName)) {
      Fluttertoast.showToast(msg: "Song Already Exists");
    } else {
      UploadTask uploadTask1 = FirebaseStorage.instance
          .ref()
          .child("Songs")
          .child(currentfileName)
          .putFile(listFiles!.last);
      uploadTask1.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          uploadProgress1 =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        });
      });
      TaskSnapshot taskSnapshot1 = await uploadTask1;
      String downloadUrl1 = await taskSnapshot1.ref.getDownloadURL();

      UploadTask uploadTask2 = FirebaseStorage.instance
          .ref()
          .child("Artworks")
          .child("${const Uuid().v1()}.jpg")
          .putFile(imageFile!);

      uploadTask2.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          uploadProgress2 =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        });
      });
      TaskSnapshot taskSnapshot2 = await uploadTask2;
      String downloadUrl2 = await taskSnapshot2.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("SongMetaData").add({
        "Like_Count": likecount,
        "displayName": song!.displayName,
        "title": song!.title,
        "lowerCaseTitle": song!.title.toLowerCase(),
        "track": song!.track,
        "id": song!.id,
        "album": song!.album,
        "artist": song!.artist,
        "composer": song!.composer,
        "duration": song!.duration,
        "fileExtension": song!.fileExtension,
        "isMusic": song!.isMusic,
        "isAlarm": song!.isAlarm,
        "isAudioBook": song!.isAudioBook,
        "isPodcast": song!.isPodcast,
        "isRingtone": song!.isRingtone,
        "size": song!.size,
        "dateAdded": song!.dateAdded,
        "songUrl": downloadUrl1,
        "artworkUrl": downloadUrl2,
      });
      Fluttertoast.showToast(
          msg:
              "Selected Song name : ${song!.displayName} Uploaded Successfully !!!");
      setState(() {
        uploadProgress1 = 0.0;
        uploadProgress2 = 0.0;
        pickedFile = null;
        song = null;
        imageFile = null;
      });
    }
    setState(() {
      current = 0;
      totalSongs = 0;
    });
  }

  void uploadMultiple() async {
    for (int i = 0; i < listFiles!.length; i++) {
      String currentfileName =
          listFiles![i].path.split(Platform.pathSeparator).last;
      setState(() {
        current = ++current;
        totalSongs = listFiles!.length;
      });
      if (await songExist(currentfileName)) {
        if (current == totalSongs) {
          Fluttertoast.showToast(msg: "All Songs Already Exist");
          break;
        }
        continue;
      } else {
        Fluttertoast.showToast(
            msg: "${current - 1} Songs Already Exists on the Server");
        List<SongModel> songs = await audioQuery.querySongs();
        for (int j = 0; j < songs.length; j++) {
          if (songs[j].displayName == currentfileName) {
            setState(() {
              song = songs[j];
              circularLoader = true;
            });
            break;
          }
        }
        UploadTask uploadTask1 = FirebaseStorage.instance
            .ref()
            .child("Songs")
            .child(currentfileName)
            .putFile(listFiles![i]);
        uploadTask1.snapshotEvents.listen((TaskSnapshot snapshot) {
          setState(() {
            uploadProgress1 =
                (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          });
        });
        TaskSnapshot taskSnapshot1 = await uploadTask1;
        String downloadUrl1 = await taskSnapshot1.ref.getDownloadURL();

        UploadTask uploadTask2 = FirebaseStorage.instance
            .ref()
            .child("Artworks")
            .child("${const Uuid().v1()}.jpg")
            .putFile(imageFile!);

        uploadTask2.snapshotEvents.listen((TaskSnapshot snapshot) {
          setState(() {
            uploadProgress2 =
                (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          });
        });
        TaskSnapshot taskSnapshot2 = await uploadTask2;
        String downloadUrl2 = await taskSnapshot2.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection("SongMetaData").add({
          "Like_Count": likecount,
          "displayName": song!.displayName,
          "title": song!.title,
          "lowerCaseTitle": song!.title.toLowerCase(),
          "track": song!.track,
          "id": song!.id,
          "album": song!.album,
          "artist": song!.artist,
          "composer": song!.composer,
          "duration": song!.duration,
          "fileExtension": song!.fileExtension,
          "isMusic": song!.isMusic,
          "isAlarm": song!.isAlarm,
          "isAudioBook": song!.isAudioBook,
          "isPodcast": song!.isPodcast,
          "isRingtone": song!.isRingtone,
          "size": song!.size,
          "dateAdded": song!.dateAdded,
          "songUrl": downloadUrl1,
          "artworkUrl": downloadUrl2,
        });
        Fluttertoast.showToast(
            msg:
                "Selected Song name : ${song!.displayName} Uploaded Successfully !!!");
        setState(() {
          uploadProgress1 = 0.0;
          uploadProgress2 = 0.0;
          song = null;
          imageFile = null;
          circularLoader = false;
        });
      }
    }
    setState(() {
      current = 0;
      totalSongs = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Upload Songs Here",
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple.shade800,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.deepPurple.shade800,
              Colors.deepPurple.shade200
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.width * 1.09,
                  child: (song != null)
                      ? WidgetToImageConverter(
                          song: song!,
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 60.0),
                          child: Image.asset(
                            "Assets/Images/blankArtwork.jpg",
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.width * 0.9,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(
                  height: 10,
                ),
                totalSongs != 0
                    ? Text("$current/$totalSongs Uploading",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold))
                    : const SizedBox(),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: pick,
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      minimumSize:
                          Size(MediaQuery.of(context).size.width * 0.89, 60)),
                  child: Text(checkBoxValue == false
                      ? "Select Songs Directory"
                      : "Select a Song"),
                ),
                const SizedBox(
                  height: 13,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (listFiles != null) {
                        if (checkBoxValue) {
                          uploadSingle();
                        } else {
                          uploadMultiple();
                        }
                      } else {
                        showErrors("No Files Selected");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepOrange.shade400,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.89, 60)),
                    child: const Text(
                        "Upload Song Fron Directory") // : const CircularProgressIndicator(color: Colors.white,strokeWidth: 3,),
                    ),
                const SizedBox(
                  width: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                  ),
                  child: CheckboxListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                    title: Text(
                      "Upload Only Selected file",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.white),
                    ),
                    value: checkBoxValue,
                    onChanged: (bool? newValue) {
                      setState(() {
                        checkBoxValue = newValue ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                imageFile != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Uploading Song Progress :',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              '${uploadProgress1.toStringAsFixed(2)}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                const SizedBox(height: 7),
                imageFile != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 30.0, left: 30.0),
                        child: LinearProgressIndicator(
                          value: uploadProgress1 / 100,
                          backgroundColor: Colors.white30,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Container(),
                const SizedBox(height: 15),
                imageFile != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Uploading Image Progress :',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              '${uploadProgress2.toStringAsFixed(2)}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                const SizedBox(height: 7),
                imageFile != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 30.0, left: 30.0),
                        child: LinearProgressIndicator(
                          value: uploadProgress2 / 100,
                          backgroundColor: Colors.white30,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showErrors(String error) {
    Fluttertoast.showToast(msg: "Error : $error");
  }
}
