import 'package:flutter/material.dart';
import 'package:beat_buddy/screens/viewMore.dart';
import 'package:beat_buddy/widgets/ImageLoader.dart';

class horizontalAlbumCard extends StatelessWidget {
  const horizontalAlbumCard({
    super.key,
    required this.artworkUrl,
    required this.title,
  });

  final String artworkUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViewMore(title: title, albums: [title])),
        ),
        child: Column(
          children: [
            ImageLoader(
              imageUrl: artworkUrl,
              width: 170,
              height: 170,
              radius: const BorderRadius.only(
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.zero,
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15)),
            ),
            SizedBox(
                width: 170,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                      color: Colors.black.withOpacity(0.7)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
