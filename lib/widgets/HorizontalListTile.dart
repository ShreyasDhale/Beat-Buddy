import 'package:beat_buddy/screens/AudioPlayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:beat_buddy/models/playerModel.dart';
import 'package:beat_buddy/widgets/ImageLoader.dart';

class HorizontalSongListTile extends StatelessWidget {
  const HorizontalSongListTile({
    super.key,
    required this.songData,
  });

  final Map<String, dynamic> songData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: InkWell(
        onTap: () async {
          final snap = await FirebaseFirestore.instance
              .collection("SongMetaData")
              .orderBy("Like_Count", descending: true)
              .get();
          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SongPlayer(
                        model: PlayerModel(
                            artist: songData['artist'],
                            songName: songData['title'],
                            songUrl: songData['songUrl'],
                            artworkUrl: songData['artworkUrl']),
                        snapshot: snap,
                      )));
        },
        child: Column(
          children: [
            ImageLoader(
                imageUrl: songData["artworkUrl"],
                width: 170,
                height: 170,
                radius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            SizedBox(
                width: 170,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.zero,
                          topRight: Radius.zero,
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                      color: Colors.black.withOpacity(0.7)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      songData["title"],
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
