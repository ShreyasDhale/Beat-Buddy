import 'package:beat_buddy/models/playerModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditQueue {
  EditQueue();
  CollectionReference queue = FirebaseFirestore.instance.collection("Queue");
  QuerySnapshot? snap;
  Future<void> refreshQueue() async {
    snap = null;
    snap = await queue.get();
  }

  Future<void> addToQueue(PlayerModel item) async {
    await queue.add({
      'title': item.songName,
      'artist': item.artist,
      'artworkUrl': item.artworkUrl,
      'songUrl': item.songUrl
    });
    Fluttertoast.showToast(msg: "${item.songName} added to Queue");
    await refreshQueue();
  }

  Future<PlayerModel> dequeue() async {
    await refreshQueue();
    if (isNotEmpty()) {
      Map<String, dynamic>? first =
          snap!.docs.first.data() as Map<String, dynamic>?;
      String id = snap!.docs.first.id;
      await queue.doc(id).delete();
      return PlayerModel(
          songName: first!['title'],
          artist: first['artist'],
          artworkUrl: first['artworkUrl'],
          songUrl: first['songUrl']);
    } else {
      return PlayerModel(
          songName: "",
          artist: "",
          artworkUrl: "",
          songUrl: ""); // Queue is empty
    }
  }

  Future<void> clearQueue() async {
    if (isNotEmpty()) {
      var batch = FirebaseFirestore.instance.batch();
      for (var doc in snap!.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      refreshQueue();
    } else {
      Fluttertoast.showToast(msg: "Queue is Already Empty");
    }
  }

  bool isNotEmpty() {
    return (snap?.size != 0);
  }
}
