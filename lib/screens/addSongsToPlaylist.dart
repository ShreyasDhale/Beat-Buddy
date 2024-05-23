import 'package:beat_buddy/models/ShowMessages.dart';
import 'package:beat_buddy/models/playerModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddToList extends StatefulWidget {
  const AddToList({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  State<AddToList> createState() => _AddToListState();
}

class _AddToListState extends State<AddToList> {
  bool isSearching = false;
  List<PlayerModel> songs = [];
  List<bool> checks = [];
  List<QueryDocumentSnapshot<Object?>> searchResults = [];
  QuerySnapshot<Map<String, dynamic>>? snapshot;

  Future<void> getSnapshot() async {
    snapshot =
        await FirebaseFirestore.instance.collection("SongMetaData").get();
  }

  @override
  void initState() {
    super.initState();
    getSnapshot();
  }

  void searchSongsByPartialTitle(String searchText) async {
    if (searchText == '') {
      setState(() {
        isSearching = false;
      });
    } else {
      setState(() {
        isSearching = true;
      });
    }
    String searchLowerCase = searchText.toLowerCase();

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('SongMetaData').get();

    var searchResult = querySnapshot.docs.where((doc) {
      String titleLowerCase = doc['title'].toString().toLowerCase();

      return titleLowerCase.contains(searchLowerCase);
    }).toList();
    setState(() {
      searchResults = searchResult;
    });
  }

  void initilizeChecks(int count) {
    for (int i = 0; i < count; i++) {
      checks.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          title: Text('Add Songs to -\n${widget.name}',
              style: GoogleFonts.poppins(color: Colors.white)),
          iconColor: Colors.white,
          backgroundColor: Colors.deepPurple,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Bar
              TextField(
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      isSearching = true;
                    } else {
                      isSearching = false;
                    }
                  });
                  searchSongsByPartialTitle(value);
                },
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search songs...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: isSearching
                    ? (searchResults.isNotEmpty)
                        ? ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              initilizeChecks(searchResults.length);
                              Map<String, dynamic> songData =
                                  searchResults[index].data()
                                      as Map<String, dynamic>;
                              return Container(
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: CheckboxListTile(
                                  onChanged: (value) {
                                    setState(() {
                                      checks[index] = value!;
                                    });
                                    if (value != null) {
                                      if (value == true) {
                                        songs.add(PlayerModel(
                                            songName: songData['title'],
                                            artist: songData['artist'],
                                            artworkUrl: songData['artworkUrl'],
                                            songUrl: songData['songUrl']));
                                      } else {
                                        songs.removeWhere((element) =>
                                            element.songName ==
                                            songData['title']);
                                      }
                                      print(songs);
                                    }
                                  },
                                  value: checks[index],
                                  title: Text(
                                    songData['title'],
                                    maxLines: 1,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    songData['artist'],
                                    maxLines: 1,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white60),
                                  ),
                                ),
                              );
                            },
                          )
                        : Text(
                            "Song Not Found",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold),
                          )
                    : StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("SongMetaData")
                            .orderBy("Like_Count", descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  initilizeChecks(snapshot.data!.docs.length);
                                  Map<String, dynamic> songData =
                                      snapshot.data!.docs[index].data();
                                  return Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: CheckboxListTile(
                                      onChanged: (value) {
                                        setState(() {
                                          checks[index] = value!;
                                        });
                                        if (value != null) {
                                          if (value == true) {
                                            songs.add(PlayerModel(
                                                songName: songData['title'],
                                                artist: songData['artist'],
                                                artworkUrl:
                                                    songData['artworkUrl'],
                                                songUrl: songData['songUrl']));
                                          } else {
                                            songs.removeWhere((element) =>
                                                element.songName ==
                                                songData['title']);
                                          }
                                          print(songs);
                                        }
                                      },
                                      value: checks[index],
                                      title: Text(
                                        songData['title'],
                                        maxLines: 1,
                                        style: GoogleFonts.poppins(
                                            color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        songData['artist'],
                                        maxLines: 1,
                                        style: GoogleFonts.poppins(
                                            color: Colors.white60),
                                      ),
                                    ),
                                  );
                                },
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
              )
            ],
          ),
          actions: [
            if (songs.isNotEmpty)
              ElevatedButton(
                  onPressed: () {
                    CollectionReference playlistSongs = FirebaseFirestore
                        .instance
                        .collection("Public_Playlists")
                        .doc(widget.name)
                        .collection("Songs");
                    for (var song in songs) {
                      playlistSongs.add(toMap(song));
                    }
                    MessageHandler.showSuccess(
                        context, "${songs.length} Added to ${widget.name}");
                    Navigator.pop(context);
                  },
                  child: Text("Add ${songs.length} songs")),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> toMap(PlayerModel model) {
    return {
      'title': model.songName,
      'artist': model.artist,
      'artworkUrl': model.artworkUrl,
      'songUrl': model.songUrl,
      // Add other properties as needed
    };
  }
}
