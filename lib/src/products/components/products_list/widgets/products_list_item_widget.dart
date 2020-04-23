import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:woocommerceadmin/src/products/components/product_details/screens/product_details_screen.dart';
import 'package:woocommerceadmin/src/products/models/product.dart';
import 'package:woocommerceadmin/src/products/providers/product_provider.dart';

class ProductItemWidget extends StatelessWidget {
  final String baseurl;
  final String username;
  final String password;
  final ProductProvider productProvider;

  ProductItemWidget({
    @required this.baseurl,
    @required this.username,
    @required this.password,
    @required this.productProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: productProvider,
                child: ProductDetailsScreen(
                  baseurl: baseurl,
                  username: username,
                  password: password,
                  id: productProvider?.product?.id,
                  // productProvider: productProvider,
                ),
              ),
            ),
          );
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ((productProvider?.product?.images == null
                      ? null
                      : productProvider.product.images.isEmpty
                          ? null
                          : productProvider.product.images[0]?.src) is String)
                  ? ExtendedImage.network(
                      productProvider.product.images[0].src,
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
                        if (productProvider?.product?.name is String)
                          Text(
                            productProvider.product.name,
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        if (productProvider?.product?.sku is String)
                          Text(
                            "SKU: ${productProvider.product.sku}",
                          ),
                        if (productProvider?.product?.price is String)
                          Text(
                            "Price: ${productProvider.product.price}",
                          ),
                        if (productProvider?.product?.stockStatus is String)
                          Text(
                            "Stock Status: ${productProvider.product.stockStatus}",
                          ),
                        if (productProvider?.product?.stockQuantity is int)
                          Text(
                            "Stock: ${productProvider.product.stockQuantity}",
                          ),
                        if (productProvider?.product?.status is String)
                          Text(
                            "Status: ${productProvider.product.status}",
                          )
                      ]),
                ),
              )
            ]),
      ),
    );
  }
}
