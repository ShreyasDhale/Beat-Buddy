import 'dart:async';
import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:beat_buddy/PlayerMethods/player.dart';
import 'package:beat_buddy/models/ShowMessages.dart';
import 'package:beat_buddy/models/playerModel.dart';
import 'package:beat_buddy/screens/OfflineMusic.dart';
import 'package:beat_buddy/screens/home_screen.dart';
import 'package:beat_buddy/widgets/ImageLoader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

AudioPlayer audioPlayer = AudioPlayer();

// ignore: must_be_immutable
class SongPlayer extends StatefulWidget {
  SongPlayer({super.key, required this.model, required this.snapshot});
  PlayerModel model;
  QuerySnapshot snapshot;

  @override
  State<SongPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<SongPlayer> {
  int likeCount = 0;
  double progress = 0;
  Player player = Player(audioPlayer);
  bool isLiked = false;
  bool isShuffling = false;
  bool isRepeating = false;
  bool isLoading = false;
  bool isPlaying = false;
  QuerySnapshot? snapshot;
  late StreamSubscription playerStateStream;

  @override
  void initState() {
    super.initState();
    initilize();
  }

  Future<void> initilize() async {
    snapshot =
        await FirebaseFirestore.instance.collection("SongMetaData").get();
    await FirebaseFirestore.instance
        .collection("SongMetaData")
        .where("title", isEqualTo: widget.model.songName)
        .get()
        .then((value) => value.docs.forEach((element) {
              Map<String, dynamic> songData = element.data();
              setState(() {
                likeCount = songData['Like_Count'] ?? 0;
              });
            }));

    bool liked = await player.isLiked(widget.model.songName);
    player.playAudioFromUrl(widget.model.songUrl);
    setState(() {
      isLiked = liked;
      isPlaying = true;
    });
    playerStateStream = audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        player.playNext(widget.snapshot, widget.model, updateUI, false, false);
      } else if (state.processingState == ProcessingState.loading) {
        setState(() {
          isLoading = true;
        });
      } else if (state.processingState == ProcessingState.buffering) {
        setState(() {
          isLoading = true;
        });
      } else if (state.processingState == ProcessingState.ready) {
        setState(() {
          isLoading = false;
        });
      } else if (state.processingState == ProcessingState.idle) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    playerStateStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.network(
            widget.model.artworkUrl,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          )),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Container(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(
                    "Music Player",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700),
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                  centerTitle: true,
                  actions: [
                    BottomMenu(songData: {
                      "title": widget.model.songName,
                      "artist": widget.model.artist,
                      "artworkUrl": widget.model.artworkUrl,
                      "songUrl": widget.model.songUrl,
                    })
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  widget.model.songName,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 10,
                ),
                ImageLoader(
                  imageUrl: widget.model.artworkUrl,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.4,
                  radius: BorderRadius.circular(20),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Artist : ${widget.model.artist}",
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  margin: const EdgeInsets.only(bottom: 4.0),
                  child: Column(
                    children: [
                      StreamBuilder<DurationState>(
                        stream: player.durationStateStream,
                        builder: (context, snapshot) {
                          final durationState = snapshot.data;
                          final progress =
                              durationState?.position ?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;
                          final buffered = durationState?.buffered;

                          return ProgressBar(
                            progress: progress,
                            buffered: buffered,
                            thumbGlowColor: Colors.black,
                            bufferedBarColor: Colors.white54,
                            total: total,
                            barHeight: 5.0,
                            baseBarColor: Colors.white38,
                            thumbColor: Colors.white,
                            timeLabelTextStyle: const TextStyle(
                              fontSize: 0,
                            ),
                            onSeek: (duration) {
                              audioPlayer.seek(duration);
                            },
                          );
                        },
                      ),
                      StreamBuilder<DurationState>(
                        stream: player.durationStateStream,
                        builder: (context, snapshot) {
                          final durationState = snapshot.data;
                          final progress =
                              durationState?.position ?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                child: Text(
                                  HomeScreen.convertDuration(
                                      progress.inMilliseconds),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  HomeScreen.convertDuration(
                                      total.inMilliseconds),
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
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (!isRepeating) {
                                  setState(() {
                                    isShuffling = !isShuffling;
                                  });
                                  if (isShuffling) {
                                    MessageHandler.showAction(
                                        context, "Now Shuffleing Songs");
                                  } else {
                                    MessageHandler.showAction(
                                        context, "Now Stoped Shuffeling");
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Cannot Shuffle while repeating is on");
                                }
                              },
                              icon: Icon(
                                isShuffling ? Icons.shuffle : Icons.shuffle,
                                size: 30,
                                color:
                                    isShuffling ? Colors.green : Colors.white,
                              ),
                            ),
                            Text(
                              isShuffling ? "Shuffle On" : "Shuffle",
                              style: TextStyle(
                                  color:
                                      isShuffling ? Colors.green : Colors.white,
                                  fontSize: 10),
                            )
                          ],
                        ),
                        IconButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  player.playprevious(
                                      widget.snapshot,
                                      widget.model,
                                      updateUI,
                                      isShuffling,
                                      isRepeating);
                                },
                          icon: Icon(
                            Icons.skip_previous,
                            size: 40,
                            color: isLoading ? Colors.white54 : Colors.white,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              if (player.playing()) {
                                audioPlayer.pause();
                                setState(() {
                                  isPlaying = false;
                                });
                              } else {
                                audioPlayer.play();
                                setState(() {
                                  isPlaying = true;
                                });
                              }
                            },
                            icon: isPlaying
                                ? const Icon(
                                    Icons.pause_circle_filled,
                                    size: 60,
                                    color: Colors.white,
                                  )
                                : const Icon(
                                    Icons.play_circle_fill,
                                    size: 60,
                                    color: Colors.white,
                                  )),
                        IconButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  player.playNext(widget.snapshot, widget.model,
                                      updateUI, isShuffling, isRepeating);
                                },
                          icon: Icon(
                            Icons.skip_next,
                            size: 40,
                            color: isLoading ? Colors.white54 : Colors.white,
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () async {
                                player.likeDislike(
                                    widget.model.songName, updateIcons);
                              },
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 30,
                                color: isLiked ? Colors.red : Colors.white,
                              ),
                            ),
                            Text(
                              likeCount.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isLoading)
                      const SizedBox(
                        height: 45,
                        width: 45,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth:
                              5, // Adjust the strokeWidth to change the thickness of the indicator
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          IconButton(
                              onPressed: () {
                                player.saveFile(
                                    widget.model.songUrl,
                                    widget.model.songName,
                                    context,
                                    updateDownload);
                              },
                              icon: const Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 32,
                              )),
                          Text(
                            "Download",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 10),
                          )
                        ],
                      ),
                      if (progress != 0)
                        Text(
                          "Downloading... ${progress.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      Column(
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  isRepeating = !isRepeating;
                                });
                                if (isRepeating) {
                                  MessageHandler.showAction(context,
                                      "Repeating ${widget.model.songName}");
                                } else {
                                  MessageHandler.showAction(
                                      context, "Stopped Repeating");
                                }
                              },
                              icon: isRepeating
                                  ? const Icon(
                                      Icons.repeat,
                                      color: Colors.green,
                                      size: 32,
                                    )
                                  : const Icon(
                                      Icons.repeat,
                                      color: Colors.white,
                                      size: 32,
                                    )),
                          Text(
                            isRepeating ? "Repeat_on" : "Repeat",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 10),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                if (progress != 0)
                  LinearProgressIndicator(
                    value: progress / 100,
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void updateDownload(double pro) {
    setState(() {
      progress = pro;
    });
  }

  void updateUI(PlayerModel model, bool liked, int count, bool playing) {
    setState(() {
      widget.model = model;
      isLiked = liked;
      likeCount = count;
      isPlaying = playing;
    });
  }

  void updateIcons(bool liked, int count) {
    setState(() {
      isLiked = liked;
      likeCount = count;
    });
  }
}
