import 'package:beat_buddy/screens/AudioPlayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:beat_buddy/models/playerModel.dart';
import 'package:beat_buddy/screens/home_screen.dart';
import 'package:beat_buddy/widgets/HomeWidgets.dart';
import 'package:beat_buddy/widgets/section_header.dart';

// ignore: must_be_immutable
class likedSongs extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;

  likedSongs({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DiscoverMusic(),
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: SectionHeader(title: "Liked Songs", albums: []),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.deepPurple.shade800.withOpacity(0.5),
              Colors.deepPurple.shade200.withOpacity(0.5)
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: StreamBuilder(
              stream: getStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> songData =
                            snapshot.data!.docs[index].data();
                        return InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongPlayer(
                                model: PlayerModel(
                                  songName: songData["title"],
                                  artist: songData["artist"],
                                  artworkUrl: songData["artworkUrl"],
                                  songUrl: songData["songUrl"],
                                ),
                                snapshot: snapshot.data!,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: 14.0, left: 14.0),
                            child: HomeScreen.songListTile(songData, context),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Text("No Songs Found!!");
                  }
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                } else {
                  print("Connection state is not active!");
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
              },
            ),
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStream() {
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection("Users");
    DocumentReference currentUser = collectionReference.doc(user!.uid);
    Stream<QuerySnapshot<Map<String, dynamic>>> stream =
        currentUser.collection("Liked_Songs").snapshots();
    return stream;
  }
}
