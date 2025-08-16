import 'package:flutter/material.dart';

class FullscreenImage extends StatelessWidget {
  final String imageUrl;

  FullscreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: InteractiveViewer(child: Image.network(imageUrl),),
          ),
        ),
      ),
    );
  }
}
