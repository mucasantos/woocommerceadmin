import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/common/widgets/image_viewer.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/providers/product_provider.dart';

class ProductDetailsImages extends StatelessWidget {
  final int id;

  ProductDetailsImages({
    @required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        Product productData = productProvider.product;
        if (productData?.images is List && productData.images.isNotEmpty) {
          List<String> imagesSrcList = [];
          for (int i = 0; i < productData.images.length; i++) {
            if (productData?.images[i]?.src is String &&
                productData.images[i].src.isNotEmpty) {
              imagesSrcList.add(productData.images[i]?.src);
            }
          }
          return Container(
            height: 150,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imagesSrcList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewer(
                            imagesData: imagesSrcList,
                            index: index,
                            isNetworkList: true,
                          ),
                        ),
                      );
                    },
                    child: ExtendedImage.network(
                      imagesSrcList[index],
                      height: 150.0,
                      width: 150.0,
                      fit: BoxFit.contain,
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
                    ),
                  );
                },
              ),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
