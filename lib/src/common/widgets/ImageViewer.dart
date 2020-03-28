import 'package:flutter/material.dart';

class ImageViewer extends StatefulWidget {
  final int index;
  final bool isNetworkList;
  final List imagesData;
  ImageViewer({Key key, this.imagesData, this.index, this.isNetworkList})
      : super(key: key);
  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          height: 350.0,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imagesData.length,
              itemBuilder: (context, index) {
                return Image.network(
                  widget.imagesData[index],
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                );
              })),
    );
  }
}
