import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          height: 350.0,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imagesData.length,
              itemBuilder: (context, index) {
                return ExtendedImage.network(
                  widget.imagesData[index],
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  cache: true,
                  enableLoadState: true,
                  loadStateChanged: (ExtendedImageState state) {
                    if (state.extendedImageLoadState == LoadState.loading) {
                      return SpinKitPulse(
                        color: Theme.of(context).primaryColor,
                        size: 50,
                      );
                    }
                    return null;
                  },
                );
              })),
    );
  }
}
