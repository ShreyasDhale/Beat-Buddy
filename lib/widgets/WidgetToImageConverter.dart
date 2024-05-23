import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

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
  final GlobalKey _widgetKey = GlobalKey();
  Uint8List? _imageBytes;

  Future<void> _captureWidget() async {
    Fluttertoast.showToast(msg: "Capturing Image");
    RenderRepaintBoundary boundary =
        _widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 10.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8List = byteData!.buffer.asUint8List();

    setState(() {
      _imageBytes = uint8List;
    });

    _saveImageToFile(uint8List);
  }

  Future<void> _saveImageToFile(Uint8List uint8List) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/Artwork.png';
    File file = File(filePath);
    await file.writeAsBytes(uint8List);

    print('Image saved to: $filePath');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RepaintBoundary(
            key: _widgetKey,
            child:
                QueryArtworkWidget(id: widget.song.id, type: ArtworkType.AUDIO),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: _captureWidget,
            child: const Text('Convert to Image'),
          ),
          const SizedBox(height: 20.0),
          if (_imageBytes != null)
            Image.memory(
              _imageBytes!,
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width * 0.9,
            )
        ],
      ),
    );
  }
}
