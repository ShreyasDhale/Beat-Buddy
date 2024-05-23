import 'package:beat_buddy/screens/AudioPlayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:beat_buddy/models/playerModel.dart';
import 'package:beat_buddy/screens/home_screen.dart';
import 'package:beat_buddy/widgets/ImageLoader.dart';

class ViewMore extends StatefulWidget {
  final String title;
  final List<String> albums;
  const ViewMore({
    super.key,
    required this.title,
    required this.albums,
  });

  @override
  State<ViewMore> createState() => _ViewMoreState();
}

class _ViewMoreState extends State<ViewMore> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? snapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade800],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            )),
          ),
          Container(
            padding: const EdgeInsets.only(top: 40, right: 10, left: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        )),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(widget.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: Colors.white)),
                    ),
                    const Icon(
                      Icons.star,
                      size: 30,
                      color: Colors.orange,
                    ),
                  ],
                ),
                StreamBuilder(
                  stream: getTrending(widget.albums),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 20.0, bottom: 10),
                              child: ImageLoader(
                                imageUrl: snapshot.data!.docs.first
                                    .data()['artworkUrl'],
                                width: MediaQuery.of(context).size.width * 0.54,
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                radius: BorderRadius.circular(10),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(50)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "  ${snapshot.data!.docs.length} songs in ${widget.title}",
                                          maxLines: 1,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(color: Colors.white),
                                        ),
                                        Text(
                                          "   Lets Play !!",
                                          maxLines: 1,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        Map<String, dynamic> songData =
                                            snapshot.data!.docs.first.data();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => SongPlayer(
                                                    model: PlayerModel(
                                                        songName:
                                                            songData["title"],
                                                        artist:
                                                            songData["artist"],
                                                        artworkUrl: songData[
                                                            "artworkUrl"],
                                                        songUrl: songData[
                                                            "songUrl"]),
                                                    snapshot: snapshot.data!)));
                                      },
                                      icon: const Icon(
                                        Icons.play_circle_fill,
                                        color: Colors.white,
                                        size: 50,
                                      ))
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.50,
                              child: ListView.builder(
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
                                    child: HomeScreen.songListTile(
                                        songData, context),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        print("No data or snapshot is null!");
                        return const Text("No data !!");
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTrending(List<String> movies) {
    if (movies.isNotEmpty) {
      snapshot = FirebaseFirestore.instance
          .collection("SongMetaData")
          .where("album", whereIn: movies)
          .orderBy("title")
          .snapshots();
      return snapshot!;
    } else {
      snapshot = FirebaseFirestore.instance
          .collection("SongMetaData")
          .orderBy("Like_Count", descending: true)
          .limit(10)
          .snapshots();
      return snapshot!;
    }
  }
}

class PlayOrShuffel extends StatefulWidget {
  const PlayOrShuffel({
    super.key,
  });

  @override
  State<PlayOrShuffel> createState() => _PlayOrShuffelState();
}

class _PlayOrShuffelState extends State<PlayOrShuffel> {
  bool isPlay = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        setState(() {
          isPlay = !isPlay;
        });
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.06,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              left: isPlay ? 0 : width * 0.398,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.06,
                width: width * 0.40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Play',
                          style: TextStyle(
                              color: isPlay ? Colors.white : Colors.black,
                              fontSize: 17),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.play_circle,
                        color: isPlay ? Colors.white : Colors.black,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Shuffel',
                          style: TextStyle(
                              color: isPlay ? Colors.black : Colors.white,
                              fontSize: 17),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.shuffle,
                        color: isPlay ? Colors.black : Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
