import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:beat_buddy/screens/OfflineMusic.dart';
import 'package:beat_buddy/Authantication/EmailAuth/Login.dart';
import 'package:beat_buddy/screens/profile.dart';
import 'package:beat_buddy/Upload/upload_song.dart';

class SideBar extends StatelessWidget {
  const SideBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade800,
            ),
            child: const Text(
              'Sidebar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const profile()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.offline_bolt),
            title: const Text('Offline Songs'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OfflineMusic(
                            title: "Offline Songs",
                          )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Upload Songs'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UploadSong()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Fluttertoast.showToast(msg: "Work in Progress...");
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Downloads'),
            onTap: () {
              Fluttertoast.showToast(msg: "Work in Progress...");
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Fluttertoast.showToast(msg: ("LOged Out !!"));
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const EmailLogin()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
