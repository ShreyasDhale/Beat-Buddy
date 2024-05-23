import 'dart:io';
import 'dart:math';

import 'package:beat_buddy/PlayerMethods/Queue.dart';
import 'package:beat_buddy/models/ShowMessages.dart';
import 'package:beat_buddy/models/playerModel.dart';
import 'package:beat_buddy/screens/OfflineMusic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

class Player {
  User? user = FirebaseAuth.instance.currentUser;
  AudioPlayer player = AudioPlayer();
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  CollectionReference songs =
      FirebaseFirestore.instance.collection("SongMetaData");
  QuerySnapshot? snapshot;
  EditQueue queue = EditQueue();

  Stream<DurationState> get durationStateStream =>
      Rx.combineLatest3<Duration, Duration?, Duration, DurationState>(
        player.positionStream,
        player.durationStream,
        player.bufferedPositionStream,
        (position, total, buffered) => DurationState(
          position: position,
          total: total ?? Duration.zero,
          buffered: buffered,
        ),
      );

  Player(AudioPlayer play) {
    player = play;
  }

  void playAudioFromUrl(String url) {
    if (player.playing) {
      player.pause();
    }
    player.setUrl(url);
    player.play();
  }

  bool playing() {
    return player.playing;
  }

  void pause() {
    player.pause();
  }

  void play() {
    player.play();
  }

  Future<void> playNext(QuerySnapshot snap, PlayerModel model,
      Function updateUI, bool isShuffling, bool isRepeating) async {
    PlayerModel playerModel = await queue.dequeue();
    List<Map<String, dynamic>> sortedSongs =
        snap.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    if (isRepeating) {
      playAudioFromUrl(model.songUrl);
    } else if (isShuffling) {
      Random rand = Random();
      int randomIndex = 0 + rand.nextInt((sortedSongs.length - 1) - 0 + 1);
      var nextSong = sortedSongs[randomIndex];
      playAudioFromUrl(nextSong['songUrl']);
    } else if (queue.isNotEmpty() && playerModel.songName != "") {
      playAudioFromUrl(playerModel.songUrl);
    } else {
      sortedSongs.sort((a, b) => a['title'].compareTo(b['title']));

      int size = sortedSongs.length;
      int index = binarySearch(sortedSongs, model.songName);

      int nextIndex = (index + 1) % size;
      var nextSong = sortedSongs[nextIndex];
      updateUI(
          PlayerModel(
              songName: nextSong['title'],
              artist: nextSong['artist'],
              artworkUrl: nextSong['artworkUrl'],
              songUrl: nextSong['songUrl']),
          await isLiked(nextSong['title']),
          await getLikeCount(nextSong['title']),
          true);
      playAudioFromUrl(nextSong['songUrl']);
    }
  }

  Future<void> playprevious(QuerySnapshot snap, PlayerModel model,
      Function updateUI, bool isShuffling, bool isRepeating) async {
    List<Map<String, dynamic>> sortedSongs =
        snap.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    sortedSongs.sort((a, b) => a['title'].compareTo(b['title']));

    if (isRepeating) {
      playAudioFromUrl(model.songUrl);
    } else if (isShuffling) {
      Random rand = Random();
      int randomIndex = 0 + rand.nextInt((sortedSongs.length - 1) - 0 + 1);
      var nextSong = sortedSongs[randomIndex];
      playAudioFromUrl(nextSong['songUrl']);
    } else {
      int size = sortedSongs.length;
      int index = binarySearch(sortedSongs, model.songName);

      int prevIndex = (index - 1) % size;
      var prevSong = sortedSongs[prevIndex];
      updateUI(
          PlayerModel(
              songName: prevSong['title'],
              artist: prevSong['artist'],
              artworkUrl: prevSong['artworkUrl'],
              songUrl: prevSong['songUrl']),
          await isLiked(prevSong['title']),
          await getLikeCount(prevSong['title']),
          true);
      playAudioFromUrl(prevSong['songUrl']);
    }
  }

  Future<void> likeDislike(String songName, Function updateUI) async {
    int updatedLikeCount = 0;
    if (await isLiked(songName)) {
      // Dislike: Remove from Liked_Songs and decrement Like_Count
      await users
          .doc(user!.uid)
          .collection("Liked_Songs")
          .where("title", isEqualTo: songName)
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference.delete();
              }));
      await songs
          .where("title", isEqualTo: songName)
          .get()
          .then((value) => value.docs.forEach((element) {
                Map<String, dynamic> songData =
                    element.data() as Map<String, dynamic>;
                int currentLikeCount = songData['Like_Count'] ?? 0;
                updatedLikeCount = currentLikeCount - 1;

                songs.doc(element.id).update({'Like_Count': updatedLikeCount});
              }));

      updateUI(false, updatedLikeCount);
    } else {
      // Like: Add to Liked_Songs and increment Like_Count
      await songs
          .where("title", isEqualTo: songName)
          .get()
          .then((value) => value.docs.forEach((element) {
                // Add to Liked_Songs
                users
                    .doc(user!.uid)
                    .collection("Liked_Songs")
                    .add(element.data() as Map<String, dynamic>);

                Map<String, dynamic> songData =
                    element.data() as Map<String, dynamic>;
                int currentLikeCount = songData['Like_Count'] ?? 0;
                updatedLikeCount = currentLikeCount + 1;

                // Update the Like_Count field
                songs.doc(element.id).update({'Like_Count': updatedLikeCount});
              }));

      updateUI(true, updatedLikeCount);
    }
  }

  Future<bool> isLiked(String songName) async {
    snapshot = await users
        .doc(user!.uid)
        .collection("Liked_Songs")
        .where("title", isEqualTo: songName)
        .get();
    if (snapshot!.size > 0) {
      return true;
    } else {
      return false;
    }
  }

  int binarySearch(List<Map<String, dynamic>> sortedSongs, String target) {
    int left = 0;
    int right = sortedSongs.length - 1;

    while (left <= right) {
      int mid = left + (right - left) ~/ 2;
      String midTitle = sortedSongs[mid]['title'];

      if (midTitle == target) {
        return mid;
      } else if (midTitle.compareTo(target) < 0) {
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }
    return -1;
  }

  Future<int> getLikeCount(String songName) async {
    int count = 0;
    await songs
        .where("title", isEqualTo: songName)
        .get()
        .then((value) => value.docs.forEach((element) {
              Map<String, dynamic> data =
                  element.data() as Map<String, dynamic>;
              count = data['Like_Count'];
            }));
    return count;
  }

  Future<void> saveFile(String downloadUrl, String fileName,
      BuildContext context, Function updateProgress) async {
    try {
      MessageHandler.showAction(context, "Download Started");
      final downloadDir = await getDownloadsDirectory();
      String path = "${downloadDir!.path}/$fileName.mp3";
      debugPrint(path);
      Dio dio = Dio();
      await dio.download(downloadUrl, path,
          onReceiveProgress: (actualBytes, totalBytes) {
        double per = actualBytes / totalBytes * 100;
        updateProgress(per);
      });
      MessageHandler.showSuccess(context, "File Downloaded Successfully !!");
      updateProgress(0.00);
      Fluttertoast.showToast(msg: path);
    } on HttpException catch (e) {
      MessageHandler.showError(context, e.message);
    } on IOException catch (ex) {
      MessageHandler.showError(context, ex.toString());
    } on DioException catch (e) {
      MessageHandler.showError(context, e.message!);
    }
  }
}
