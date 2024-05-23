import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:beat_buddy/Authantication/EmailAuth/Login.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

class OfflineMusic extends StatefulWidget {
  const OfflineMusic({super.key, required this.title});
  final String title;
  @override
  State<OfflineMusic> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<OfflineMusic> {
  Color bgColor = Colors.amberAccent;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _player = AudioPlayer();
  List<SongModel> songs = [];
  String currentSongTitle = '';
  int currentIndex = 0;
  bool isPlaying = false;
  bool isPlayerViewVisible = false;

  //define a method to set the player view visibility
  void _changePlayerViewVisibility() {
    setState(() {
      isPlayerViewVisible = !isPlayerViewVisible;
      if (_player.playing) {
        isPlaying = true;
      }
    });
  }

  //duration state stream
  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          _player.positionStream,
          _player.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));

  bool delayed = false;

  //request permission from initStateMethod
  @override
  void initState() {
    super.initState();
    _loadSongs();
    initilizeList();
    _player.currentIndexStream.listen((index) {
      if (index != null) {
        _updateCurrentPlayingSongDetails(index);
      }
    });
  }

  PageController pageController = PageController();

  //dispose the player when done
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  late List<SongModel> _songs;
  String _searchQuery = "";

  Future<void> _loadSongs() async {
    final songs = await _audioQuery.querySongs();
    setState(() {
      _songs = songs;
    });
  }

  List<SongModel> _filteredSongs() {
    return _songs.where((song) {
      final title = song.title.toLowerCase();
      return title.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isPlayerViewVisible) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: queryArtworkWidget()),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  if (_player.hasPrevious) {
                    _player.seekToPrevious();
                  } else {
                    _player.seek(Duration.zero, index: songs.length);
                  }
                } else if (details.primaryVelocity! < 0) {
                  if (_player.hasNext) {
                    _player.seekToNext();
                  } else {
                    _player.seek(Duration.zero, index: 0);
                  }
                }
              },
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.only(top: 56.0, right: 20.0, left: 20.0),
                  // decoration: BoxDecoration(color: bgColor),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                _changePlayerViewVisibility();
                              }, //hides the player view
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: getDecoration(BoxShape.circle,
                                    const Offset(2, 2), 2.0, 0.0),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                          const Flexible(
                            flex: 2,
                            child: Text(
                              "Now Playing",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),

                      //artwork container
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 300,
                              height: 300,
                              decoration: getDecoration(BoxShape.rectangle,
                                  const Offset(4, 4), 4.0, 4.0),
                              margin:
                                  const EdgeInsets.only(top: 30, bottom: 30),
                              child: QueryArtworkWidget(
                                id: songs[currentIndex].id,
                                type: ArtworkType.AUDIO,
                                quality: 100,
                                artworkBorder: BorderRadius.circular(10.0),
                                nullArtworkWidget:
                                    Image.asset("Assets/Images/mp3.png"),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              child: Text(
                                currentSongTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            SizedBox(
                              height: 70,
                              child: Text(
                                "\nArtist : ${songs[currentIndex].artist!} \nAlbum : ${songs[currentIndex].album!}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      ),

                      //slider , position and duration widgets
                      Column(
                        children: [
                          //slider bar container
                          Container(
                            padding: EdgeInsets.zero,
                            margin: const EdgeInsets.only(bottom: 4.0),

                            //slider bar duration state stream
                            child: StreamBuilder<DurationState>(
                              stream: _durationStateStream,
                              builder: (context, snapshot) {
                                final durationState = snapshot.data;
                                final progress =
                                    durationState?.position ?? Duration.zero;
                                final total =
                                    durationState?.total ?? Duration.zero;

                                return ProgressBar(
                                  progress: progress,
                                  thumbGlowColor: Colors.black,
                                  bufferedBarColor: Colors.black,
                                  total: total,
                                  barHeight: 5.0,
                                  baseBarColor: Colors.black,
                                  progressBarColor: const Color(0xEE9E9E9E),
                                  thumbColor: Colors.white.withBlue(99),
                                  timeLabelTextStyle: const TextStyle(
                                    fontSize: 0,
                                  ),
                                  onSeek: (duration) {
                                    _player.seek(duration);
                                  },
                                );
                              },
                            ),
                          ),

                          //position /progress and total text
                          StreamBuilder<DurationState>(
                            stream: _durationStateStream,
                            builder: (context, snapshot) {
                              final durationState = snapshot.data;
                              final progress =
                                  durationState?.position ?? Duration.zero;
                              final total =
                                  durationState?.total ?? Duration.zero;

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    child: Text(
                                      progress.toString().split(".")[0],
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      total.toString().split(".")[0],
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),

                      //prev, play/pause & seek next control buttons
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            //skip to previous
                            Flexible(
                              child: InkWell(
                                onTap: () {
                                  if (_player.hasPrevious) {
                                    _player.seekToPrevious();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: getDecoration(BoxShape.circle,
                                      const Offset(2, 2), 2.0, 2.0),
                                  child: const Icon(
                                    Icons.skip_previous,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),

                            //play pause
                            Flexible(
                              child: InkWell(
                                onTap: () {
                                  if (_player.playing) {
                                    _player.pause();
                                    setState(() {
                                      isPlaying = false;
                                    });
                                  } else {
                                    if (_player.currentIndex != null) {
                                      _player.play();
                                      setState(() {
                                        isPlaying = true;
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20.0),
                                  margin: const EdgeInsets.only(
                                      right: 20.0, left: 20.0),
                                  decoration: getDecoration(BoxShape.circle,
                                      const Offset(2, 2), 2.0, 2.0),
                                  child: StreamBuilder<bool>(
                                    stream: _player.playingStream,
                                    builder: (context, snapshot) {
                                      bool? playingState = snapshot.data;
                                      if (playingState != null &&
                                          playingState) {
                                        return const Icon(
                                          Icons.pause,
                                          size: 30,
                                          color: Colors.white70,
                                        );
                                      }
                                      return const Icon(
                                        Icons.play_arrow,
                                        size: 30,
                                        color: Colors.white70,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            //skip to next
                            Flexible(
                              child: InkWell(
                                onTap: () {
                                  if (_player.hasNext) {
                                    _player.seekToNext();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: getDecoration(BoxShape.circle,
                                      const Offset(2, 2), 2.0, 2.0),
                                  child: const Icon(
                                    Icons.skip_next,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //go to playlist, shuffle , repeat all and repeat one control buttons
                      Container(
                        margin: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            //go to playlist btn
                            Flexible(
                              child: InkWell(
                                onTap: () {
                                  _changePlayerViewVisibility();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: getDecoration(BoxShape.circle,
                                      const Offset(2, 2), 2.0, 0.0),
                                  child: const Icon(
                                    Icons.list_alt,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),

                            //shuffle playlist
                            Flexible(
                              child: InkWell(
                                onTap: () {
                                  _player.setShuffleModeEnabled(true);
                                  toast(context, "Shuffling enabled");
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  margin: const EdgeInsets.only(
                                      right: 30.0, left: 30.0),
                                  decoration: getDecoration(BoxShape.circle,
                                      const Offset(2, 2), 2.0, 0.0),
                                  child: const Icon(
                                    Icons.shuffle,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),

                            //repeat mode
                            Flexible(
                              child: InkWell(
                                onTap: () {
                                  _player.loopMode == LoopMode.one
                                      ? _player.setLoopMode(LoopMode.all)
                                      : _player.setLoopMode(LoopMode.one);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: getDecoration(BoxShape.circle,
                                      const Offset(2, 2), 2.0, 0.0),
                                  child: StreamBuilder<LoopMode>(
                                    stream: _player.loopModeStream,
                                    builder: (context, snapshot) {
                                      final loopMode = snapshot.data;
                                      if (LoopMode.one == loopMode) {
                                        return const Icon(
                                          Icons.repeat_one,
                                          color: Colors.white70,
                                        );
                                      }
                                      return const Icon(
                                        Icons.repeat,
                                        color: Colors.white70,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 20,
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'item1',
                  child: Row(
                    children: [
                      const Icon(Icons.online_prediction),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Back Online !!',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'item2',
                  child: Row(
                    children: [
                      const Icon(Icons.playlist_add_check_circle),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Play List',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'item3',
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Profile',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'item4',
                  child: Row(
                    children: [
                      const Icon(Icons.logout),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Exit App',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ];
            },
            color: Colors.black.withOpacity(0.8),
            onSelected: (String value) {
              // Handle the selected item here
              switch (value) {
                case 'item1':
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EmailLogin()));
                  break;
                case 'item2':
                  // Handle item 2 selection
                  break;
                case 'item3':
                  // Handle item 3 selection
                  break;
                case 'item4':
                  SystemNavigator.pop();
                  break;
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.deepPurple.shade800,
                Colors.deepPurple.shade200,
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
          FutureBuilder<List<SongModel>>(
            //default values
            future: _audioQuery.querySongs(
              orderType: OrderType.ASC_OR_SMALLER,
              uriType: UriType.EXTERNAL,
              ignoreCase: true,
            ),
            builder: (context, item) {
              //loading content indicator
              if (item.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              //no songs found
              if (item.data!.isEmpty) {
                return const Center(
                  child: Text("No Songs Found"),
                );
              }

              if (songs.isNotEmpty) {
                Future.delayed(const Duration(seconds: 2), () {});
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.001,
                            ),
                            Text(
                              "Enjoy your Favouraite Music",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 18),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            TextFormField(
                              onChanged: (query) {
                                setState(() {
                                  _searchQuery = query;
                                });
                              },
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.579,
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        child: ListView.builder(
                            itemCount: _filteredSongs().length,
                            itemBuilder: (context, index) {
                              final song = _filteredSongs()[index];
                              return Container(
                                margin: const EdgeInsets.only(
                                    top: 10.0, left: 12.0, right: 16.0),
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(10.0),
                                  // boxShadow: const [
                                  //   BoxShadow(
                                  //     blurRadius: 2.0,
                                  //     offset: Offset(-2, -2),
                                  //     color: Colors.black54,
                                  //   ),
                                  //   BoxShadow(
                                  //     blurRadius: 4.0,
                                  //     offset: Offset(4, 4),
                                  //     color: Colors.black54,
                                  //   ),
                                  // ],
                                ),
                                child: ListTile(
                                  textColor: Colors.white,
                                  title: Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Container(
                                          padding:
                                              const EdgeInsets.only(right: 2),
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                          ),
                                          child: const Text(" LYRICS ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ))),
                                      Expanded(
                                        child: Text(
                                          song.artist!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  leading: QueryArtworkWidget(
                                    id: item.data![index].id,
                                    type: ArtworkType.AUDIO,
                                    quality: 100,
                                    nullArtworkWidget:
                                        Image.asset("Assets/Images/mp3.png"),
                                  ),
                                  onTap: () async {
                                    _changePlayerViewVisibility();
                                    toast(context, "Playing:  ${song.title}");
                                    await _player.setAudioSource(
                                        createPlaylist(item.data!),
                                        initialIndex: index);
                                    await _player.play();
                                  },
                                ),
                              );
                            }),
                      ),
                    ),
                    GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! > 0) {
                          //seek to Previous
                          if (_player.hasPrevious) {
                            _player.seekToPrevious();
                          } else {
                            toast(context, "No Songs Left in List");
                          }
                          print("Prev");
                        } else if (details.primaryVelocity! < 0) {
                          //seek to Next
                          if (_player.hasNext) {
                            _player.seekToNext();
                          } else {
                            toast(context, "No Songs Left in List");
                          }
                          print("next");
                        }
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        decoration: const BoxDecoration(
                            color: Colors.black54,
                            boxShadow: [
                              // BoxShadow(
                              //   blurRadius: 4.0,
                              //   offset: Offset(-4, -4),
                              //   color: Colors.black87,
                              // ),
                            ]),
                        child: Center(
                          child: ListTile(
                            autofocus: true,
                            leading: QueryArtworkWidget(
                              id: songs[currentIndex].id,
                              type: ArtworkType.AUDIO,
                              nullArtworkWidget:
                                  Image.asset("Assets/Images/mp3.png"),
                            ),
                            title: InkWell(
                              onTap: () async {
                                if (_player.playing) {
                                  _changePlayerViewVisibility();
                                } else {
                                  toast(context,
                                      "Playing:  ${songs[currentIndex].title}");
                                  _changePlayerViewVisibility();
                                }
                              },
                              child: Text(
                                "${songs[currentIndex].displayName}\n",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            subtitle: StreamBuilder<DurationState>(
                              stream: _durationStateStream,
                              builder: (context, snapshot) {
                                final durationState = snapshot.data;
                                final progress =
                                    durationState?.position ?? Duration.zero;
                                final total =
                                    durationState?.total ?? Duration.zero;

                                return ProgressBar(
                                  progress: progress,
                                  total: total,
                                  barHeight: 10.0,
                                  baseBarColor: Colors.black,
                                  progressBarColor: const Color(0xEE9E9E9E),
                                  thumbColor: Colors.white.withBlue(99),
                                  timeLabelTextStyle: const TextStyle(
                                    fontSize: 0,
                                  ),
                                  onSeek: (duration) {
                                    _player.seek(duration);
                                  },
                                );
                              },
                            ),
                            trailing: InkWell(
                              onTap: () async {
                                if (_player.playing) {
                                  _player.pause();
                                } else {
                                  if (_player.currentIndex != null) {
                                    _player.play();
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5.0),
                                margin: const EdgeInsets.only(
                                    right: 10.0, left: 10.0),
                                decoration: getDecoration(BoxShape.circle,
                                    const Offset(1, 1), 1.0, 2.0),
                                child: StreamBuilder<bool>(
                                  stream: _player.playingStream,
                                  builder: (context, snapshot) {
                                    bool? playingState = snapshot.data;
                                    if (playingState != null && playingState) {
                                      return const Icon(
                                        Icons.pause,
                                        size: 40,
                                        color: Colors.white70,
                                      );
                                    }
                                    return const Icon(
                                      Icons.play_arrow,
                                      size: 40,
                                      color: Colors.white70,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void initilizeList() async {
    songs = await _audioQuery.querySongs(
        orderType: OrderType.ASC_OR_SMALLER, uriType: UriType.EXTERNAL);
    await _player.setAudioSource(createPlaylist(songs), initialIndex: 0);
  }

  //define a toast method
  void toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
    ));
  }

  //create playlist
  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  //update playing song details
  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if (songs.isNotEmpty) {
        currentSongTitle = songs[index].title;
        currentIndex = index;
      }
    });
  }

  BoxDecoration getDecoration(
      BoxShape shape, Offset offset, double blurRadius, double spreadRadius) {
    return BoxDecoration(
      color: Colors.black,
      shape: shape,
      boxShadow: [
        BoxShadow(
          offset: -offset,
          color: Colors.white24,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
        BoxShadow(
          offset: offset,
          color: Colors.black,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        )
      ],
    );
  }

  Widget queryArtworkWidget() {
    // Replace this with your actual widget or image.
    return QueryArtworkWidget(
      id: songs[currentIndex].id,
      type: ArtworkType.AUDIO,
      artworkFit: BoxFit.fill,
      quality: 100,
      artworkQuality: FilterQuality.high,
      artworkBorder: BorderRadius.zero,
    );
  }

  BoxDecoration getRectDecoration(BorderRadius borderRadius, Offset offset,
      double blurRadius, double spreadRadius) {
    return BoxDecoration(
      borderRadius: borderRadius,
      color: bgColor,
      boxShadow: [
        BoxShadow(
          offset: -offset,
          color: Colors.white24,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
        BoxShadow(
          offset: offset,
          color: Colors.black,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        )
      ],
    );
  }
}

//duration class
class DurationState {
  DurationState(
      {this.position = Duration.zero,
      this.buffered = Duration.zero,
      this.total = Duration.zero});
  Duration position, total, buffered;
}
