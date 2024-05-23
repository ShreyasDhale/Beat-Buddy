import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:beat_buddy/widgets/HomeWidgets.dart';
import 'package:beat_buddy/screens/Playlist.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayLists extends StatefulWidget {
  const PlayLists({super.key});

  @override
  State<PlayLists> createState() => _PlayListsState();
}

class _PlayListsState extends State<PlayLists> {
  @override
  void initState() {
    super.initState();
    refreshLists();
  }

  Future<void> refreshLists() async {
    if (mounted) {
      await getPlayLists("priv");
      setState(() {
        PrivatePlaylists = Playlists;
      });
      await getPlayLists("public");
      setState(() {
        PublicPlaylists = Playlists;
      });
    }
  }

  bool screenVisible = false;

  void changeScreen() {
    setState(() {
      screenVisible = !screenVisible;
    });
  }

  List<Map<String, dynamic>> Playlists = [];
  List<Map<String, dynamic>> PublicPlaylists = [];
  List<Map<String, dynamic>> PrivatePlaylists = [];

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.deepPurple.shade800.withOpacity(0.5),
          Colors.deepPurple.shade200.withOpacity(0.5)
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: tabbedView(context));
  }

  Column tabbedView(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        screenVisible = false;
                      });
                      refreshLists();
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor:
                            screenVisible ? Colors.black : Colors.white,
                        backgroundColor: screenVisible
                            ? Colors.white
                            : Colors.black.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                color: Colors.white, width: 1.5)),
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.89, 60)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !screenVisible
                            ? const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 5,
                                    backgroundColor: Colors.green,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  )
                                ],
                              )
                            : const SizedBox(),
                        const Text("Public PlayList"),
                      ],
                    )),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 5,
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        screenVisible = true;
                      });
                      refreshLists();
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor:
                            !screenVisible ? Colors.black : Colors.white,
                        backgroundColor: !screenVisible
                            ? Colors.white
                            : Colors.black.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                color: Colors.white, width: 1.5)),
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.89, 60)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        screenVisible
                            ? const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 5,
                                    backgroundColor: Colors.green,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  )
                                ],
                              )
                            : const SizedBox(),
                        const Text("Private PlayList"),
                      ],
                    )),
              ),
            ],
          ),
        ),
        const DiscoverMusic(),
        screenVisible
            ? Expanded(
                child: PrivatePlayLists(
                  playlists: PrivatePlaylists,
                ),
              )
            : Expanded(
                child: PublicPlayLists(
                  playlists: PublicPlaylists,
                ),
              ),
      ],
    );
  }

  Future<void> getPlayLists(String playlistType) async {
    QuerySnapshot docs;
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference collection = (playlistType == "public")
        ? FirebaseFirestore.instance.collection("Public_Playlists")
        : FirebaseFirestore.instance
            .collection("Users")
            .doc(user?.uid)
            .collection("Playlists");
    docs = await collection.get();
    List<Map<String, dynamic>> list = [];
    var documents = docs.docs;
    for (var doc in documents) {
      var name = doc.data() as Map<String, dynamic>;
      var snap = await collection.doc(name["Name"]).collection("Songs").get();
      if (snap.size > 0) {
        var first = snap.docs.first.data();
        int size = snap.docs.length;
        list.add({
          "name": name["Name"],
          "artwork": first["artworkUrl"],
          "size": size
        });
      } else {
        Fluttertoast.showToast(msg: "No PlayLists Found");
        break;
      }
    }
    setState(() {
      Playlists = list;
    });
    print(Playlists);
  }
}

class PublicPlayLists extends StatelessWidget {
  const PublicPlayLists({super.key, required this.playlists});
  final List<Map<String, dynamic>> playlists;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: ((context, index) {
                Map<String, dynamic> data = playlists[index];
                if (playlists.isNotEmpty) {
                  return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                          title: Text(
                            data["name"],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            "${data["size"]} Songs",
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                            ),
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              data["artwork"],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(10),
                          tileColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Playlist(
                                  name: data['name'],
                                  artwork: data['artwork'],
                                  count: data['size'],
                                  public: true,
                                ),
                              ),
                            );
                          }));
                } else {
                  return Center(
                      child: Text(
                    "No Private Playlists Found",
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 20),
                  ));
                }
              })),
        ),
      ],
    );
  }
}

class PrivatePlayLists extends StatelessWidget {
  const PrivatePlayLists({super.key, required this.playlists});
  final List<Map<String, dynamic>> playlists;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: ((context, index) {
                Map<String, dynamic> data = playlists[index];
                if (playlists.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Text(data["name"]),
                      subtitle: Text("${data["size"]} Songs"),
                      leading: Image.network(data["artwork"]),
                      contentPadding: const EdgeInsets.all(10),
                      tileColor: Colors.black87,
                      textColor: Colors.white,
                    ),
                  );
                } else {
                  return Center(
                      child: Text(
                    "No Private Playlists Found",
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 20),
                  ));
                }
              })),
        ),
      ],
    );
  }
}
