import 'package:beat_buddy/models/playerModel.dart';
import 'package:beat_buddy/screens/AudioPlayer.dart';
import 'package:beat_buddy/screens/addSongsToPlaylist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:beat_buddy/screens/home_screen.dart';
import 'package:beat_buddy/widgets/ImageLoader.dart';

class Playlist extends StatelessWidget {
  const Playlist(
      {super.key,
      required this.name,
      required this.artwork,
      required this.count,
      required this.public});
  final String name;
  final String artwork;
  final int count;
  final bool public;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(name),
        backgroundColor: Colors.deepPurple.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(fontSize: 23, color: Colors.white),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddToList(name: name)));
              },
              icon: const Icon(
                Icons.playlist_add_circle,
                color: Colors.white,
              ))
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.deepPurple.shade200,
              Colors.deepPurple.shade800
            ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ImageLoader(
                  imageUrl: artwork,
                  width: 270,
                  height: 270,
                  radius: BorderRadius.circular(20),
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(50)),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(20),
                  child: ListTile(
                    title: Text("This Playlist Contains \n$count Songs"),
                    textColor: Colors.white,
                    trailing: IconButton(
                        onPressed: () async {
                          print("Hello");

                          QuerySnapshot snapshot = await FirebaseFirestore
                              .instance
                              .collection("Public_Playlists")
                              .doc(name)
                              .collection("Songs")
                              .get();
                          Map<String, dynamic> songData = snapshot.docs.first
                              .data() as Map<String, dynamic>;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SongPlayer(
                                      model: PlayerModel(
                                          songName: songData['title'],
                                          artist: songData['artist'],
                                          artworkUrl: songData['artworkUrl'],
                                          songUrl: songData['songUrl']),
                                      snapshot: snapshot)));
                        },
                        icon: const Icon(
                          Icons.play_circle_fill_rounded,
                          size: 40,
                          color: Colors.white,
                        )),
                  )),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Public_Playlists")
                      .doc(name)
                      .collection("Songs")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> songData =
                                  snapshot.data!.docs[index].data();
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SongPlayer(
                                                  model: PlayerModel(
                                                      artist:
                                                          songData['artist'],
                                                      songName:
                                                          songData['title'],
                                                      songUrl:
                                                          songData['songUrl'],
                                                      artworkUrl: songData[
                                                          'artworkUrl']),
                                                  snapshot: snapshot.data!)));
                                    },
                                    child: HomeScreen.songListTile(
                                        songData, context)),
                              );
                            },
                          ),
                        );
                      } else {
                        return const Text("No Songs Yett !!");
                      }
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text(
                          "No data !!",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                  })
            ],
          ),
        ],
      ),
    );
  }
}
