import 'package:beat_buddy/screens/AudioPlayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:beat_buddy/models/playerModel.dart';
import 'package:beat_buddy/screens/home_screen.dart';
import 'package:beat_buddy/widgets/AlbumListTile.dart';
import 'package:beat_buddy/widgets/HorizontalListTile.dart';
import 'package:beat_buddy/widgets/section_header.dart';

class AlbumsMusic extends StatefulWidget {
  const AlbumsMusic({super.key});

  @override
  _AlbumsMusicState createState() => _AlbumsMusicState();
}

class _AlbumsMusicState extends State<AlbumsMusic> {
  List<String> albums = [];
  List<String> artworkUrls = [];

  @override
  void initState() {
    super.initState();
    getAlbums();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 0.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 20),
              child: SectionHeader(
                title: 'Hot Albums',
                action: 'View More',
                albums: albums.isNotEmpty ? albums.sublist(0, 1) : [],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20, right: 20),
              width: 370,
              height: 250,
              child: albums.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    )) // Loading indicator
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        return horizontalAlbumCard(
                          artworkUrl: artworkUrls[index],
                          title: albums[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getAlbums() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('SongMetaData').get();

      List<String> tempAlbums = [];
      List<String> tempArtworkUrls = [];
      Set<String> uniqueAlbums = <String>{};

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String album = data['album'];
        String artworkUrl = data['artworkUrl'];

        if (!uniqueAlbums.contains(album)) {
          uniqueAlbums.add(album);
          tempAlbums.add(album);
          tempArtworkUrls.add(artworkUrl);

          if (uniqueAlbums.length >= 10) {
            break; // Stop iterating once you have 10 unique albums
          }
        }
      }

      setState(() {
        albums = tempAlbums;
        artworkUrls = tempArtworkUrls;
      });
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        setState(() {
          albums = [];
          artworkUrls = [];
        });
      }
    }
  }
}

// ignore: must_be_immutable
class TrendingMusic extends StatelessWidget {
  TrendingMusic({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>>? snapshot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 370,
      height: 298,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 0.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 20.0, top: 20),
              child: SectionHeader(
                title: 'Trending Music',
                action: 'View More',
                albums: [
                  "Animal",
                  "Jawan",
                  "Gadar 2",
                  "Tu Jhoothi Main Makkar"
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20, right: 20),
              width: 370,
              height: 250,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("SongMetaData")
                    .orderBy("Like_Count", descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> songData =
                              snapshot.data!.docs[index].data();
                          return HorizontalSongListTile(songData: songData);
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
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTrending(List<String> movies) {
    snapshot = FirebaseFirestore.instance
        .collection("SongMetaData")
        .orderBy("Like_Count", descending: true)
        .limit(10)
        .snapshots();
    return snapshot!;
  }
}

class DiscoverMusic extends StatefulWidget {
  const DiscoverMusic({super.key});

  @override
  State<DiscoverMusic> createState() => _DiscoverMusicState();
}

class _DiscoverMusicState extends State<DiscoverMusic> {
  bool isSearching = false;
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  "Enjoy your Favouraite Music",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  onChanged: searchSongsByPartialTitle,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search...',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Colors.grey.shade500),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                )
              ],
            )),
        isSearching
            ? Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "    Search Reasults : ",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: (searchResults.isNotEmpty)
                        ? ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> songData =
                                  searchResults[index].data()
                                      as Map<String, dynamic>;
                              return Padding(
                                padding: const EdgeInsets.only(
                                    right: 14.0, left: 14.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SongPlayer(
                                          model: PlayerModel(
                                            songName: songData["title"],
                                            artist: songData["artist"],
                                            artworkUrl: songData["artworkUrl"],
                                            songUrl: songData["songUrl"],
                                          ),
                                          snapshot: snapshot!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: HomeScreen.songListTile(
                                      songData, context),
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
                          ),
                  ),
                ],
              )
            : const SizedBox(
                height: 0,
                width: 0,
              ),
      ],
    );
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
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.deepPurple.shade900,
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.white,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline),
          label: 'Play',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const _CustomAppbar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const Icon(
        Icons.grid_view_rounded,
        color: Colors.white,
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          child: const CircleAvatar(
            backgroundImage:
                NetworkImage('https://www.w3schools.com/howto/img_avatar.png'),
          ),
        )
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(56.0);
}
