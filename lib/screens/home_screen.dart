import 'package:beat_buddy/PlayerMethods/Queue.dart';
import 'package:beat_buddy/models/playerModel.dart';
import 'package:beat_buddy/screens/AudioPlayer.dart';
import 'package:beat_buddy/screens/Liked.dart';
import 'package:beat_buddy/screens/PlayListScreen.dart';
import 'package:beat_buddy/screens/ReferFrends.dart';
import 'package:beat_buddy/screens/profile.dart';
import 'package:beat_buddy/screens/viewMore.dart';
import 'package:beat_buddy/widgets/HomeWidgets.dart';
import 'package:beat_buddy/widgets/ImageLoader.dart';
import 'package:beat_buddy/widgets/SideBar.dart';
import 'package:beat_buddy/widgets/section_header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static String convertDuration(int durationInMilliseconds) {
    int durationInSeconds =
        (durationInMilliseconds ~/ 1000); // Convert milliseconds to seconds
    int minutes = (durationInSeconds ~/ 60);
    int seconds = durationInSeconds % 60;
    return '$minutes:${seconds < 10 ? '0' : ''}$seconds';
  }

  static Container songListTile(
      Map<String, dynamic> songData, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withOpacity(0.5),
      ),
      child: ListTile(
          leading: ImageLoader(
            imageUrl: songData['artworkUrl'],
            width: 60,
            height: 60,
            radius: BorderRadius.circular(10),
          ),
          title: Text(
            songData["title"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
          subtitle: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Container(
                  color: Colors.white,
                  child: Text(
                    " LYRICS ",
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    "  ${songData["artist"]}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        color: Colors.white60, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          trailing: BottomMenu(
            songData: songData,
          )),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  String title = '';
  String profilePic = '';

  @override
  initState() {
    super.initState();
    fetchPhoneNumberFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepPurple.shade900.withOpacity(0.8),
            Colors.deepPurple.shade200.withOpacity(0.8)
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _CustomAppbar(title, profilePic, changeScreen),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.deepPurple.shade900,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          showUnselectedLabels: false,
          onTap: changeScreen,
          showSelectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: (currentIndex == 0)
                  ? const Icon(
                      Icons.home,
                      color: Colors.green,
                    )
                  : const Icon(Icons.home_outlined),
              label: 'home',
            ),
            BottomNavigationBarItem(
              icon: (currentIndex == 1)
                  ? const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                  : const Icon(Icons.favorite_outline),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: (currentIndex == 2)
                  ? const Icon(Icons.play_circle)
                  : const Icon(Icons.play_circle_outline),
              label: 'Play',
            ),
            BottomNavigationBarItem(
              icon: (currentIndex == 3)
                  ? const Icon(Icons.people)
                  : const Icon(Icons.people_outline),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: (currentIndex == 4)
                  ? const Icon(Icons.person)
                  : const Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
        body: pages[currentIndex],
        drawer: const SideBar(),
      ),
    );
  }

  final List<Widget> pages = [
    const HomeScreenWidget(),
    likedSongs(),
    const PlayLists(),
    const ContactListScreen(),
    const profile(),
  ];

  void fetchPhoneNumberFromFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference users = firestore.collection('Users');

      DocumentSnapshot snapshot = await users.doc(user.uid).get();

      if (snapshot.exists) {
        setState(() {
          if (snapshot['Name'].toString() != "") {
            title = snapshot['Name'];
          } else {
            title = "+91 ${snapshot['Phone']}";
          }
          profilePic = snapshot['profilePicUrl'];
        });
      }
    }
  }

  void changeScreen(int value) {
    setState(() {
      currentIndex = value;
    });
  }
}

class CreatePlayListWidget extends StatefulWidget {
  final PlayerModel model;
  const CreatePlayListWidget({super.key, required this.model});

  @override
  State<CreatePlayListWidget> createState() => _CreatePlayListWidgetState();
}

class _CreatePlayListWidgetState extends State<CreatePlayListWidget> {
  TextEditingController playListController = TextEditingController();
  bool checkBoxValue = false;
  List<String> dropdownItems = ['Default 1', 'Default 2'];
  String? _selectedDropdownItem;

  Future<void> getPlaylists() async {
    User? user = FirebaseAuth.instance.currentUser;
    QuerySnapshot snap1 =
        await FirebaseFirestore.instance.collection("Public_Playlists").get();
    QuerySnapshot snap2 = await FirebaseFirestore.instance
        .collection("Users")
        .doc(user?.uid)
        .collection("Playlists")
        .get();
    if (snap1.docs.isNotEmpty || snap2.docs.isNotEmpty) {
      setState(() {
        dropdownItems = [];
      });
      if (snap1.docs.isNotEmpty) {
        for (int i = 0; i < snap1.docs.length; i++) {
          Map<String, dynamic> data =
              snap1.docs[i].data() as Map<String, dynamic>;
          if (dropdownItems.contains(data['Name'])) {
            continue;
          } else {
            setState(() {
              dropdownItems.add(data['Name']);
            });
          }
        }
      }
      if (snap2.docs.isNotEmpty) {
        for (int i = 0; i < snap2.docs.length; i++) {
          Map<String, dynamic> data =
              snap2.docs[i].data() as Map<String, dynamic>;
          if (dropdownItems.contains(data['Name'])) {
            continue;
          } else {
            setState(() {
              dropdownItems.add('${data['Name']} - Private');
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    getPlaylists();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.deepPurple.shade400,
      title: const Text(
        'Create A New PlayList / Add in Existing',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.48,
          child: Column(children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white60, // Border color
                  width: 2.0, // Border width
                ),
                borderRadius: BorderRadius.circular(8.0), // Border radius
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: playListController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Playlist Name',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.grey.shade500),
                        prefixIcon: Icon(
                          Icons.playlist_add_check,
                          color: Colors.grey.shade800,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: Text(
                        'Create Publically',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.white),
                      ),
                      value: checkBoxValue,
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                      onChanged: (bool? newValue) {
                        setState(() {
                          checkBoxValue = newValue ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.deepOrange.shade400,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * 0.18,
                                  40)),
                          onPressed: () {
                            // Process the text and checkbox value as needed
                            String enteredText = playListController.text;
                            print('Entered Text: $enteredText');
                            print('Checkbox Value: $checkBoxValue');
                            if (enteredText != '') {
                              try {
                                if (checkBoxValue) {
                                  FirebaseFirestore.instance
                                      .collection("Public_Playlists")
                                      .doc(enteredText)
                                      .set({"Name": enteredText}).then((_) =>
                                          FirebaseFirestore.instance
                                              .collection("Public_Playlists")
                                              .doc(enteredText)
                                              .collection("Songs")
                                              .add({
                                            "title": widget.model.songName,
                                            "artist": widget.model.artist,
                                            "artworkUrl":
                                                widget.model.artworkUrl,
                                            "songUrl": widget.model.songUrl,
                                          }));

                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                      msg:
                                          "${widget.model.songName} Added to PlayList $enteredText");
                                } else {
                                  User? user =
                                      FirebaseAuth.instance.currentUser;
                                  FirebaseFirestore.instance
                                      .collection("Users")
                                      .doc(user!.uid)
                                      .collection("Playlists")
                                      .doc(enteredText)
                                      .set({"Name": enteredText}).then((_) =>
                                          FirebaseFirestore.instance
                                              .collection("Users")
                                              .doc(user.uid)
                                              .collection("Playlists")
                                              .doc(enteredText)
                                              .collection("Songs")
                                              .add({
                                            "title": widget.model.songName,
                                            "artist": widget.model.artist,
                                            "artworkUrl":
                                                widget.model.artworkUrl,
                                            "songUrl": widget.model.songUrl,
                                          }));
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                      msg:
                                          "${widget.model.songName} Added to PlayList $_selectedDropdownItem");
                                }
                              } catch (e) {
                                Fluttertoast.showToast(msg: e.toString());
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please Enter Playlist Name");
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    )
                  ]),
            ),
            if (dropdownItems.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white60, // Border color
                    width: 2.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(8.0), // Border radius
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(15.0), // Border radius
                        color: Colors.white, // Fill color
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              hint: const Text(
                                  'Select a Play List...                 '),
                              value: _selectedDropdownItem,
                              items: dropdownItems
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(item),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDropdownItem = value;
                                });
                              },
                              style: const TextStyle(
                                  color: Colors.black), // Text color
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.black), // Dropdown arrow color
                              underline: Container(
                                // Remove underline
                                height: 0,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.deepOrange.shade400,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width * 0.09,
                                    40)),
                            onPressed: () {
                              if (_selectedDropdownItem != null) {
                                try {
                                  if (!_selectedDropdownItem!
                                      .endsWith("Private")) {
                                    FirebaseFirestore.instance
                                        .collection("Public_Playlists")
                                        .doc(_selectedDropdownItem)
                                        .set({
                                      "Name": _selectedDropdownItem
                                    }).then((_) => FirebaseFirestore.instance
                                                .collection("Public_Playlists")
                                                .doc(_selectedDropdownItem)
                                                .collection("Songs")
                                                .add({
                                              "title": widget.model.songName,
                                              "artist": widget.model.artist,
                                              "artworkUrl":
                                                  widget.model.artworkUrl,
                                              "songUrl": widget.model.songUrl,
                                            }));

                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                        msg:
                                            "${widget.model.songName} Added to PlayList $_selectedDropdownItem");
                                  } else {
                                    User? user =
                                        FirebaseAuth.instance.currentUser;
                                    FirebaseFirestore.instance
                                        .collection("Users")
                                        .doc(user!.uid)
                                        .collection("Playlists")
                                        .doc(_selectedDropdownItem)
                                        .set({
                                      "Name": _selectedDropdownItem
                                    }).then((_) => FirebaseFirestore.instance
                                                .collection("Users")
                                                .doc(user.uid)
                                                .collection("Playlists")
                                                .doc(_selectedDropdownItem)
                                                .collection("Songs")
                                                .add({
                                              "title": widget.model.songName,
                                              "artist": widget.model.artist,
                                              "artworkUrl":
                                                  widget.model.artworkUrl,
                                              "songUrl": widget.model.songUrl,
                                            }));
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                        msg:
                                            "${widget.model.songName} Added to PlayList $_selectedDropdownItem");
                                  }
                                } catch (e) {
                                  Fluttertoast.showToast(msg: e.toString());
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please select Playlist");
                              }
                            },
                            child: const Text("Save")),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ]),
        ),
      ),
      actions: [
        TextButton(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              minimumSize: Size(MediaQuery.of(context).size.width * 0.09, 40)),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void saveSongToPlayList(String PlaylistName) {}
}

class BottomMenu extends StatefulWidget {
  const BottomMenu({
    super.key,
    required this.songData,
  });
  final Map<String, dynamic> songData;
  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          QuerySnapshot snap = await FirebaseFirestore.instance
              .collection("SongMetaData")
              .where("title", isEqualTo: widget.songData['title'])
              .limit(1)
              .get();
          Map<String, dynamic> songData =
              snap.docs.first.data() as Map<String, dynamic>;

          // ignore: use_build_context_synchronously
          showModalBottomSheet(
              context: context,
              builder: (BuildContext builderContext) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade400,
                            Colors.deepPurple.shade700,
                            Colors.deepPurple.shade800,
                          ],
                          end: Alignment.topCenter,
                          begin: Alignment.bottomCenter),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      color: Colors.deepPurple.shade300),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Center(
                                  child: Text(
                                songData['title'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              )),
                              Expanded(
                                child: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text("Add to Playlist"),
                      leading: const Icon(Icons.playlist_add_check),
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreatePlayListWidget(
                                    model: PlayerModel(
                                        songName: songData['title'],
                                        artist: songData['artist'],
                                        artworkUrl: songData['artworkUrl'],
                                        songUrl: songData['songUrl']))));
                      },
                    ),
                    ListTile(
                      title: const Text("Add to Queue"),
                      leading: const Icon(Icons.queue_music_outlined),
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      onTap: () {
                        EditQueue queue = EditQueue();
                        queue.addToQueue(PlayerModel(
                            songName: songData['title'],
                            artist: songData['artist'],
                            artworkUrl: songData['artworkUrl'],
                            songUrl: songData['songUrl']));
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text("Open Album"),
                      leading: const Icon(Icons.album_outlined),
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewMore(
                                    title: songData['album'],
                                    albums: [songData['album']])));
                      },
                    ),
                    ListTile(
                      title: const Text("Share"),
                      leading: const Icon(Icons.share),
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      onTap: () async {
                        final Uri uri = Uri(
                          scheme: 'sms',
                          path: '',
                          queryParameters: {
                            'body':
                                'Download My App Using This Link : \n and Play Song ${songData['title']}'
                          },
                        );

                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          // Handle error
                          print('Could not launch messaging app');
                        }
                      },
                    ),
                    ListTile(
                      title: const Text("Show Artists"),
                      leading: const Icon(Icons.people),
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return AlertDialog(
                            icon: const Icon(Icons.people),
                            title: Text(
                              "Artists of Song \n${songData['title']}",
                              textAlign: TextAlign.center,
                            ),
                            titleTextStyle: const TextStyle(
                                fontSize: 20, color: Colors.white),
                            backgroundColor: Colors.deepPurple.shade400,
                            iconColor: Colors.white,
                            content: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ImageLoader(
                                    imageUrl: songData['artworkUrl'],
                                    width: 80,
                                    height: 80,
                                  ),
                                  const Text(
                                    "Artists",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  for (int index = 0;
                                      index <
                                          songData['artist']
                                              .toString()
                                              .split(',')
                                              .length;
                                      index++)
                                    ListTile(
                                      leading: Text(
                                        "${index + 1}.",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 17),
                                      ),
                                      title: Text(
                                        songData['artist']
                                            .toString()
                                            .split(',')[index],
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 17),
                                      ),
                                    ),
                                  if (songData['artist'].isEmpty)
                                    const Text(
                                      "No Artists",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 22),
                                    ),
                                  const Text(
                                    "Composer",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.album,
                                        color: Colors.white54,
                                      ),
                                      title: Text(
                                        songData['composer'],
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.deepOrange,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0)),
                                          minimumSize: Size(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                              50)),
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close",
                                          style: TextStyle(fontSize: 17))),
                                ],
                              ),
                            ),
                          );
                        }));
                      },
                    ),
                  ]),
                );
              });
        },
        icon: const Icon(
          Icons.more_vert,
          color: Colors.white,
        ));
  }
}

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              const DiscoverMusic(),
              TrendingMusic(),
              const AlbumsMusic(),
              const OtherSongs()
            ],
          ),
        ),
      ],
    );
  }
}

class OtherSongs extends StatefulWidget {
  const OtherSongs({super.key});

  @override
  State<OtherSongs> createState() => _OtherSongsState();
}

class _OtherSongsState extends State<OtherSongs> {
  int limit = 20;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SectionHeader(title: "More Songs", albums: []),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("SongMetaData")
                    .orderBy("Like_Count")
                    .limit(limit)
                    .snapshots(),
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
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SongPlayer(
                                            model: PlayerModel(
                                                songName: songData['title'],
                                                artist: songData['artist'],
                                                artworkUrl:
                                                    songData['artworkUrl'],
                                                songUrl: songData['songUrl']),
                                            snapshot: snapshot.data!)));
                              },
                              child:
                                  HomeScreen.songListTile(songData, context));
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
                }),
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  limit = limit + 5;
                });
              },
              child: Text(
                "More Songs",
                style: GoogleFonts.poppins(color: Colors.deepPurple),
              ))
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class _CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  String title;
  String profilePic;
  Function changeScreen;
  _CustomAppbar(this.title, this.profilePic, this.changeScreen);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Container(
        margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Text(
          greet(title),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.black.withOpacity(0.3),
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(
            right: 20.0,
          ),
          child: InkWell(
            onTap: () {
              changeScreen(4);
            },
            child: CircleAvatar(
                backgroundImage: (profilePic != '')
                    ? CachedNetworkImageProvider(profilePic)
                    : const CachedNetworkImageProvider(
                        'https://cdn2.vectorstock.com/i/1000x1000/23/81/default-avatar-profile-icon-vector-18942381.jpg')),
          ),
        )
      ],
      leading: IconButton(
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        icon: const Icon(Icons.grid_view_rounded),
        color: Colors.white,
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(56.0);

  String greet(String title) {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour < 12) {
      return 'Morning Masala for\n$title';
    } else if (hour < 17) {
      return 'AfterNoon Vibes for\n$title';
    } else if (hour < 21) {
      return 'Energetic Evenings for\n$title';
    } else if (hour < 24) {
      return 'Chilling Night for\n$title';
    } else if (hour < 4) {
      return 'Mid-Night Parties for\n$title';
    } else {
      return 'Hello\n$title';
    }
  }
}
