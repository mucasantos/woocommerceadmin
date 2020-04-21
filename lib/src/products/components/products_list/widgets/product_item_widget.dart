import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:woocommerceadmin/src/products/components/product_details/screens/product_details_screen.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';

class ProductItemWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;
  final Product productData;

  ProductItemWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.productData,
  });

  @override
  Widget build(BuildContext context) {
    // return Consumer<Products>(
    //   builder: (context, productListData, _) {
    //     final Product productData = productListData.findById(id);
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                baseurl: baseurl,
                username: username,
                password: password,
                id: productData.id,
              ),
            ),
          );
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ((productData?.images == null
                      ? null
                      : productData.images.isEmpty
                          ? null
                          : productData.images[0]?.src) is String)
                  ? ExtendedImage.network(
                      productData.images[0].src,
                      fit: BoxFit.fill,
                      width: 140,
                      height: 140,
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
                    )
                  : SizedBox(
                      height: 140,
                      width: 140,
                    ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (productData?.name is String)
                          Text(
                            productData.name,
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        if (productData?.sku is String)
                          Text(
                            "SKU: ${productData.sku}",
                          ),
                        if (productData?.price is String)
                          Text(
                            "Price: ${productData.price}",
                          ),
                        if (productData?.stockStatus is String)
                          Text(
                            "Stock Status: ${productData.stockStatus}",
                          ),
                        if (productData?.stockQuantity is int)
                          Text(
                            "Stock: ${productData.stockQuantity}",
                          ),
                        if (productData?.status is String)
                          Text(
                            "Status: ${productData.status}",
                          )
                      ]),
                ),
              )
            ]),
      ),
    );
    // },
    // );
  }
}
