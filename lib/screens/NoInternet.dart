import 'package:flutter/material.dart';
import 'package:beat_buddy/screens/OfflineMusic.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({super.key});

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No Internet'),
            SizedBox(
              width: 170,
              child: ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OfflineMusic(
                                  title: "Enjoy Your Offline Music",
                                )));
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Explore Offline"),
                      Icon(Icons.music_note_rounded),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
